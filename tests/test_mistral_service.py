"""Tests for Gemini Vision (photo identification) via GeminiService."""

import pytest
from unittest.mock import MagicMock, patch, AsyncMock
import json


@pytest.mark.asyncio
async def test_identify_material_parses_response():
    """Test that identify_material correctly parses Gemini vision JSON output."""
    mock_content = json.dumps({
        "identified_material": "Mild Steel",
        "confidence": "HIGH",
        "material_category": "metal",
        "visible_condition": "corroded",
        "estimated_grade": None,
        "failure_indicators": ["surface rust", "pitting"],
        "recommended_action": "replace",
        "environment_inference": "outdoor",
        "additional_observations": "Heavily weathered surface",
    })

    mock_response = MagicMock()
    mock_response.text = mock_content

    with patch("app.services.gemini_service.get_settings") as mock_settings:
        mock_settings.return_value = MagicMock(gemini_api_key="test-key")

        with patch("app.services.gemini_service.genai") as mock_genai:
            mock_client = MagicMock()
            mock_aio = MagicMock()
            mock_aio.models.generate_content = AsyncMock(return_value=mock_response)
            mock_client.aio = mock_aio
            mock_genai.Client.return_value = mock_client

            from app.services.gemini_service import GeminiService
            service = GeminiService()
            service.client = mock_client

            result = await service.identify_material("YmFzZTY0aW1hZ2VkYXRh")
            assert result["identified_material"] == "Mild Steel"
            assert result["confidence"] == "HIGH"
            assert result["material_category"] == "metal"
            assert "surface rust" in result["failure_indicators"]


@pytest.mark.asyncio
async def test_identify_material_handles_low_confidence():
    """Test that low confidence results are logged as warnings."""
    mock_content = json.dumps({
        "identified_material": "Unknown Metal",
        "confidence": "LOW",
        "material_category": "unknown",
        "visible_condition": "unknown",
        "estimated_grade": None,
        "failure_indicators": [],
        "recommended_action": "inspect_further",
        "environment_inference": "outdoor",
        "additional_observations": "",
    })

    mock_response = MagicMock()
    mock_response.text = mock_content

    with patch("app.services.gemini_service.get_settings") as mock_settings:
        mock_settings.return_value = MagicMock(gemini_api_key="test-key")

        with patch("app.services.gemini_service.genai") as mock_genai:
            mock_client = MagicMock()
            mock_aio = MagicMock()
            mock_aio.models.generate_content = AsyncMock(return_value=mock_response)
            mock_client.aio = mock_aio
            mock_genai.Client.return_value = mock_client

            from app.services.gemini_service import GeminiService
            service = GeminiService()
            service.client = mock_client

            result = await service.identify_material("YmFzZTY0ZGF0YQ==")
            assert result["confidence"] == "LOW"
            assert result["identified_material"] == "Unknown Metal"
