"""Materials service — MongoDB query, matching, conflict detection, and pricing enrichment."""

from motor.motor_asyncio import AsyncIOMotorDatabase
from app.core.exceptions import DatabaseException, MaterialNotFoundException
from app.data.pricing_map import get_pricing_dict, format_price_display
import logging

logger = logging.getLogger(__name__)


class MaterialsService:
    """Service for querying and processing construction materials from MongoDB."""

    async def query_by_properties(
        self,
        db: AsyncIOMotorDatabase,
        category: str | None,
        properties: dict,
        limit: int = 10,
    ) -> list[dict]:
        """
        Query materials by category, then score and rank by property similarity.

        Previous approach used MongoDB $and filters requiring ALL properties
        to exceed thresholds simultaneously — this eliminated everything
        except stainless steel. New approach: fetch a broad pool by category,
        then sort by best property match in Python.
        """
        try:
            query: dict = {}

            if category and category != "other":
                query["category"] = {"$regex": category, "$options": "i"}

            # Fetch a broad pool of candidates (no property filtering in DB)
            pool_size = max(limit * 2, 20)
            results = await db["materials"].find(query).limit(pool_size).to_list(length=pool_size)

            for r in results:
                r.pop("_id", None)

            # If we have property targets, score and sort by similarity
            if properties and results:
                results = self._score_and_sort(results, properties, limit)
            else:
                results = results[:limit]

            logger.info(f"Materials query returned {len(results)} candidates (category={category})")
            return results

        except Exception as e:
            logger.error(f"Materials DB query failed: {e}")
            raise DatabaseException(f"Material query failed: {str(e)}")

    def _score_and_sort(self, candidates: list[dict], target_props: dict, limit: int) -> list[dict]:
        """
        Score candidates by how closely their properties match the target.
        Uses sum of squared differences (lower = better match).
        """
        scored = []
        for mat in candidates:
            mat_props = mat.get("properties", {})
            score = 0
            matched = 0
            for prop, target_val in target_props.items():
                if not isinstance(target_val, (int, float)):
                    continue
                mat_val = mat_props.get(prop, 5)  # default to midpoint
                if isinstance(mat_val, (int, float)):
                    score += (target_val - mat_val) ** 2
                    matched += 1
            # Normalize: materials with more matching properties rank higher
            avg_score = score / max(matched, 1)
            scored.append((avg_score, mat))

        scored.sort(key=lambda x: x[0])
        return [mat for _, mat in scored[:limit]]

    async def get_by_name(self, db: AsyncIOMotorDatabase, name: str) -> dict:
        """Look up a single material by name (case-insensitive)."""
        try:
            result = await db["materials"].find_one(
                {"name": {"$regex": f"^{name}$", "$options": "i"}}
            )
            if not result:
                raise MaterialNotFoundException(name)
            result.pop("_id", None)
            return result
        except MaterialNotFoundException:
            raise
        except Exception as e:
            raise DatabaseException(f"Material lookup failed: {str(e)}")

    async def get_alternatives(
        self,
        db: AsyncIOMotorDatabase,
        primary_material: dict,
        limit: int = 2,
    ) -> list[dict]:
        """Get alternative materials from the same category."""
        try:
            query = {
                "category": primary_material.get("category"),
                "name": {"$ne": primary_material.get("name")},
            }
            results = await db["materials"].find(query).limit(limit).to_list(length=limit)
            for r in results:
                r.pop("_id", None)
            return results
        except Exception as e:
            logger.error(f"Alternatives query failed: {e}")
            return []

    def enrich_with_pricing(self, material: dict) -> dict:
        """Attach pricing data from the pricing map to a material dict."""
        pricing = get_pricing_dict(material.get("name", ""))
        material["pricing"] = {
            **pricing,
            "price_display": format_price_display(
                pricing["price_per_kg_min"],
                pricing["price_per_kg_max"],
            ),
        }
        return material

    def detect_conflicts(self, advanced_params: dict) -> list[str]:
        """Detect mutually exclusive property requirements."""
        conflicts = []

        if (
            advanced_params.get("malleability", 5) >= 8
            and advanced_params.get("tensile_strength", 5) >= 8
        ):
            conflicts.append(
                "High malleability and high tensile strength are mutually limiting "
                "— no single alloy excels at both"
            )

        if (
            advanced_params.get("density", 5) <= 2
            and advanced_params.get("tensile_strength", 5) >= 9
        ):
            conflicts.append(
                "Ultra-low density and extremely high tensile strength are "
                "difficult to achieve simultaneously"
            )

        if (
            advanced_params.get("corrosion_resistance", 5) >= 9
            and advanced_params.get("malleability", 5) >= 9
        ):
            conflicts.append(
                "Maximum corrosion resistance typically requires alloy compositions "
                "that reduce malleability"
            )

        return conflicts


materials_service = MaterialsService()
