"""
Gemini 3 Flash service — unified AI provider for NLP, vision, and ranking.
Uses the google-genai SDK with client.aio for native async/await.

Responsibilities:
  - Intent extraction from natural language (text/voice)
  - Photo-based material identification (vision)
  - Candidate material ranking
  - Human-readable explanation generation

All methods use client.aio.models.generate_content() to prevent
blocking the FastAPI event loop during high-resolution photo processing.
"""

from google import genai
from google.genai import types
import base64
import json
import logging
from app.config import get_settings
from app.core.exceptions import GeminiException

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Prompt templates
# ---------------------------------------------------------------------------

INTENT_EXTRACTION_PROMPT = """
You are a senior construction materials expert with 30 years of field experience.

Extract structured intent from the user's description and return ONLY a valid JSON object.
No explanation. No markdown. No preamble. Just the JSON.

Required output format:
{{
  "material_category": "metal | wood | paint | concrete | glass | insulation | ceramic | composite | other",
  "use_case": "brief description under 10 words",
  "environment": "indoor | outdoor | coastal | cold | hot | industrial | wet | dry",
  "property_priorities": ["list of properties in order of importance from: tensile_strength, ductility, corrosion_resistance, malleability, thermal_resistance, density, surface_finish"],
  "surface_finish_preference": "glossy | matte | brushed | none",
  "budget_sensitivity": "low | medium | high",
  "structural_load": "light | medium | heavy | none",
  "inferred_advanced_params": {{
    "tensile_strength": 1-10,
    "ductility": 1-10,
    "corrosion_resistance": 1-10,
    "malleability": 1-10,
    "thermal_resistance": 1-10,
    "density": 1-10
  }},
  "conflict_check": {{
    "has_conflicts": true | false,
    "conflicts": ["describe each conflicting pair if any"]
  }}
}}

User input: {user_input}
"""

RANKING_PROMPT = """
You are a construction materials expert. You have been given a list of candidate materials from a database and the user's requirements.

Rank these materials from most to least suitable. Return ONLY a valid JSON array of material names in ranked order.
No explanation. No markdown. Just the JSON array.

User requirements:
{requirements}

Candidate materials:
{candidates}

Return format: ["first_choice", "second_choice", "third_choice"]
"""

EXPLANATION_PROMPT = """
You are a construction materials expert explaining a recommendation to a {experience_level} user.

Analyze the material: {material_name} for the use case: {use_case} in {environment} conditions.

Return ONLY a valid JSON object containing:
1. A clear, practical explanation (2-3 sentences) for why it is the best choice. Mention a key property. Do not use excessive jargon.
2. Estimated physical properties for this material on a 1-10 scale.

Return format:
{{
  "explanation": "your explanation here",
  "properties": {{
    "tensile_strength": 1-10,
    "ductility": 1-10,
    "corrosion_resistance": 1-10,
    "malleability": 1-10,
    "thermal_resistance": 1-10,
    "density": 1-10,
    "surface_finish": "matte | glossy | brushed"
  }}
}}
No explanation. No markdown. Just the JSON.
"""

PHOTO_ANALYSIS_PROMPT = """
You are a construction materials expert with deep knowledge of visual material identification.

Analyze this image and return ONLY a valid JSON object. No explanation. No markdown.

{
  "identified_material": "specific material name",
  "confidence": "HIGH | MEDIUM | LOW",
  "material_category": "metal | wood | paint | concrete | glass | insulation | ceramic | composite | unknown",
  "visible_condition": "excellent | good | fair | damaged | corroded | cracked | weathered | severely_degraded",
  "estimated_grade": "grade if identifiable, null if unknown",
  "failure_indicators": ["list visible failure signs, empty array if none"],
  "recommended_action": "replace | inspect_further | maintain | no_action_needed",
  "environment_inference": "what environment this material appears to be used in",
  "additional_observations": "any other relevant observations under 20 words"
}
"""

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def _parse_json_response(raw: str) -> dict | list:
    """Strip markdown fences and parse JSON from Gemini's raw text output."""
    cleaned = raw.strip().replace("```json", "").replace("```", "").strip()
    return json.loads(cleaned)


def _detect_image_mime(image_bytes: bytes) -> str:
    """Detect image MIME type from magic bytes. Falls back to jpeg."""
    if image_bytes[:8] == b'\x89PNG\r\n\x1a\n':
        return "image/png"
    if image_bytes[:4] == b'RIFF' and image_bytes[8:12] == b'WEBP':
        return "image/webp"
    if image_bytes[:3] == b'GIF':
        return "image/gif"
    return "image/jpeg"


# ---------------------------------------------------------------------------
# Service
# ---------------------------------------------------------------------------

class GeminiService:
    """
    Unified Gemini 3 Flash service — NLP, vision, ranking, and explanation.

    Uses client.aio for native async. Every public method is a coroutine
    so FastAPI never blocks on Gemini calls, even for high-res image uploads.
    """

    MODEL = "gemini-3-flash-preview"

    def __init__(self):
        settings = get_settings()
        self.client = genai.Client(api_key=settings.gemini_api_key)

    # ---- NLP: intent extraction ----

    async def extract_intent(self, user_input: str) -> dict:
        """Extract structured intent from natural language user input."""
        try:
            prompt = INTENT_EXTRACTION_PROMPT.format(user_input=user_input)
            response = await self.client.aio.models.generate_content(
                model=self.MODEL,
                contents=prompt,
            )
            return _parse_json_response(response.text)
        except json.JSONDecodeError as e:
            logger.error(f"Gemini returned invalid JSON: {e}")
            raise GeminiException(f"Invalid JSON response from intent extraction: {str(e)}")
        except Exception as e:
            logger.error(f"Gemini intent extraction failed: {e}")
            raise GeminiException(str(e))

    # ---- Vision: photo identification ----

    async def identify_material(self, base64_image: str) -> dict:
        """
        Identify a construction material from a base64-encoded photo.

        Uses Gemini 3 Flash's native multimodal vision — sends the image as
        inline bytes alongside the analysis prompt via client.aio for
        non-blocking async processing of high-resolution photos.
        """
        try:
            image_bytes = base64.b64decode(base64_image)

            # Auto-detect MIME type from magic bytes instead of hardcoding jpeg
            mime_type = _detect_image_mime(image_bytes)

            response = await self.client.aio.models.generate_content(
                model=self.MODEL,
                contents=[
                    types.Part.from_bytes(data=image_bytes, mime_type=mime_type),
                    PHOTO_ANALYSIS_PROMPT,
                ],
            )

            result = _parse_json_response(response.text)

            if result.get("confidence") == "LOW":
                logger.warning(
                    f"Low confidence material identification: "
                    f"{result.get('identified_material')}"
                )

            return result

        except json.JSONDecodeError as e:
            logger.error(f"Gemini vision returned invalid JSON: {e}")
            raise GeminiException(f"Invalid JSON from photo analysis: {str(e)}")
        except Exception as e:
            logger.error(f"Gemini photo identification failed: {e}")
            raise GeminiException(str(e))

    # ---- Ranking ----

    async def rank_candidates(self, requirements: dict, candidates: list[dict]) -> list[str]:
        """Rank candidate materials by suitability. Returns ordered list of names."""
        try:
            candidate_summary = [
                {
                    "name": c["name"],
                    "category": c["category"],
                    "properties": c.get("properties", {}),
                }
                for c in candidates
            ]
            prompt = RANKING_PROMPT.format(
                requirements=json.dumps(requirements, indent=2),
                candidates=json.dumps(candidate_summary, indent=2),
            )
            response = await self.client.aio.models.generate_content(
                model=self.MODEL,
                contents=prompt,
            )
            return _parse_json_response(response.text)
        except json.JSONDecodeError as e:
            logger.error(f"Gemini ranking returned invalid JSON: {e}")
            raise GeminiException(f"Invalid JSON from ranking: {str(e)}")
        except Exception as e:
            logger.error(f"Gemini ranking failed: {e}")
            raise GeminiException(str(e))

    # ---- Explanation ----

    async def generate_explanation(
        self,
        material_name: str,
        use_case: str,
        environment: str,
        experience_level: str = "professional",
    ) -> dict:
        """Generate a human-readable explanation and estimate properties for a material recommendation."""
        try:
            prompt = EXPLANATION_PROMPT.format(
                material_name=material_name,
                use_case=use_case,
                environment=environment,
                experience_level=experience_level,
            )
            response = await self.client.aio.models.generate_content(
                model=self.MODEL,
                contents=prompt,
            )
            return _parse_json_response(response.text)
        except json.JSONDecodeError as e:
            logger.error(f"Gemini explanation returned invalid JSON: {e}")
            raise GeminiException(f"Invalid JSON from explanation: {str(e)}")
        except Exception as e:
            logger.error(f"Gemini explanation generation failed: {e}")
            raise GeminiException(str(e))


gemini_service = GeminiService()
