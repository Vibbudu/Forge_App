"""Pytest fixtures for Forge backend tests."""

import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock, MagicMock, patch


def _make_mock_db():
    """Create a reusable mock database with materials collection."""
    db = MagicMock()

    # Mock find() cursor chain
    mock_cursor = MagicMock()
    mock_cursor.limit.return_value = mock_cursor
    mock_cursor.to_list = AsyncMock(return_value=[
        {
            "name": "316 Stainless Steel",
            "category": "metal",
            "composition": {"Fe": 68.0, "Cr": 18.0, "Ni": 10.0, "Mo": 3.0},
            "properties": {
                "tensile_strength": 9,
                "ductility": 6,
                "corrosion_resistance": 9,
                "malleability": 5,
                "thermal_resistance": 7,
                "density": 6,
                "surface_finish": "matte",
            },
            "grade": "Grade 316",
        }
    ])
    db["materials"].find.return_value = mock_cursor

    db["materials"].find_one = AsyncMock(return_value={
        "name": "316 Stainless Steel",
        "category": "metal",
    })
    return db


@pytest.fixture(autouse=True)
def mock_db_connection():
    """
    Mock the entire database layer globally for every test.
    
    This patches three things simultaneously:
    1. connect_db / disconnect_db — prevents the FastAPI lifespan from hitting real Mongo.
    2. mongodb.db singleton — prevents get_db() from raising 'Database not initialized'.
    3. get_db itself — returns a mock DB for FastAPI Depends() injection.
    """
    fake_db = _make_mock_db()

    with patch("app.main.connect_db", new_callable=AsyncMock):
        with patch("app.main.disconnect_db", new_callable=AsyncMock):
            with patch("app.db.mongo.mongodb") as mock_mongodb:
                mock_mongodb.db = fake_db
                mock_mongodb.client = MagicMock()
                with patch("app.db.mongo.get_db", return_value=fake_db):
                    yield fake_db


@pytest.fixture
def mock_db():
    """Explicit mock DB fixture for tests that need direct access."""
    return _make_mock_db()


@pytest.fixture
def mock_gemini():
    """Mock Gemini service with preset responses."""
    with patch("app.routers.analysis.gemini_service") as mock:
        mock.extract_intent = AsyncMock(return_value={
            "material_category": "metal",
            "environment": "coastal",
            "use_case": "outdoor gate",
            "property_priorities": ["corrosion_resistance", "tensile_strength"],
            "budget_sensitivity": "medium",
            "inferred_advanced_params": {
                "tensile_strength": 8,
                "ductility": 6,
                "corrosion_resistance": 9,
                "malleability": 5,
                "thermal_resistance": 7,
                "density": 6,
            },
            "conflict_check": {"has_conflicts": False, "conflicts": []},
        })
        mock.rank_candidates = AsyncMock(return_value=["316 Stainless Steel"])
        mock.generate_explanation = AsyncMock(
            return_value={
                "explanation": "316 Stainless Steel performs well in coastal environments due to its molybdenum content.",
                "properties": {
                    "tensile_strength": 9,
                    "ductility": 6,
                    "corrosion_resistance": 9,
                    "malleability": 5,
                    "thermal_resistance": 7,
                    "density": 6,
                    "surface_finish": "matte"
                }
            }
        )
        yield mock


@pytest.fixture
async def client():
    """Async HTTP test client using HTTPX + ASGITransport."""
    from app.main import app

    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac

