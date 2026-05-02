# Forge — Frontend API Contract
> **BASE URL:** `https://forgeapp-production-e708.up.railway.app`
> **Status:** Live on Railway

This document contains all the necessary information for the Flutter frontend (and your AI coding agent) to connect to the live Forge backend.

---

## 1. Primary Endpoint: Full Analysis Pipeline
This is the core endpoint. The frontend should call this for almost all user interactions (Text, Voice, Photo, or Sliders). It handles intent extraction, MongoDB querying, vendor searching, standards matching, and text-to-speech in one single call.

* **Method:** `POST`
* **URL:** `https://forgeapp-production-e708.up.railway.app/api/full-analysis`
* **Headers:** `Content-Type: application/json`

### Request Payload (`FullAnalysisRequest` in Dart)
```json
{
  "input_type": "text | voice_transcript | photo | advanced",
  "text": "I need material for an outdoor gate in a coastal area", 
  "photo_base64": null,
  "advanced_params": {
    "tensile_strength": 8,
    "ductility": 5,
    "corrosion_resistance": 9,
    "malleability": 4,
    "thermal_resistance": 6,
    "density": 5,
    "surface_finish": "matte"
  },
  "location": {
    "lat": 12.9716,
    "lng": 77.5946
  },
  "language": "en-IN | hi-IN | kn-IN"
}
```
*Note: `text` can be `null` if using `photo` or `advanced` mode. `advanced_params` can be `null` unless in `advanced` mode.*

### Response Payload (`FullAnalysisResponse` in Dart)
The AI should generate Dart models (`fromJson` / `toJson`) matching this exact structure:
```json
{
  "success": true,
  "recommendation": {
    "name": "316 Stainless Steel",
    "category": "metal",
    "explanation": "Performs well in coastal conditions due to molybdenum content.",
    "composition": { "Fe": 68.0, "Cr": 18.0, "Ni": 10.0, "Mo": 3.0 },
    "properties": {
      "tensile_strength": 9,
      "ductility": 6,
      "corrosion_resistance": 9,
      "malleability": 5,
      "thermal_resistance": 7,
      "density": 6,
      "surface_finish": "matte"
    },
    "grade": "Grade 316"
  },
  "alternatives": [
    {
      "name": "Duplex 2205",
      "reason": "Alternative option with similar properties",
      "cost_difference": "₹40/kg more expensive"
    }
  ],
  "standards": {
    "passed": true,
    "standards_checked": ["IS 6911", "ASTM A240"],
    "details": [
      {
        "standard": "IS 6911",
        "status": "PASS",
        "note": "Meets stainless steel plate specification"
      }
    ]
  },
  "failure": {
    "risk_level": "LOW",
    "failure_modes": [
      {
        "type": "Crevice Corrosion",
        "severity": "LOW",
        "description": "Risk in tight spaces exposed to seawater.",
        "prevention": "Ensure proper drainage."
      }
    ],
    "overall_recommendation": "Monitor drainage points annually."
  },
  "cost": {
    "comparison": [
      {
        "name": "316 Stainless Steel",
        "price_per_kg_min": 320.0,
        "price_per_kg_max": 380.0,
        "price_display": "₹320 - ₹380/kg",
        "tier": "Premium",
        "currency": "INR"
      }
    ]
  },
  "vendors": {
    "vendors": [
      {
        "name": "Bangalore Steel Traders",
        "address": "Peenya Industrial Area",
        "rating": 4.5,
        "total_ratings": 234,
        "distance_km": 3.2,
        "maps_url": "https://maps.google.com/...",
        "phone": "+91 98XXXXXXXX",
        "open_now": true
      }
    ],
    "search_radius_km": 10
  },
  "conflict_warning": {
    "detected": false,
    "conflicts": [],
    "resolution": null
  },
  "tts_audio_base64": "<base64_encoded_audio_string>",
  "tts_language": "en-IN",
  "report_available": true
}
```

---

## 2. Identify Photo Endpoint (Standalone Vision)
Use this if you want to quickly identify a material *before* running the full analysis.

* **Method:** `POST`
* **URL:** `https://forgeapp-production-e708.up.railway.app/api/identify-photo`
* **Body:**
```json
{
  "photo_base64": "<your_base64_image_string>"
}
```
* **Response:**
```json
{
  "success": true,
  "identification": {
    "identified_material": "Mild Steel",
    "confidence": "HIGH",
    "material_category": "metal",
    "visible_condition": "corroded",
    "recommended_action": "replace"
  }
}
```

---

## 3. Browse Materials Database
Fetches the raw catalog of materials. Used for populating drop-downs or a general catalog screen.

* **Method:** `GET`
* **URL:** `https://forgeapp-production-e708.up.railway.app/api/materials`
* **Query Params:** `?category=metal` *(optional)*
* **Response:**
```json
{
  "materials": [
    {
      "name": "316 Stainless Steel",
      "category": "metal",
      "properties": { ... }
    }
  ],
  "count": 1
}
```

---

## 4. Vendor Search (Google Maps Standalone)
Searches for nearby dealers and suppliers of a specific material. *(Note: The Full Analysis endpoint already returns this! Use this only if you need a separate map refresh).*

* **Method:** `POST`
* **URL:** `https://forgeapp-production-e708.up.railway.app/api/vendors`
* **Body:**
```json
{
  "material_name": "316 Stainless Steel",
  "location": { "lat": 12.9716, "lng": 77.5946 },
  "radius_km": 10.0
}
```

---

## 5. Download PDF Report
Generates a downloadable PDF summarizing the analysis. The frontend should trigger a download intent using the raw bytes.

* **Method:** `POST`
* **URL:** `https://forgeapp-production-e708.up.railway.app/api/report/generate`
* **Body:** Paste the *exact* response object received from the `/api/full-analysis` endpoint.
* **Response Type:** `application/pdf`

---

## 🤖 Directives for the Frontend AI Agent
If you are an AI reading this document, obey the following rules when writing the Flutter code:
1. Generate Dart classes with `json_serializable` or `freezed` that **exactly** match the `FullAnalysisResponse` JSON structure above.
2. The `tts_audio_base64` field might be `null` if the TTS service times out. Use null-safety (`String?`). If it is not null, decode the base64 and play it using `audioplayers`.
3. The `vendors` array might be empty `[]`. Render a fallback "No nearby vendors found" UI gracefully.
4. Pass the user's live GPS coordinates `lat` and `lng` to every `full-analysis` call using the `geolocator` package so the backend can find local vendors.
5. Set `Content-Type: application/json` on all POST requests.
