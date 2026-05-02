"""Tests for GeminiService with mocked google-genai async client."""

import pytest
from unittest.mock import MagicMock, patch, AsyncMock
import json


def test_intent_extraction_prompt_has_placeholders():
    """Verify the intent extraction prompt template has the expected placeholder."""
    from app.services.gemini_service import INTENT_EXTRACTION_PROMPT
    assert "{user_input}" in INTENT_EXTRACTION_PROMPT


def test_ranking_prompt_has_placeholders():
    """Verify the ranking prompt template has the expected placeholders."""
    from app.services.gemini_service import RANKING_PROMPT
    assert "{requirements}" in RANKING_PROMPT
    assert "{candidates}" in RANKING_PROMPT


def test_explanation_prompt_has_placeholders():
    """Verify the explanation prompt template has the expected placeholders."""
    from app.services.gemini_service import EXPLANATION_PROMPT
    assert "{material_name}" in EXPLANATION_PROMPT
    assert "{use_case}" in EXPLANATION_PROMPT
    assert "{environment}" in EXPLANATION_PROMPT


def test_photo_analysis_prompt_exists():
    """Verify the photo analysis prompt template exists."""
    from app.services.gemini_service import PHOTO_ANALYSIS_PROMPT
    assert "identified_material" in PHOTO_ANALYSIS_PROMPT
    assert "confidence" in PHOTO_ANALYSIS_PROMPT


@pytest.mark.asyncio
async def test_extract_intent_parses_json():
    """Test that extract_intent correctly parses a JSON response via client.aio."""
    mock_response = MagicMock()
    mock_response.text = json.dumps({
        "material_category": "metal",
        "environment": "outdoor",
        "use_case": "gate",
        "property_priorities": ["tensile_strength"],
        "budget_sensitivity": "medium",
        "inferred_advanced_params": {"tensile_strength": 8},
        "conflict_check": {"has_conflicts": False, "conflicts": []},
    })

    with patch("app.services.gemini_service.genai") as mock_genai:
        mock_client = MagicMock()
        mock_aio = MagicMock()
        mock_aio.models.generate_content = AsyncMock(return_value=mock_response)
        mock_client.aio = mock_aio
        mock_genai.Client.return_value = mock_client

        from app.services.gemini_service import GeminiService
        with patch("app.services.gemini_service.get_settings") as mock_settings:
            mock_settings.return_value = MagicMock(gemini_api_key="test-key")
            service = GeminiService()
            service.client = mock_client

            result = await service.extract_intent("I need a metal gate")
            assert result["material_category"] == "metal"
            assert result["environment"] == "outdoor"


@pytest.mark.asyncio
async def test_model_constant_is_gemini_3_flash():
    """Verify the service uses Gemini 3 Flash model."""
    from app.services.gemini_service import GeminiService
    assert GeminiService.MODEL == "gemini-3-flash-preview"
