"""Pydantic request models for all API endpoints."""

from pydantic import BaseModel, Field, field_validator
from typing import Literal
from enum import Enum


class InputType(str, Enum):
    TEXT = "text"
    VOICE_TRANSCRIPT = "voice_transcript"
    PHOTO = "photo"
    ADVANCED = "advanced"


class SurfaceFinish(str, Enum):
    GLOSSY = "glossy"
    MATTE = "matte"
    BRUSHED = "brushed"


class Language(str, Enum):
    ENGLISH = "en-IN"
    HINDI = "hi-IN"
    KANNADA = "kn-IN"


class Location(BaseModel):
    lat: float = Field(..., ge=-90, le=90)
    lng: float = Field(..., ge=-180, le=180)


class AdvancedParams(BaseModel):
    tensile_strength: int = Field(5, ge=1, le=10)
    ductility: int = Field(5, ge=1, le=10)
    corrosion_resistance: int = Field(5, ge=1, le=10)
    malleability: int = Field(5, ge=1, le=10)
    thermal_resistance: int = Field(5, ge=1, le=10)
    density: int = Field(5, ge=1, le=10)
    surface_finish: SurfaceFinish = SurfaceFinish.MATTE


class FullAnalysisRequest(BaseModel):
    input_type: InputType
    text: str | None = Field(None, max_length=2000)
    photo_base64: str | None = None
    advanced_params: AdvancedParams | None = None
    location: Location
    language: Language = Language.ENGLISH

    @field_validator("text")
    @classmethod
    def validate_text_input(cls, v, info):
        input_type = info.data.get("input_type")
        if input_type in [InputType.TEXT, InputType.VOICE_TRANSCRIPT] and not v:
            raise ValueError(
                "text field is required for text and voice_transcript input types"
            )
        return v

    @field_validator("photo_base64")
    @classmethod
    def validate_photo_input(cls, v, info):
        input_type = info.data.get("input_type")
        if input_type == InputType.PHOTO and not v:
            raise ValueError("photo_base64 is required for photo input type")
        return v

    @field_validator("advanced_params")
    @classmethod
    def validate_advanced_input(cls, v, info):
        input_type = info.data.get("input_type")
        if input_type == InputType.ADVANCED and not v:
            raise ValueError("advanced_params is required for advanced input type")
        return v


class VendorRequest(BaseModel):
    material_name: str = Field(..., min_length=1, max_length=200)
    location: Location
    radius_km: int = Field(10, ge=1, le=50)
    min_rating: float = Field(3.0, ge=1.0, le=5.0)


class PhotoIdentifyRequest(BaseModel):
    """Request model for standalone photo identification endpoint."""

    photo_base64: str = Field(..., min_length=1)


class ReportRequest(BaseModel):
    """Request model for PDF report generation endpoint."""

    recommendation: dict
    alternatives: list[dict] = []
    standards: dict = {}
    failure: dict = {}
    cost: dict = {}
    vendors: dict = {}
    conflict_warning: dict = {}
