"""
Custom exception hierarchy for Forge.
Every service raises typed exceptions — no bare Exception raises anywhere.
"""


class ForgeBaseException(Exception):
    """Base exception for all Forge-specific errors."""

    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(message)


class MaterialNotFoundException(ForgeBaseException):
    """Raised when a material is not found in the database."""

    def __init__(self, material_name: str):
        super().__init__(f"Material not found: {material_name}", 404)


class AIServiceException(ForgeBaseException):
    """Base exception for AI service failures (Gemini, Bulbul)."""

    def __init__(self, service: str, detail: str):
        super().__init__(f"{service} service error: {detail}", 502)


class GeminiException(AIServiceException):
    """Raised when Gemini API call fails."""

    def __init__(self, detail: str):
        super().__init__("Gemini", detail)


class VisionException(AIServiceException):
    """Raised when Gemini vision (photo identification) fails."""

    def __init__(self, detail: str):
        super().__init__("Gemini Vision", detail)


class BulbulException(AIServiceException):
    """Raised when Sarvam Bulbul TTS API call fails."""

    def __init__(self, detail: str):
        super().__init__("Sarvam Bulbul", detail)


class VendorServiceException(ForgeBaseException):
    """Raised when Google Maps Places API call fails."""

    def __init__(self, detail: str):
        super().__init__(f"Vendor service error: {detail}", 502)


class DatabaseException(ForgeBaseException):
    """Raised when MongoDB operations fail."""

    def __init__(self, detail: str):
        super().__init__(f"Database error: {detail}", 503)


class InvalidInputException(ForgeBaseException):
    """Raised when user input is invalid or cannot be processed."""

    def __init__(self, detail: str):
        super().__init__(f"Invalid input: {detail}", 422)


class ReportGenerationException(ForgeBaseException):
    """Raised when PDF report generation fails."""

    def __init__(self, detail: str):
        super().__init__(f"Report generation failed: {detail}", 500)


class ConflictingRequirementsException(ForgeBaseException):
    """Raised when user requirements have mutually exclusive properties."""

    def __init__(self, conflicts: list[str]):
        self.conflicts = conflicts
        super().__init__(
            f"Conflicting requirements detected: {', '.join(conflicts)}", 200
        )
