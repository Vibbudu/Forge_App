"""Materials browsing and filtering endpoint."""

from fastapi import APIRouter, Depends, Query
from motor.motor_asyncio import AsyncIOMotorDatabase
from app.db.mongo import get_db
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/materials")
async def list_materials(
    category: str | None = Query(None, description="Filter by material category"),
    limit: int = Query(20, le=100, description="Max results to return"),
    db: AsyncIOMotorDatabase = Depends(get_db),
):
    """Browse and filter materials from the database."""
    query = {}
    if category:
        query["category"] = {"$regex": category, "$options": "i"}

    results = await db["materials"].find(query).limit(limit).to_list(length=limit)

    for r in results:
        r.pop("_id", None)

    logger.info(f"Materials list: category={category}, returned={len(results)}")
    return {"materials": results, "count": len(results)}
