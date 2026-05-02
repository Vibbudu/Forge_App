"""Health check endpoint."""

from fastapi import APIRouter
from app.db.mongo import mongodb

router = APIRouter()


@router.get("/api/health")
async def health():
    """Health check — returns API status, DB connection state, and version."""
    db_status = "connected" if mongodb.db is not None else "disconnected"
    return {
        "status": "healthy",
        "database": db_status,
        "version": "1.0.0",
    }
