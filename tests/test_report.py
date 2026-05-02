"""Tests for ReportService PDF generation."""

import pytest
from app.services.report_service import report_service


def test_generate_pdf_returns_bytes():
    """Test that generate_pdf returns non-empty bytes."""
    analysis_data = {
        "recommendation": {
            "name": "316 Stainless Steel",
            "explanation": "Best for coastal environments",
            "grade": "Grade 316",
        },
        "alternatives": [
            {"name": "304 SS", "reason": "Cheaper option", "cost_difference": "₹70/kg cheaper"},
        ],
        "standards": {
            "passed": True,
            "details": [
                {"standard": "IS 6911", "status": "PASS", "note": "Meets specification"},
            ],
        },
        "failure": {
            "risk_level": "LOW",
            "failure_modes": [
                {
                    "type": "General Wear",
                    "severity": "LOW",
                    "description": "Normal aging",
                    "prevention": "Regular maintenance",
                },
            ],
        },
        "cost": {
            "comparison": [
                {"name": "316 SS", "price_display": "₹320 - ₹380/kg", "tier": "Premium"},
            ],
        },
        "conflict_warning": {"detected": False, "conflicts": []},
    }

    result = report_service.generate_pdf(analysis_data)
    assert isinstance(result, bytes)
    assert len(result) > 0
    # PDF files start with %PDF
    assert result[:5] == b"%PDF-"


def test_generate_pdf_with_empty_data():
    """Test that generate_pdf handles minimal data without crashing."""
    result = report_service.generate_pdf({
        "recommendation": {"name": "Test Material", "explanation": "Test"},
    })
    assert isinstance(result, bytes)
    assert len(result) > 0


def test_generate_pdf_with_conflicts():
    """Test that conflict warnings appear in the PDF."""
    analysis_data = {
        "recommendation": {"name": "Test", "explanation": "Test"},
        "conflict_warning": {
            "detected": True,
            "conflicts": ["High malleability conflicts with high tensile strength"],
            "resolution": "Best tradeoff selected",
        },
    }
    result = report_service.generate_pdf(analysis_data)
    assert isinstance(result, bytes)
    assert len(result) > 0
