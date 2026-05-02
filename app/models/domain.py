"""Internal domain models for inter-service data transfer."""

from dataclasses import dataclass, field


@dataclass
class AnalysisIntent:
    """Structured intent extracted from user input by Gemini."""

    material_category: str
    environment: str
    use_case: str
    property_priorities: list[str] = field(default_factory=list)
    budget_sensitivity: str = "medium"
    inferred_advanced_params: dict = field(default_factory=dict)
    conflict_check: dict = field(default_factory=lambda: {"has_conflicts": False, "conflicts": []})

    @classmethod
    def from_dict(cls, data: dict) -> "AnalysisIntent":
        """Create an AnalysisIntent from a raw dict (e.g. Gemini JSON output)."""
        return cls(
            material_category=data.get("material_category", "other"),
            environment=data.get("environment", "outdoor"),
            use_case=data.get("use_case", "general construction"),
            property_priorities=data.get("property_priorities", []),
            budget_sensitivity=data.get("budget_sensitivity", "medium"),
            inferred_advanced_params=data.get("inferred_advanced_params", {}),
            conflict_check=data.get("conflict_check", {"has_conflicts": False, "conflicts": []}),
        )


@dataclass
class PhotoIdentification:
    """Structured result from Gemini 3 Flash photo analysis."""

    identified_material: str
    confidence: str
    material_category: str
    visible_condition: str
    estimated_grade: str | None = None
    failure_indicators: list[str] = field(default_factory=list)
    recommended_action: str = "inspect_further"
    environment_inference: str = "outdoor"
    additional_observations: str = ""

    @classmethod
    def from_dict(cls, data: dict) -> "PhotoIdentification":
        """Create a PhotoIdentification from a raw dict (e.g. Gemini vision JSON output)."""
        return cls(
            identified_material=data.get("identified_material", "unknown"),
            confidence=data.get("confidence", "LOW"),
            material_category=data.get("material_category", "unknown"),
            visible_condition=data.get("visible_condition", "unknown"),
            estimated_grade=data.get("estimated_grade"),
            failure_indicators=data.get("failure_indicators", []),
            recommended_action=data.get("recommended_action", "inspect_further"),
            environment_inference=data.get("environment_inference", "outdoor"),
            additional_observations=data.get("additional_observations", ""),
        )
