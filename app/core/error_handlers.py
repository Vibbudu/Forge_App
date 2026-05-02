"""Global FastAPI exception handlers for structured JSON error responses."""

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from app.core.exceptions import ForgeBaseException
import logging

logger = logging.getLogger(__name__)


def register_exception_handlers(app: FastAPI) -> None:
    """Register all custom exception handlers on the FastAPI app."""

    @app.exception_handler(ForgeBaseException)
    async def forge_exception_handler(request: Request, exc: ForgeBaseException):
        logger.error(f"ForgeException on {request.url}: {exc.message}")
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "success": False,
                "error": exc.message,
                "error_type": type(exc).__name__,
            },
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception):
        logger.critical(
            f"Unhandled exception on {request.url}: {str(exc)}", exc_info=True
        )
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "error": "An unexpected error occurred. Please try again.",
                "error_type": "InternalServerError",
            },
        )
