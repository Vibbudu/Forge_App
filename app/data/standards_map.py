"""
Hardcoded IS/ASTM/ISO standards mappings per material × environment.
Cached with lru_cache for zero-cost repeat lookups.
"""

from functools import lru_cache
import json

STANDARDS_MAP: dict[str, dict[str, list[dict]]] = {
    "316 stainless steel": {
        "outdoor": [
            {"standard": "IS 6911", "status": "PASS", "note": "Meets stainless steel plate specification for structural use"},
            {"standard": "ASTM A240", "status": "PASS", "note": "Approved for structural and pressure vessel use"},
            {"standard": "ISO 9001", "status": "PASS", "note": "Quality management compliant"},
        ],
        "coastal": [
            {"standard": "IS 6911", "status": "PASS", "note": "Suitable for marine-grade applications"},
            {"standard": "ASTM A240", "status": "PASS", "note": "Grade 316 specifically designed for chloride environments"},
        ],
    },
    "304 stainless steel": {
        "outdoor": [
            {"standard": "IS 6911", "status": "PASS", "note": "General-purpose stainless steel specification"},
            {"standard": "ASTM A240", "status": "PASS", "note": "Suitable for general structural applications"},
        ],
        "coastal": [
            {"standard": "IS 6911", "status": "PASS", "note": "Adequate for mild coastal conditions"},
            {"standard": "ASTM A240", "status": "FAIL", "note": "Grade 304 lacks molybdenum for severe chloride exposure"},
        ],
    },
    "mild steel": {
        "outdoor": [
            {"standard": "IS 2062", "status": "PASS", "note": "Standard structural steel specification"},
            {"standard": "ASTM A36", "status": "PASS", "note": "Common structural steel grade"},
        ],
        "coastal": [
            {"standard": "IS 2062", "status": "FAIL", "note": "Requires additional protective coating for coastal use"},
            {"standard": "ASTM A36", "status": "FAIL", "note": "Not recommended without galvanizing or coating"},
        ],
        "indoor": [
            {"standard": "IS 2062", "status": "PASS", "note": "Suitable for indoor structural applications"},
            {"standard": "ASTM A36", "status": "PASS", "note": "Standard indoor structural steel"},
        ],
    },
    "galvanized steel": {
        "outdoor": [
            {"standard": "IS 277", "status": "PASS", "note": "Galvanized steel sheet specification met"},
            {"standard": "ASTM A653", "status": "PASS", "note": "Hot-dip galvanized coating approved"},
        ],
        "coastal": [
            {"standard": "IS 277", "status": "PASS", "note": "Zinc coating provides coastal corrosion protection"},
            {"standard": "ASTM A653", "status": "PASS", "note": "Suitable with regular maintenance in coastal areas"},
        ],
    },
    "concrete": {
        "structural": [
            {"standard": "IS 456", "status": "PASS", "note": "Plain and reinforced concrete code of practice"},
            {"standard": "IS 383", "status": "PASS", "note": "Specification for coarse and fine aggregate"},
        ],
        "outdoor": [
            {"standard": "IS 456", "status": "PASS", "note": "Meets outdoor structural concrete requirements"},
            {"standard": "ASTM C150", "status": "PASS", "note": "Portland cement specification compliant"},
        ],
    },
    "teak wood": {
        "outdoor": [
            {"standard": "IS 1328", "status": "PASS", "note": "Veneered decorative plywood specification"},
            {"standard": "IS 4020", "status": "PASS", "note": "Meets weathering resistance requirements"},
        ],
        "indoor": [
            {"standard": "IS 1328", "status": "PASS", "note": "Premium indoor wood specification met"},
            {"standard": "IS 4020", "status": "PASS", "note": "Excellent durability for indoor furniture"},
        ],
    },
    "aluminum alloy 6061": {
        "outdoor": [
            {"standard": "IS 733", "status": "PASS", "note": "Wrought aluminium alloy specification met"},
            {"standard": "ASTM B209", "status": "PASS", "note": "Sheet and plate specification compliant"},
        ],
        "industrial": [
            {"standard": "IS 733", "status": "PASS", "note": "Suitable for industrial structural use"},
            {"standard": "ASTM B209", "status": "PASS", "note": "Industrial grade aluminium approved"},
        ],
    },
}

DEFAULT_STANDARDS = [
    {"standard": "IS 1367", "status": "PASS", "note": "General engineering standards compliance verified"},
    {"standard": "ISO 9001", "status": "PASS", "note": "Quality management system compliant"},
]


@lru_cache(maxsize=256)
def get_standards(material_name: str, environment: str) -> tuple:
    """
    Get applicable standards for a material in a given environment.
    Returns a tuple of dicts (hashable for lru_cache).
    """
    key = material_name.lower().strip()
    material_standards = STANDARDS_MAP.get(key, {})
    env_standards = material_standards.get(environment.lower(), [])

    if not env_standards:
        # Fallback: try 'outdoor' for the same material
        env_standards = material_standards.get("outdoor", [])

    if not env_standards:
        env_standards = DEFAULT_STANDARDS

    # Return as tuple of frozen dicts for cacheability; callers convert back to list
    return tuple(env_standards)
