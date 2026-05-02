"""Tests for the /api/full-analysis endpoint."""

import pytest
from unittest.mock import AsyncMock, patch


@pytest.mark.asyncio
async def test_full_analysis_text_input_success(client, mock_gemini, mock_db):
    with patch("app.routers.analysis.get_db", return_value=mock_db):
        with patch("app.routers.analysis.vendor_service.search_vendors", new_callable=AsyncMock, return_value=[]):
            with patch("app.routers.analysis.bulbul_service.synthesize", new_callable=AsyncMock, return_value="base64audio"):
                response = await client.post("/api/full-analysis", json={
                    "input_type": "text",
                    "text": "I need a metal gate for a coastal area",
                    "location": {"lat": 12.9716, "lng": 77.5946},
                    "language": "en-IN",
                })
                assert response.status_code == 200
                data = response.json()
                assert data["success"] is True
                assert "recommendation" in data
                assert data["recommendation"]["name"] == "316 Stainless Steel"
                assert "standards" in data
                assert "failure" in data
                assert "cost" in data


@pytest.mark.asyncio
async def test_full_analysis_missing_text_raises_422(client):
    response = await client.post("/api/full-analysis", json={
        "input_type": "text",
        "text": None,
        "location": {"lat": 12.9716, "lng": 77.5946},
    })
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_full_analysis_advanced_mode(client, mock_gemini, mock_db):
    with patch("app.routers.analysis.get_db", return_value=mock_db):
        with patch("app.routers.analysis.vendor_service.search_vendors", new_callable=AsyncMock, return_value=[]):
            with patch("app.routers.analysis.bulbul_service.synthesize", new_callable=AsyncMock, return_value=None):
                response = await client.post("/api/full-analysis", json={
                    "input_type": "advanced",
                    "advanced_params": {
                        "tensile_strength": 9, "ductility": 5,
                        "corrosion_resistance": 9, "malleability": 4,
                        "thermal_resistance": 7, "density": 6,
                        "surface_finish": "matte",
                    },
                    "location": {"lat": 12.9716, "lng": 77.5946},
                })
                assert response.status_code == 200


@pytest.mark.asyncio
async def test_conflict_detection_in_advanced_mode(client, mock_gemini, mock_db):
    with patch("app.routers.analysis.get_db", return_value=mock_db):
        with patch("app.routers.analysis.vendor_service.search_vendors", new_callable=AsyncMock, return_value=[]):
            with patch("app.routers.analysis.bulbul_service.synthesize", new_callable=AsyncMock, return_value=None):
                response = await client.post("/api/full-analysis", json={
                    "input_type": "advanced",
                    "advanced_params": {
                        "tensile_strength": 10, "ductility": 5,
                        "corrosion_resistance": 5, "malleability": 10,
                        "thermal_resistance": 5, "density": 5,
                        "surface_finish": "matte",
                    },
                    "location": {"lat": 12.9716, "lng": 77.5946},
                })
                assert response.status_code == 200
                data = response.json()
                assert data["conflict_warning"]["detected"] is True
                assert len(data["conflict_warning"]["conflicts"]) > 0


@pytest.mark.asyncio
async def test_tts_failure_does_not_break_response(client, mock_gemini, mock_db):
    with patch("app.routers.analysis.get_db", return_value=mock_db):
        with patch("app.routers.analysis.vendor_service.search_vendors", new_callable=AsyncMock, return_value=[]):
            with patch("app.routers.analysis.bulbul_service.synthesize", side_effect=Exception("TTS failed")):
                response = await client.post("/api/full-analysis", json={
                    "input_type": "text",
                    "text": "I need material for an outdoor gate",
                    "location": {"lat": 12.9716, "lng": 77.5946},
                })
                assert response.status_code == 200
                data = response.json()
                assert data["tts_audio_base64"] is None


@pytest.mark.asyncio
async def test_vendor_failure_does_not_break_response(client, mock_gemini, mock_db):
    with patch("app.routers.analysis.get_db", return_value=mock_db):
        with patch("app.routers.analysis.vendor_service.search_vendors", side_effect=Exception("Maps API down")):
            with patch("app.routers.analysis.bulbul_service.synthesize", new_callable=AsyncMock, return_value=None):
                response = await client.post("/api/full-analysis", json={
                    "input_type": "text",
                    "text": "I need material for a wall",
                    "location": {"lat": 12.9716, "lng": 77.5946},
                })
                assert response.status_code == 200
                data = response.json()
                assert data["vendors"]["vendors"] == []
