"""Vendor service — Google Maps Places API for nearby material suppliers."""

import httpx
import logging
import math
from app.config import get_settings
from app.core.exceptions import VendorServiceException

logger = logging.getLogger(__name__)

PLACES_NEARBY_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
PLACES_DETAILS_URL = "https://maps.googleapis.com/maps/api/place/details/json"


class VendorService:
    def __init__(self):
        self.settings = get_settings()

    def _haversine_distance(self, lat1, lng1, lat2, lng2):
        R = 6371
        dlat = math.radians(lat2 - lat1)
        dlng = math.radians(lng2 - lng1)
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng/2)**2
        return R * 2 * math.asin(math.sqrt(a))

    async def _get_place_phone(self, place_id: str) -> str | None:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(PLACES_DETAILS_URL, params={
                    "place_id": place_id, "fields": "formatted_phone_number",
                    "key": self.settings.google_maps_api_key,
                })
                return response.json().get("result", {}).get("formatted_phone_number")
        except Exception:
            return None

    async def search_vendors(self, material_name: str, lat: float, lng: float, radius_km: int = 10, min_rating: float = 4.0) -> list[dict]:
        try:
            queries = [f"{material_name} supplier", f"{material_name} dealer"]
            all_results, seen_ids = [], set()

            async with httpx.AsyncClient(timeout=15.0) as client:
                for query in queries:
                    resp = await client.get(PLACES_NEARBY_URL, params={
                        "location": f"{lat},{lng}", "radius": radius_km * 1000,
                        "keyword": query, "key": self.settings.google_maps_api_key,
                    })
                    if resp.status_code != 200:
                        continue
                    for place in resp.json().get("results", []):
                        pid = place.get("place_id")
                        if pid in seen_ids:
                            continue
                        seen_ids.add(pid)
                        rating = place.get("rating", 0)
                        if rating < min_rating:
                            continue
                        plat = place["geometry"]["location"]["lat"]
                        plng = place["geometry"]["location"]["lng"]
                        all_results.append({
                            "name": place.get("name", "Unknown"),
                            "address": place.get("vicinity", "Address unavailable"),
                            "rating": rating,
                            "total_ratings": place.get("user_ratings_total", 0),
                            "distance_km": round(self._haversine_distance(lat, lng, plat, plng), 1),
                            "maps_url": f"https://www.google.com/maps/place/?q=place_id:{pid}",
                            "phone": None,
                            "open_now": place.get("opening_hours", {}).get("open_now"),
                            "place_id": pid,
                        })

            all_results.sort(key=lambda x: (-x["rating"], x["distance_km"]))
            top = all_results[:5]
            if top:
                phone = await self._get_place_phone(top[0]["place_id"])
                if phone:
                    top[0]["phone"] = phone
            for r in top:
                r.pop("place_id", None)
            return top
        except httpx.TimeoutException:
            logger.error("Google Maps API timed out")
            raise VendorServiceException("Vendor search timed out")
        except Exception as e:
            logger.error(f"Vendor search failed: {e}")
            raise VendorServiceException(str(e))


vendor_service = VendorService()
