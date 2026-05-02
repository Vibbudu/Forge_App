"""Tests for standards_map data functions."""

from app.data.standards_map import get_standards


def test_known_material_known_environment():
    result = list(get_standards("316 stainless steel", "coastal"))
    assert len(result) > 0
    assert all("standard" in r for r in result)
    assert all("status" in r for r in result)


def test_material_fails_wrong_environment():
    result = list(get_standards("mild steel", "coastal"))
    statuses = [r["status"] for r in result]
    assert "FAIL" in statuses


def test_unknown_material_returns_defaults():
    result = list(get_standards("unobtanium", "outdoor"))
    assert len(result) > 0


def test_standards_structure():
    result = list(get_standards("mild steel", "outdoor"))
    for item in result:
        assert "standard" in item
        assert "status" in item
        assert "note" in item
        assert item["status"] in ["PASS", "FAIL"]
