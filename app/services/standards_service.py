"""Standards service — wrapper around standards_map for service-layer consistency."""

from app.data.standards_map import get_standards
import logging

logger = logging.getLogger(__name__)


class StandardsService:
    """Service for checking IS/ASTM/ISO standards compliance."""

    def check_standards(self, material_name: str, environment: str) -> dict:
        """
        Check standards compliance for a material in a given environment.
        Returns structured result with pass/fail status and details.
        """
        standards = list(get_standards(material_name, environment))

        passed = all(s["status"] == "PASS" for s in standards)
        standards_checked = [s["standard"] for s in standards]

        logger.info(
            f"Standards check for '{material_name}' in '{environment}': "
            f"{'PASSED' if passed else 'FAILED'} ({len(standards)} standards)"
        )

        return {
            "passed": passed,
            "standards_checked": standards_checked,
            "details": standards,
        }


standards_service = StandardsService()
