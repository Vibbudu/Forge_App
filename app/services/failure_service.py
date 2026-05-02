"""Failure service — wrapper around failure_map for service-layer consistency."""

from app.data.failure_map import get_failure_modes_dict
import logging

logger = logging.getLogger(__name__)


class FailureService:
    """Service for failure mode detection and risk assessment."""

    def analyze_failures(self, material_name: str, environment: str) -> dict:
        """
        Analyze potential failure modes for a material in a given environment.
        Returns risk level, failure modes, and recommendation.
        """
        result = get_failure_modes_dict(material_name, environment)

        logger.info(
            f"Failure analysis for '{material_name}' in '{environment}': "
            f"risk_level={result['risk_level']}, modes={len(result['failure_modes'])}"
        )

        return result


failure_service = FailureService()
