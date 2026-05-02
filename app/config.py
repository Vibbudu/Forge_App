from pydantic_settings import BaseSettings
from pydantic import field_validator
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    gemini_api_key: str
    sarvam_api_key: str
    google_maps_api_key: str
    mongodb_uri: str
    mongodb_db_name: str = "forge"
    environment: str = "development"
    log_level: str = "INFO"
    allowed_origins: str | list[str] = ["http://localhost:3000"]

    @field_validator("allowed_origins", mode="before")
    @classmethod
    def parse_origins(cls, v):
        """Parse comma-separated origins string from .env into a list."""
        if isinstance(v, str):
            return [o.strip() for o in v.split(",")]
        return v

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    """Cached settings singleton. Raises clear error if required env vars are missing."""
    return Settings()
