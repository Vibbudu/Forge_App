"""
DEPRECATED: Mistral service has been replaced by Gemini 3 Flash vision.

This module is kept as a thin facade for backward compatibility.
All vision calls are now handled by gemini_service.identify_material().
"""

from app.services.gemini_service import gemini_service
from app.core.exceptions import GeminiException
import logging

logger = logging.getLogger(__name__)


class MistralService:
    """
    Deprecated: delegates to GeminiService.identify_material().

    Kept for backward compatibility — any code importing mistral_service
    will transparently use Gemini 3 Flash vision instead.
    """

    async def identify_material(self, base64_image: str) -> dict:
        """Proxy to gemini_service.identify_material()."""
        logger.info("MistralService.identify_material() → delegating to GeminiService")
        return await gemini_service.identify_material(base64_image)


mistral_service = MistralService()
