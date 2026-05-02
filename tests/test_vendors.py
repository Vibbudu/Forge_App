"""Tests for the /api/vendors endpoint."""

import pytest
from unittest.mock import AsyncMock, patch


@pytest.mark.asyncio
async def test_vendor_search_returns_results(client):
    mock_vendors = [
        {
            "name": "Steel World",
            "address": "123 Main St",
            "rating": 4.5,
            "total_ratings": 120,
            "distance_km": 2.3,
            "maps_url": "https://maps.google.com/test",
            "phone": "+91-9876543210",
            "open_now": True,
        }
    ]
    with patch("app.routers.vendors.vendor_service.search_vendors", new_callable=AsyncMock, return_value=mock_vendors):
        response = await client.post("/api/vendors", json={
            "material_name": "316 stainless steel",
            "location": {"lat": 12.9716, "lng": 77.5946},
            "radius_km": 10,
            "min_rating": 4.0,
        })
        assert response.status_code == 200
        data = response.json()
        assert len(data["vendors"]) == 1
        assert data["vendors"][0]["name"] == "Steel World"
        assert data["search_radius_km"] == 10


@pytest.mark.asyncio
async def test_vendor_search_empty_results(client):
    with patch("app.routers.vendors.vendor_service.search_vendors", new_callable=AsyncMock, return_value=[]):
        response = await client.post("/api/vendors", json={
            "material_name": "unobtanium",
            "location": {"lat": 12.9716, "lng": 77.5946},
        })
        assert response.status_code == 200
        data = response.json()
        assert data["vendors"] == []
