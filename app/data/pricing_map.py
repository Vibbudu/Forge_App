"""
Hardcoded regional pricing data for construction materials (INR/kg).
Cached with lru_cache for zero-cost repeat lookups.
"""

from functools import lru_cache
import json

PRICING_MAP: dict[str, dict] = {
    "316 stainless steel": {
        "price_per_kg_min": 320.0,
        "price_per_kg_max": 380.0,
        "tier": "Premium",
        "currency": "INR",
    },
    "304 stainless steel": {
        "price_per_kg_min": 250.0,
        "price_per_kg_max": 300.0,
        "tier": "Mid-range",
        "currency": "INR",
    },
    "mild steel": {
        "price_per_kg_min": 55.0,
        "price_per_kg_max": 75.0,
        "tier": "Budget",
        "currency": "INR",
    },
    "galvanized steel": {
        "price_per_kg_min": 85.0,
        "price_per_kg_max": 110.0,
        "tier": "Budget",
        "currency": "INR",
    },
    "aluminum alloy 6061": {
        "price_per_kg_min": 180.0,
        "price_per_kg_max": 220.0,
        "tier": "Mid-range",
        "currency": "INR",
    },
    "duplex 2205": {
        "price_per_kg_min": 280.0,
        "price_per_kg_max": 340.0,
        "tier": "Mid-range",
        "currency": "INR",
    },
    "weathering steel": {
        "price_per_kg_min": 85.0,
        "price_per_kg_max": 120.0,
        "tier": "Budget",
        "currency": "INR",
    },
    "teak wood": {
        "price_per_kg_min": 2500.0,
        "price_per_kg_max": 4000.0,
        "tier": "Premium",
        "currency": "INR",
    },
    "cement concrete m25": {
        "price_per_kg_min": 5.5,
        "price_per_kg_max": 7.0,
        "tier": "Budget",
        "currency": "INR",
    },
    "grade 5 titanium": {
        "price_per_kg_min": 2800.0,
        "price_per_kg_max": 3500.0,
        "tier": "Premium",
        "currency": "INR",
    },
}

DEFAULT_PRICING = {
    "price_per_kg_min": 100.0,
    "price_per_kg_max": 200.0,
    "tier": "Mid-range",
    "currency": "INR",
}


@lru_cache(maxsize=256)
def get_pricing(material_name: str) -> tuple:
    """
    Get pricing for a material. Returns a tuple for cacheability.
    Callers should use get_pricing_dict() for the full dict response.
    """
    key = material_name.lower().strip()
    pricing = PRICING_MAP.get(key, DEFAULT_PRICING)
    return (
        pricing["price_per_kg_min"],
        pricing["price_per_kg_max"],
        pricing["tier"],
        pricing["currency"],
    )


def get_pricing_dict(material_name: str) -> dict:
    """Get pricing as a dict (convenience wrapper around cached tuple)."""
    min_price, max_price, tier, currency = get_pricing(material_name)
    return {
        "price_per_kg_min": min_price,
        "price_per_kg_max": max_price,
        "tier": tier,
        "currency": currency,
    }


def format_price_display(min_price: float, max_price: float) -> str:
    """Format price range as a human-readable string."""
    return f"₹{min_price:.0f} - ₹{max_price:.0f}/kg"
