"""Forge API — FastAPI application entry point."""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.config import get_settings
from app.db.mongo import connect_db, disconnect_db
from app.core.error_handlers import register_exception_handlers
from app.core.logging import setup_logging
from app.core.limiter import limiter
from app.routers import analysis, materials, vendors, report, health


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan: setup logging and DB on startup, disconnect on shutdown."""
    setup_logging()
    await connect_db()
    yield
    await disconnect_db()


def create_app() -> FastAPI:
    """Factory function to create and configure the FastAPI application."""
    settings = get_settings()

    app = FastAPI(
        title="Forge API",
        version="1.0.0",
        description="Construction materials intelligence platform",
        lifespan=lifespan,
        docs_url="/docs" if settings.environment == "development" else None,
        redoc_url=None,
    )

    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Rate limiting
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

    # Custom exception handlers
    register_exception_handlers(app)

    # Register routers
    app.include_router(health.router, tags=["health"])
    app.include_router(analysis.router, prefix="/api", tags=["analysis"])
    app.include_router(materials.router, prefix="/api", tags=["materials"])
    app.include_router(vendors.router, prefix="/api", tags=["vendors"])
    app.include_router(report.router, prefix="/api", tags=["report"])

    return app


app = create_app()
