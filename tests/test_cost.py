"""Tests for pricing_map data functions."""

from app.data.pricing_map import get_pricing_dict, format_price_display


def test_known_material_pricing():
    result = get_pricing_dict("316 stainless steel")
    assert result["price_per_kg_min"] > 0
    assert result["price_per_kg_max"] > result["price_per_kg_min"]
    assert result["tier"] in ["Budget", "Mid-range", "Premium"]
    assert result["currency"] == "INR"


def test_unknown_material_returns_default():
    result = get_pricing_dict("unobtanium alloy x9")
    assert "price_per_kg_min" in result
    assert result["tier"] == "Mid-range"


def test_price_display_format():
    display = format_price_display(320.0, 380.0)
    assert "₹" in display
    assert "320" in display
    assert "380" in display
    assert "/kg" in display


def test_budget_tier_cheaper_than_premium():
    budget = get_pricing_dict("mild steel")
    premium = get_pricing_dict("316 stainless steel")
    assert budget["price_per_kg_max"] < premium["price_per_kg_min"]
