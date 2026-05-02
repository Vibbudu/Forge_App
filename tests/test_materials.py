"""Tests for the /api/materials endpoint."""

import pytest
from unittest.mock import AsyncMock, MagicMock
from app.db.mongo import get_db
from app.main import app


@pytest.mark.asyncio
async def test_list_materials_returns_results(client):
    mock_db = MagicMock()
    mock_cursor = MagicMock()
    mock_cursor.limit.return_value = mock_cursor
    mock_cursor.to_list = AsyncMock(return_value=[
        {"name": "Mild Steel", "category": "metal", "_id": "abc123"},
        {"name": "Teak Wood", "category": "wood", "_id": "def456"},
    ])
    mock_db["materials"].find.return_value = mock_cursor

    app.dependency_overrides[get_db] = lambda: mock_db
    try:
        response = await client.get("/api/materials")
        assert response.status_code == 200
        data = response.json()
        assert "materials" in data
        assert data["count"] == 2
    finally:
        app.dependency_overrides.pop(get_db, None)


@pytest.mark.asyncio
async def test_list_materials_with_category_filter(client):
    mock_db = MagicMock()
    mock_cursor = MagicMock()
    mock_cursor.limit.return_value = mock_cursor
    mock_cursor.to_list = AsyncMock(return_value=[
        {"name": "Mild Steel", "category": "metal"},
    ])
    mock_db["materials"].find.return_value = mock_cursor

    app.dependency_overrides[get_db] = lambda: mock_db
    try:
        response = await client.get("/api/materials?category=metal")
        assert response.status_code == 200
        data = response.json()
        assert data["count"] == 1
    finally:
        app.dependency_overrides.pop(get_db, None)


@pytest.mark.asyncio
async def test_list_materials_empty_collection(client):
    mock_db = MagicMock()
    mock_cursor = MagicMock()
    mock_cursor.limit.return_value = mock_cursor
    mock_cursor.to_list = AsyncMock(return_value=[])
    mock_db["materials"].find.return_value = mock_cursor

    app.dependency_overrides[get_db] = lambda: mock_db
    try:
        response = await client.get("/api/materials")
        assert response.status_code == 200
        data = response.json()
        assert data["count"] == 0
        assert data["materials"] == []
    finally:
        app.dependency_overrides.pop(get_db, None)

