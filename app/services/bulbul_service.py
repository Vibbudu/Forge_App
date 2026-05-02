"""Sarvam Bulbul TTS service — text-to-speech in en-IN, hi-IN, kn-IN."""

import httpx
import logging
from app.config import get_settings
from app.core.exceptions import BulbulException

logger = logging.getLogger(__name__)

SARVAM_TTS_URL = "https://api.sarvam.ai/text-to-speech"


class BulbulService:
    """Service for Sarvam Bulbul text-to-speech synthesis."""

    def __init__(self):
        self.settings = get_settings()

    def build_summary(
        self,
        material_name: str,
        explanation: str,
        risk_level: str,
        language: str,
    ) -> str:
        """Build a TTS-friendly summary in the requested language."""
        if language == "kn-IN":
            return (
                f"ಶಿಫಾರಸು ಮಾಡಲಾದ ವಸ್ತು: {material_name}. "
                f"{explanation}. "
                f"ಅಪಾಯದ ಮಟ್ಟ: {risk_level}."
            )
        elif language == "hi-IN":
            return (
                f"अनुशंसित सामग्री: {material_name}. "
                f"{explanation}. "
                f"जोखिम स्तर: {risk_level}."
            )
        else:
            return (
                f"Recommended material: {material_name}. "
                f"{explanation}. "
                f"Risk level: {risk_level}."
            )

    async def synthesize(self, text: str, language: str = "en-IN") -> str:
        """
        Synthesize text to speech via Sarvam Bulbul API.
        Returns base64-encoded audio string.
        """
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    SARVAM_TTS_URL,
                    headers={
                        "api-subscription-key": self.settings.sarvam_api_key,
                        "Content-Type": "application/json",
                    },
                    json={
                        "inputs": [text],
                        "target_language_code": language,
                        "speaker": "arya",
                        "pitch": 0,
                        "pace": 1.0,
                        "loudness": 1.5,
                        "enable_preprocessing": True,
                        "model": "bulbul:v3",
                    },
                )

                if response.status_code != 200:
                    raise BulbulException(
                        f"Sarvam API returned {response.status_code}: {response.text}"
                    )

                data = response.json()
                audios = data.get("audios", [])
                if not audios:
                    raise BulbulException("No audio returned from Sarvam API")

                return audios[0]

        except httpx.TimeoutException:
            logger.error("Sarvam Bulbul TTS request timed out")
            raise BulbulException("TTS request timed out")
        except BulbulException:
            raise
        except Exception as e:
            logger.error(f"Bulbul synthesis failed: {e}")
            raise BulbulException(str(e))


bulbul_service = BulbulService()
