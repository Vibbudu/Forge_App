"""Cost service — wrapper around pricing_map for service-layer consistency."""

from app.data.pricing_map import get_pricing_dict, format_price_display
import logging

logger = logging.getLogger(__name__)


class CostService:
    """Service for cost comparison and pricing lookups."""

    def get_cost_comparison(self, materials: list[dict]) -> list[dict]:
        """
        Build cost comparison entries for a list of materials.
        Each entry includes name, price range, display string, tier, and currency.
        """
        entries = []
        for mat in materials:
            pricing = get_pricing_dict(mat.get("name", ""))
            entries.append({
                "name": mat["name"],
                "price_per_kg_min": pricing["price_per_kg_min"],
                "price_per_kg_max": pricing["price_per_kg_max"],
                "price_display": format_price_display(
                    pricing["price_per_kg_min"],
                    pricing["price_per_kg_max"],
                ),
                "tier": pricing["tier"],
                "currency": pricing["currency"],
            })

        logger.info(f"Cost comparison built for {len(entries)} materials")
        return entries

    def get_price_difference(
        self, primary_name: str, alternative_name: str
    ) -> str:
        """Get a human-readable price difference string between two materials."""
        primary = get_pricing_dict(primary_name)
        alternative = get_pricing_dict(alternative_name)
        diff = alternative["price_per_kg_min"] - primary["price_per_kg_min"]
        return f"₹{abs(diff):.0f}/kg {'cheaper' if diff < 0 else 'more expensive'}"


cost_service = CostService()
