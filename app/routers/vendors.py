"""Vendor search endpoint."""

from fastapi import APIRouter
from app.models.requests import VendorRequest
from app.services.vendor_service import vendor_service
from app.models.responses import VendorResult, Vendor
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/vendors", response_model=VendorResult)
async def search_vendors(body: VendorRequest):
    """Search for nearby material vendors via Google Maps Places API."""
    logger.info(f"Vendor search: material={body.material_name}, radius={body.radius_km}km")

    raw_vendors = await vendor_service.search_vendors(
        material_name=body.material_name,
        lat=body.location.lat,
        lng=body.location.lng,
        radius_km=body.radius_km,
        min_rating=body.min_rating,
    )

    return VendorResult(
        vendors=[Vendor(**v) for v in raw_vendors],
        search_radius_km=body.radius_km,
    )
