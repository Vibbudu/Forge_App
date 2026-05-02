"""Tests for failure_map data functions."""

from app.data.failure_map import get_failure_modes_dict


def test_high_risk_material_environment():
    result = get_failure_modes_dict("mild steel", "coastal")
    assert result["risk_level"] == "HIGH"
    assert len(result["failure_modes"]) > 0


def test_unknown_combination_returns_default():
    result = get_failure_modes_dict("unobtanium", "space")
    assert "risk_level" in result
    assert result["risk_level"] == "LOW"


def test_failure_mode_structure():
    result = get_failure_modes_dict("mild steel", "coastal")
    for mode in result["failure_modes"]:
        assert "type" in mode
        assert "severity" in mode
        assert "description" in mode
        assert "prevention" in mode
        assert mode["severity"] in ["HIGH", "MEDIUM", "LOW"]


def test_overall_recommendation_present():
    result = get_failure_modes_dict("wood", "outdoor")
    assert "overall_recommendation" in result
    assert len(result["overall_recommendation"]) > 0
