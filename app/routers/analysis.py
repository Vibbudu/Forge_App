"""
Primary analysis router — POST /api/full-analysis and POST /api/identify-photo.
Orchestrates all services into a unified response.
"""

from fastapi import APIRouter, Depends, Request
from motor.motor_asyncio import AsyncIOMotorDatabase
from cachetools import TTLCache
import hashlib
import logging

from app.core.limiter import limiter
from app.models.requests import FullAnalysisRequest, InputType, PhotoIdentifyRequest
from app.models.responses import (
    FullAnalysisResponse, MaterialRecommendation, MaterialProperties,
    AlternativeMaterial, StandardsResult, StandardResult,
    FailureResult, FailureMode, CostResult, CostEntry,
    VendorResult, Vendor, ConflictWarning,
)
from app.db.mongo import get_db
from app.services.gemini_service import gemini_service
from app.services.bulbul_service import bulbul_service
from app.services.materials_service import materials_service
from app.services.vendor_service import vendor_service
from app.data.standards_map import get_standards
from app.data.failure_map import get_failure_modes_dict
from app.data.pricing_map import get_pricing_dict, format_price_display
from app.core.exceptions import (
    InvalidInputException, MaterialNotFoundException,
    GeminiException,
)

logger = logging.getLogger(__name__)
router = APIRouter()

# Response cache: identical queries within 5 minutes don't re-call Gemini
_response_cache = TTLCache(maxsize=100, ttl=300)


def _cache_key(request: FullAnalysisRequest) -> str:
    """Generate a cache key from the request."""
    key_data = f"{request.input_type}{request.text}{request.advanced_params}{request.location}"
    return hashlib.md5(key_data.encode()).hexdigest()


def _infer_category_from_params(params) -> str | None:
    """
    Infer material category from slider values instead of hardcoding to 'metal'.
    Returns None to search across all categories when no strong signal exists.
    """
    ts = params.tensile_strength
    ductility = params.ductility
    corr = params.corrosion_resistance
    thermal = params.thermal_resistance
    density = params.density
    finish = getattr(params, "surface_finish", "matte")

    # Strong wood signals: low tensile, low density, moderate thermal
    if ts <= 4 and density <= 4 and thermal <= 5:
        return "wood"

    # Strong paint signals: very low tensile, very low density, surface finish focus
    if ts <= 2 and density <= 2:
        return "paint"

    # Strong concrete signals: high density, high tensile, low ductility
    if density >= 7 and ts >= 7 and ductility <= 3:
        return "concrete"

    # Strong glass signals: high corrosion resistance, low ductility, glossy finish
    if corr >= 8 and ductility <= 2 and finish == "glossy":
        return "glass"

    # Strong insulation signals: high thermal, very low density, low tensile
    if thermal >= 8 and density <= 3 and ts <= 3:
        return "insulation"

    # Strong ceramic signals: high thermal, high density, low ductility
    if thermal >= 8 and density >= 7 and ductility <= 3:
        return "ceramic"

    # Strong metal signals: high tensile, high density, moderate-high ductility
    if ts >= 7 and density >= 6:
        return "metal"

    # No strong signal — search ALL categories and let Gemini rank
    return None


@router.post("/full-analysis", response_model=FullAnalysisResponse)
@limiter.limit("10/minute")
async def full_analysis(
    request: Request,
    body: FullAnalysisRequest,
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    """Primary endpoint — full material analysis pipeline."""
    logger.info(f"Full analysis request: input_type={body.input_type}, language={body.language}")

    # Check cache
    cache_key = _cache_key(body)
    if cache_key in _response_cache:
        logger.info("Returning cached response")
        return _response_cache[cache_key]

    intent = {}
    photo_result = None

    # --- Step 1: Input routing ---
    if body.input_type == InputType.PHOTO:
        try:
            photo_result = await gemini_service.identify_material(body.photo_base64)
            synthetic_text = (
                f"I have a {photo_result.get('identified_material', 'unknown material')} "
                f"in {photo_result.get('environment_inference', 'outdoor')} conditions. "
                f"Condition: {photo_result.get('visible_condition', 'unknown')}. "
                f"Action needed: {photo_result.get('recommended_action', 'inspect')}."
            )
            intent = await gemini_service.extract_intent(synthetic_text)
        except GeminiException as e:
            raise InvalidInputException(f"Could not identify material from photo: {e.message}")

    elif body.input_type == InputType.ADVANCED:
        params = body.advanced_params
        # Infer category from slider values instead of hardcoding to "metal"
        inferred_category = _infer_category_from_params(params)
        intent = {
            "material_category": inferred_category,
            "environment": "outdoor",
            "use_case": "specified by advanced parameters",
            "property_priorities": ["tensile_strength", "corrosion_resistance"],
            "budget_sensitivity": "medium",
            "inferred_advanced_params": {
                "tensile_strength": params.tensile_strength,
                "ductility": params.ductility,
                "corrosion_resistance": params.corrosion_resistance,
                "malleability": params.malleability,
                "thermal_resistance": params.thermal_resistance,
                "density": params.density,
            },
            "conflict_check": {"has_conflicts": False, "conflicts": []},
        }
        detected_conflicts = materials_service.detect_conflicts(params.model_dump())
        if detected_conflicts:
            intent["conflict_check"] = {"has_conflicts": True, "conflicts": detected_conflicts}
    else:
        try:
            intent = await gemini_service.extract_intent(body.text)
        except GeminiException as e:
            raise InvalidInputException(f"Could not understand input: {e.message}")

    # --- Step 2: Query materials from MongoDB ---
    advanced_params = intent.get("inferred_advanced_params", {})
    candidates = await materials_service.query_by_properties(
        db, category=intent.get("material_category"), properties=advanced_params, limit=10
    )
    if not candidates:
        candidates = await materials_service.query_by_properties(db, category=None, properties={}, limit=5)
    if not candidates:
        raise MaterialNotFoundException("any material matching your requirements")

    # --- Step 3: Rank with Gemini ---
    ranked_names = await gemini_service.rank_candidates(intent, candidates)
    ranked_candidates = sorted(
        candidates, key=lambda c: ranked_names.index(c["name"]) if c["name"] in ranked_names else 999
    )
    primary = ranked_candidates[0]
    alternative_materials = ranked_candidates[1:3] if len(ranked_candidates) > 1 else []

    environment = intent.get("environment", "outdoor")
    use_case = intent.get("use_case", "general construction")

    # --- Step 4: Generate explanation ---
    explanation = await gemini_service.generate_explanation(
        material_name=primary["name"], use_case=use_case, environment=environment
    )

    # --- Step 5: Standards check ---
    raw_standards = list(get_standards(primary["name"], environment))
    standards_result = StandardsResult(
        passed=all(s["status"] == "PASS" for s in raw_standards),
        standards_checked=[s["standard"] for s in raw_standards],
        details=[StandardResult(**s) for s in raw_standards],
    )

    # --- Step 6: Failure analysis ---
    raw_failure = get_failure_modes_dict(primary["name"], environment)
    failure_result = FailureResult(
        risk_level=raw_failure["risk_level"],
        failure_modes=[FailureMode(**m) for m in raw_failure["failure_modes"]],
        overall_recommendation=raw_failure["overall_recommendation"],
    )

    # --- Step 7: Cost comparison ---
    all_mats = [primary] + alternative_materials
    cost_entries = []
    for mat in all_mats:
        pricing = get_pricing_dict(mat["name"])
        cost_entries.append(CostEntry(
            name=mat["name"],
            price_per_kg_min=pricing["price_per_kg_min"],
            price_per_kg_max=pricing["price_per_kg_max"],
            price_display=format_price_display(pricing["price_per_kg_min"], pricing["price_per_kg_max"]),
            tier=pricing["tier"], currency=pricing["currency"],
        ))
    cost_result = CostResult(comparison=cost_entries)

    # --- Step 8: Vendor search (non-fatal) ---
    try:
        raw_vendors = await vendor_service.search_vendors(
            material_name=primary["name"], lat=body.location.lat, lng=body.location.lng
        )
        vendor_result = VendorResult(vendors=[Vendor(**v) for v in raw_vendors], search_radius_km=10)
    except Exception as e:
        logger.warning(f"Vendor search failed, returning empty: {e}")
        vendor_result = VendorResult(vendors=[], search_radius_km=10)

    # --- Step 9: Conflict warning ---
    conflict_data = intent.get("conflict_check", {})
    conflict_warning = ConflictWarning(
        detected=conflict_data.get("has_conflicts", False),
        conflicts=conflict_data.get("conflicts", []),
        resolution=(
            "The recommendation below represents the best available tradeoff for your requirements."
            if conflict_data.get("has_conflicts") else None
        ),
    )

    # --- Step 10: TTS (non-fatal) ---
    tts_audio = None
    try:
        tts_text = bulbul_service.build_summary(
            material_name=primary["name"], explanation=explanation,
            risk_level=raw_failure["risk_level"], language=body.language.value,
        )
        tts_audio = await bulbul_service.synthesize(tts_text, body.language.value)
    except Exception as e:
        logger.warning(f"TTS generation failed, continuing without audio: {e}")

    # --- Build response ---
    props = primary.get("properties", {})
    recommendation = MaterialRecommendation(
        name=primary["name"], category=primary.get("category", "Unknown"),
        explanation=explanation, composition=primary.get("composition", {}),
        properties=MaterialProperties(
            tensile_strength=props.get("tensile_strength", 5),
            ductility=props.get("ductility", 5),
            corrosion_resistance=props.get("corrosion_resistance", 5),
            malleability=props.get("malleability", 5),
            thermal_resistance=props.get("thermal_resistance", 5),
            density=props.get("density", 5),
            surface_finish=props.get("surface_finish", "matte"),
        ),
        grade=primary.get("grade"),
    )

    alternatives = []
    for alt in alternative_materials:
        primary_pricing = get_pricing_dict(primary["name"])
        alt_pricing = get_pricing_dict(alt["name"])
        price_diff = alt_pricing["price_per_kg_min"] - primary_pricing["price_per_kg_min"]
        cost_diff_str = f"₹{abs(price_diff):.0f}/kg {'cheaper' if price_diff < 0 else 'more expensive'}"
        alternatives.append(AlternativeMaterial(
            name=alt["name"],
            reason=f"Alternative option with {alt.get('category', 'similar')} properties",
            cost_difference=cost_diff_str,
        ))

    response = FullAnalysisResponse(
        recommendation=recommendation, alternatives=alternatives,
        standards=standards_result, failure=failure_result,
        cost=cost_result, vendors=vendor_result,
        conflict_warning=conflict_warning,
        tts_audio_base64=tts_audio,
        tts_language=body.language.value if tts_audio else None,
        report_available=True,
    )

    # Cache the response
    _response_cache[cache_key] = response
    return response


@router.post("/identify-photo")
async def identify_photo(body: PhotoIdentifyRequest):
    """Standalone photo identification via Gemini 3 Flash vision."""
    try:
        result = await gemini_service.identify_material(body.photo_base64)
        return {"success": True, "identification": result}
    except GeminiException as e:
        raise InvalidInputException(f"Could not identify material from photo: {e.message}")
