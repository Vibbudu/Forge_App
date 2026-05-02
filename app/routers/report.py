"""PDF report generation endpoint."""

from fastapi import APIRouter
from fastapi.responses import Response
from app.models.requests import ReportRequest
from app.services.report_service import report_service
from app.core.exceptions import ReportGenerationException
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/report/generate")
async def generate_report(body: ReportRequest):
    """Generate a PDF analysis report from analysis data."""
    try:
        analysis_data = body.model_dump()
        pdf_bytes = report_service.generate_pdf(analysis_data)

        logger.info(f"Report generated: {len(pdf_bytes)} bytes")

        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={
                "Content-Disposition": "attachment; filename=forge_report.pdf"
            },
        )
    except Exception as e:
        logger.error(f"Report generation failed: {e}")
        raise ReportGenerationException(str(e))
