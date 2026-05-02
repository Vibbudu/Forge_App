"""MongoDB Atlas async connection using Motor."""

from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from app.config import get_settings
from app.core.exceptions import DatabaseException
import logging

logger = logging.getLogger(__name__)


class MongoDB:
    """Singleton container for the Motor client and database reference."""

    client: AsyncIOMotorClient | None = None
    db: AsyncIOMotorDatabase | None = None


mongodb = MongoDB()


async def connect_db() -> None:
    """Connect to MongoDB Atlas on application startup."""
    settings = get_settings()
    try:
        mongodb.client = AsyncIOMotorClient(
            settings.mongodb_uri,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
        )
        # Verify connection is alive
        await mongodb.client.admin.command("ping")
        mongodb.db = mongodb.client[settings.mongodb_db_name]
        logger.info(f"Connected to MongoDB Atlas: {settings.mongodb_db_name}")
    except Exception as e:
        logger.critical(f"Failed to connect to MongoDB: {str(e)}")
        raise DatabaseException(f"Could not connect to database: {str(e)}")


async def disconnect_db() -> None:
    """Close MongoDB connection on application shutdown."""
    if mongodb.client:
        mongodb.client.close()
        logger.info("MongoDB connection closed")


def get_db() -> AsyncIOMotorDatabase:
    """Get the database instance. Raises if not connected."""
    if mongodb.db is None:
        raise DatabaseException("Database not initialized")
    return mongodb.db
