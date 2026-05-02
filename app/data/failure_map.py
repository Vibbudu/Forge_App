"""
Hardcoded failure mode mappings per (material, environment) tuple.
Cached with lru_cache for zero-cost repeat lookups.
"""

from functools import lru_cache
import json

FAILURE_MAP: dict[tuple[str, str], list[dict]] = {
    ("mild steel", "coastal"): [
        {
            "type": "Uniform Corrosion",
            "severity": "HIGH",
            "description": "Rapid rust formation due to salt air and moisture exposure",
            "prevention": "Apply hot-dip galvanizing or epoxy coating before installation",
        },
        {
            "type": "Crevice Corrosion",
            "severity": "MEDIUM",
            "description": "Accelerated corrosion in joints and gaps where salt water pools",
            "prevention": "Seal all joints and ensure proper drainage design",
        },
    ],
    ("mild steel", "outdoor"): [
        {
            "type": "Surface Oxidation",
            "severity": "MEDIUM",
            "description": "Gradual rust formation with exposure to rain and humidity",
            "prevention": "Apply weather-resistant paint or primer coating annually",
        },
    ],
    ("mild steel", "industrial"): [
        {
            "type": "Chemical Corrosion",
            "severity": "HIGH",
            "description": "Accelerated degradation from industrial chemical exposure",
            "prevention": "Use chemical-resistant coatings and regular inspection schedule",
        },
    ],
    ("304 stainless steel", "coastal"): [
        {
            "type": "Pitting Corrosion",
            "severity": "MEDIUM",
            "description": "Localized pitting from chloride ion attack in marine environments",
            "prevention": "Consider upgrading to 316 grade for severe coastal exposure",
        },
    ],
    ("wood", "outdoor"): [
        {
            "type": "Moisture Absorption",
            "severity": "MEDIUM",
            "description": "Wood swells and warps with repeated wet-dry cycles",
            "prevention": "Apply waterproof sealant and elevate from ground contact",
        },
        {
            "type": "Biological Degradation",
            "severity": "LOW",
            "description": "Fungal growth and rot in persistently wet conditions",
            "prevention": "Use pressure-treated timber or teak for outdoor applications",
        },
    ],
    ("teak wood", "outdoor"): [
        {
            "type": "Surface Weathering",
            "severity": "LOW",
            "description": "Natural graying of surface due to UV exposure over time",
            "prevention": "Apply UV-resistant teak oil annually to maintain appearance",
        },
    ],
    ("concrete", "coastal"): [
        {
            "type": "Chloride Attack",
            "severity": "HIGH",
            "description": "Salt penetration causes internal rebar corrosion and spalling",
            "prevention": "Use sulphate-resistant cement and adequate concrete cover",
        },
    ],
    ("concrete", "outdoor"): [
        {
            "type": "Freeze-Thaw Cracking",
            "severity": "MEDIUM",
            "description": "Water ingress and freeze-thaw cycles cause surface spalling",
            "prevention": "Use air-entrained concrete and proper curing methods",
        },
    ],
    ("aluminum", "industrial"): [
        {
            "type": "Galvanic Corrosion",
            "severity": "HIGH",
            "description": "Rapid corrosion when in contact with dissimilar metals in industrial fluids",
            "prevention": "Use insulating gaskets and avoid direct contact with steel or copper",
        },
    ],
    ("aluminum alloy 6061", "coastal"): [
        {
            "type": "Filiform Corrosion",
            "severity": "MEDIUM",
            "description": "Thread-like corrosion under surface coatings in humid saline air",
            "prevention": "Use anodized finish and inspect coating integrity regularly",
        },
    ],
    ("galvanized steel", "coastal"): [
        {
            "type": "White Rust",
            "severity": "MEDIUM",
            "description": "Zinc coating reacts with salt air producing white oxide deposits",
            "prevention": "Apply chromate passivation and allow proper drying between exposures",
        },
    ],
}

RISK_THRESHOLDS = {
    "HIGH": "HIGH",
    "MEDIUM": "MEDIUM",
    "LOW": "LOW",
}

NO_FAILURE_RESPONSE = {
    "risk_level": "LOW",
    "failure_modes": [
        {
            "type": "General Wear",
            "severity": "LOW",
            "description": "Normal aging expected with standard maintenance",
            "prevention": "Follow manufacturer recommended maintenance schedule",
        }
    ],
    "overall_recommendation": "This material is well suited for the specified conditions with standard maintenance.",
}


@lru_cache(maxsize=256)
def get_failure_modes(material_name: str, environment: str) -> tuple:
    """
    Get failure modes for a material in a given environment.
    Returns a tuple (risk_level, modes_json, recommendation) for cacheability.
    Callers should use get_failure_modes_dict() for the full dict response.
    """
    key = (material_name.lower().strip(), environment.lower().strip())
    modes = FAILURE_MAP.get(key, [])

    if not modes:
        # Partial match: try same material in any environment
        partial_key = next(
            (k for k in FAILURE_MAP if k[0] == material_name.lower().strip()),
            None,
        )
        if partial_key:
            modes = FAILURE_MAP[partial_key]

    if not modes:
        return (
            NO_FAILURE_RESPONSE["risk_level"],
            json.dumps(NO_FAILURE_RESPONSE["failure_modes"]),
            NO_FAILURE_RESPONSE["overall_recommendation"],
        )

    severities = [m["severity"] for m in modes]
    risk_level = "HIGH" if "HIGH" in severities else "MEDIUM" if "MEDIUM" in severities else "LOW"

    recommendation = (
        f"Monitor for {modes[0]['type'].lower()} in {environment} conditions. "
        f"{modes[0]['prevention']}"
    )

    return (risk_level, json.dumps(modes), recommendation)


def get_failure_modes_dict(material_name: str, environment: str) -> dict:
    """Get failure modes as a dict (convenience wrapper around cached tuple)."""
    risk_level, modes_json, recommendation = get_failure_modes(material_name, environment)
    return {
        "risk_level": risk_level,
        "failure_modes": json.loads(modes_json),
        "overall_recommendation": recommendation,
    }
