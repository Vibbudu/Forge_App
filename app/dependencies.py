from fastapi import Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from app.db.mongo import get_db as _get_db
from app.config import get_settings as _get_settings, Settings


def get_db() -> AsyncIOMotorDatabase:
    """Dependency provider for MongoDB database instance."""
    return _get_db()


def get_settings() -> Settings:
    """Dependency provider for application settings."""
    return _get_settings()
