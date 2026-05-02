# Forge — Project Context
> Last updated: May 2, 2026
> Status: Active development — Hackathon build
> Event: Vibeathon 2026 — NMIT Bangalore
> Timeline: 5PM to 8AM (15 hours)

---

## 1. What Is Forge

Forge is a construction materials intelligence platform. It recommends the most suitable construction material — metal alloys, wood, concrete, paint, glass, insulation, and more — based on a user's plain language description, voice input, photo of an existing material, or advanced property specification.

The core insight: construction workers and contractors have no accessible, plain-language tool to verify material choices, check standards compliance, compare costs, and find rated local suppliers — all in one flow. Forge fills that gap.

**Primary users:**
- On-site construction workers who need fast material verification
- Contractors and small construction businesses who need professional reports

**Secondary users (experimental, no specific design for these):**
- Homeowners who want to verify contractor recommendations
- Hobby builders doing DIY projects

**The single most important product decision:** Forge is NOT an AI wrapper. The AI (Gemini) handles only NLP intent parsing, material identification from photos, and recommendation ranking. Everything else — standards compliance, failure detection, cost comparison, vendor discovery — runs as real backend logic with its own data layer.

---

## 2. Team

| Person | Role | Responsibilities |
|---|---|---|
| Ani | Backend + AI | FastAPI backend, all services, MongoDB, Gemini API, Sarvam Bulbul, Google Maps API, Railway deployment |
| Hamish | Flutter functional | All input screens, API wiring, voice input, camera input, vendor map screen, TTS playback |
| Vibhas | Flutter UI + polish | Advanced mode sliders, output dashboard, desktop layout, all card designs, demo video |

**Git workflow:** Frontend and backend are on separate branches. Merge after backend is stable and API contracts are locked.

---

## 3. Hackathon Event Flow

| Time | Activity |
|---|---|
| 1PM - 5PM | Registration, inauguration, lab setup |
| 5PM - 8PM | Hackathon Session I — primary build window |
| 8PM - 9PM | Dinner |
| 9PM - 8:30AM | Hackathon Session II — continuous development |
| 9AM - 10:30AM | Judges review demo videos |
| 10:30AM - 11AM | Shortlisting |
| 11AM - 1PM | Refinement window for shortlisted teams |
| 2PM - 3PM | Final presentations (PPT + live demo) |

**Demo setup:** One Android phone with Forge installed handed to judges. Screen shared on projector simultaneously. No reliance on venue WiFi — phone has mobile data.

---

## 4. Final Technology Decisions

Every decision below is locked. Do not suggest alternatives.

| Layer | Technology | Reason locked |
|---|---|---|
| Mobile app | Flutter (Android) | Native camera, voice, maps — best demo impact on physical phone |
| Backend | FastAPI + Python 3.12 | Async, fast, Ani knows it |
| Database | MongoDB Atlas | Already provisioned and populated |
| AI / NLP / Vision | Gemini 3 Flash | Best intent extraction, native multimodal vision, fast low latency via `client.aio` |
| Text to Speech | Sarvam Bulbul | Indian language support — kn-IN, hi-IN, en-IN |
| Voice to Text | speech_to_text Flutter package | Native mobile, works offline |
| Maps + Vendors | Google Maps + Places API | Key already obtained |
| PDF Export | ReportLab (Python backend) | Simple, reliable, no external dependency |
| Deployment | Railway | No Dockerfile needed, auto-detects Python, push to deploy |
| UI generation | Google Stitch | Generated base UI, team refining on top |

**Explicitly rejected:**
- Mistral Pixtral 12B — Removed in favor of Gemini 3 Flash to consolidate API keys and utilize native async SDK features.
- Docker / Docker Compose — not needed for Railway
- PWA / Next.js — rejected in favour of Flutter native app on physical phone
- React Native — team does not know it
- Firebase — MongoDB Atlas already provisioned

---

## 5. Product Features

### Input Modes
1. **Simple Mode (text):** User types plain language — "I need a gate for a coastal area"
2. **Voice Mode:** User speaks the prompt — converted to text via speech_to_text, processed same as text
3. **Photo Mode:** User photographs a material — Gemini identifies it, result fed to NLP pipeline for analysis
4. **Advanced Mode:** User sets 7 property sliders directly — bypasses Gemini intent extraction for properties

### Output Components (all 7 must be present in every response)
1. Material recommendation — name, category, plain English explanation
2. Standards compliance — IS/ASTM/ISO pass/fail per standard
3. Failure mode warning — risk level, failure types, prevention advice
4. Cost comparison — primary + 2 alternatives with INR pricing and tier
5. Vendor list — rated Google Maps suppliers nearby
6. PDF report — downloadable, contains all 6 above
7. Bulbul audio — TTS readout of recommendation summary in user's language

### Advanced Mode Properties (7 sliders, 1-10 scale)
- Tensile Strength
- Ductility
- Corrosion Resistance
- Malleability
- Thermal Resistance
- Density
- Surface Finish (segmented: Glossy / Matte / Brushed)

### Conflict Detection
When Advanced Mode detects mutually exclusive property combinations, a warning card is shown with the best realistic tradeoff. Examples:
- Malleability ≥ 8 AND Tensile Strength ≥ 8
- Density ≤ 2 AND Tensile Strength ≥ 9
- Corrosion Resistance ≥ 9 AND Malleability ≥ 9

---

## 6. Backend Architecture

### Project Structure
```
forge-backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── dependencies.py
│   ├── routers/
│   │   ├── analysis.py        ← PRIMARY ENDPOINT
│   │   ├── materials.py
│   │   ├── vendors.py
│   │   ├── report.py
│   │   └── health.py
│   ├── services/
│   │   ├── gemini_service.py  ← Unified AI (NLP + Vision)
│   │   ├── mistral_service.py ← DEPRECATED (facade only)
│   │   ├── bulbul_service.py
│   │   ├── materials_service.py
│   │   ├── standards_service.py
│   │   ├── failure_service.py
│   │   ├── cost_service.py
│   │   ├── vendor_service.py
│   │   └── report_service.py
│   ├── models/
│   │   ├── requests.py
│   │   ├── responses.py
│   │   └── domain.py
│   ├── db/
│   │   └── mongo.py
│   ├── core/
│   │   ├── exceptions.py
│   │   ├── error_handlers.py
│   │   └── logging.py
│   └── data/
│       ├── standards_map.py
│       ├── failure_map.py
│       └── pricing_map.py
├── tests/
│   ├── conftest.py
│   ├── test_analysis.py
│   ├── test_standards.py
│   ├── test_failure.py
│   ├── test_cost.py
│   ├── test_vendors.py
│   ├── test_gemini_service.py
│   ├── test_mistral_service.py
│   └── test_report.py
├── .env.example
├── .env
├── requirements.txt
├── railway.toml
├── pytest.ini
└── README.md
```

### API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/health` | DB connection status check |
| POST | `/api/full-analysis` | Primary endpoint — full pipeline |
| POST | `/api/identify-photo` | Standalone Gemini photo identification |
| GET | `/api/materials` | Browse and filter materials from MongoDB |
| POST | `/api/vendors` | Standalone vendor search |
| POST | `/api/report/generate` | PDF report download |

### Primary Endpoint — POST /api/full-analysis

**Request:**
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
  "location": { "lat": 12.9716, "lng": 77.5946 },
  "language": "en-IN | hi-IN | kn-IN"
}
```

**Response:**
```json
{
  "success": true,
  "recommendation": {
    "name": "316 Stainless Steel",
    "category": "Metal",
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
    { "name": "Duplex 2205", "reason": "Cheaper alternative with similar corrosion resistance", "cost_difference": "₹40/kg cheaper" }
  ],
  "standards": {
    "passed": true,
    "standards_checked": ["IS 6911", "ASTM A240"],
    "details": [
      { "standard": "IS 6911", "status": "PASS", "note": "Meets stainless steel plate specification" }
    ]
  },
  "failure": {
    "risk_level": "LOW",
    "failure_modes": [
      { "type": "Crevice Corrosion", "severity": "LOW", "description": "...", "prevention": "..." }
    ],
    "overall_recommendation": "Monitor drainage points annually."
  },
  "cost": {
    "comparison": [
      { "name": "316 Stainless Steel", "price_per_kg_min": 320.0, "price_per_kg_max": 380.0, "price_display": "₹320 - ₹380/kg", "tier": "Premium", "currency": "INR" }
    ]
  },
  "vendors": {
    "vendors": [
      { "name": "Bangalore Steel Traders", "address": "Peenya Industrial Area", "rating": 4.5, "total_ratings": 234, "distance_km": 3.2, "maps_url": "https://...", "phone": "+91 98XXXXXXXX", "open_now": true }
    ],
    "search_radius_km": 10
  },
  "conflict_warning": {
    "detected": false,
    "conflicts": [],
    "resolution": null
  },
  "tts_audio_base64": "<base64 encoded audio>",
  "tts_language": "en-IN",
  "report_available": true
}
```

---

## 7. Service Responsibilities

### Gemini Service (`gemini_service.py`)
- Unified service for **both** NLP and Vision
- Uses `google-genai` SDK — NOT `google-generativeai` (that SDK is deprecated)
- Model: `gemini-3-flash-preview`
- Four methods: `extract_intent()`, `identify_material()` (vision), `rank_candidates()`, `generate_explanation()`
- All responses parsed as strict JSON — strip markdown fences before parsing
- All methods use `client.aio` (native async) to prevent the FastAPI event loop from hanging during high-resolution photo processing

### Mistral Service (`mistral_service.py`)
- **DEPRECATED**: Kept only as a facade for backward compatibility. All calls delegate to `gemini_service.identify_material()`.

### Sarvam Bulbul Service (`bulbul_service.py`)
- REST API call via `httpx` — NOT an SDK
- Endpoint: `https://api.sarvam.ai/text-to-speech`
- Header: `api-subscription-key`
- Model field: `bulbul:v1`
- Returns base64 encoded audio
- CRITICAL: TTS failure must NEVER break the main response — wrap in try/except, return None on failure

### Materials Service (`materials_service.py`)
- All MongoDB queries via `motor` (async)
- Correct pattern: `await db["materials"].find(query).limit(n).to_list(length=n)`
- Property queries use tolerance of ±2 to avoid over-filtering
- `detect_conflicts()` runs pure Python logic — no DB calls

### Vendor Service (`vendor_service.py`)
- Two search queries per request: "{material} supplier" and "{material} dealer"
- Deduplication by place_id
- Filter: rating ≥ 4.0
- Sort: rating desc, distance asc
- Haversine distance calculation (not Google's distance)
- Fetch phone for top result only (separate Details API call)
- CRITICAL: Vendor failure must NEVER break the main response

### Report Service (`report_service.py`)
- ReportLab PDF with A4 pagesize
- Sections: title, recommendation, standards table, failure modes, cost comparison table, vendor list
- Returns raw bytes — FastAPI returns as `application/pdf` with download header

---

## 8. Data Layer

### MongoDB Atlas
- Already provisioned — do not touch connection string format
- Database name: `forge`
- Collection: `materials`
- Required document structure:
```json
{
  "name": "316 Stainless Steel",
  "category": "metal",
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
  "grade": "Grade 316",
  "use_cases": ["outdoor gates", "marine hardware", "food processing"],
  "standards": ["IS 6911", "ASTM A240"]
}
```
- Required indexes:
```javascript
db.materials.createIndex({ "category": 1, "properties.corrosion_resistance": -1 })
db.materials.createIndex({ "name": 1 }, { unique: true })
```

### Hardcoded Data Maps
Three Python dict files — never call AI for these, always use the dict:
- `standards_map.py` — IS/ASTM/ISO rules per material × environment
- `failure_map.py` — failure modes per (material, environment) tuple
- `pricing_map.py` — INR pricing per kg with tier for 10+ materials

All three functions wrapped in `@functools.lru_cache` for performance.

---

## 9. Exception Hierarchy
```
ForgeBaseException
├── MaterialNotFoundException (404)
├── AIServiceException (502)
│   ├── GeminiException
│   ├── VisionException
│   └── BulbulException
├── VendorServiceException (502)
├── DatabaseException (503)
├── InvalidInputException (422)
├── ReportGenerationException (500)
└── ConflictingRequirementsException (200)
```

**Rules:**
- No bare `except Exception` without logging
- TTS and vendor exceptions caught at orchestration level — never propagated
- All exceptions return structured JSON: `{ success: false, error: message, error_type: ClassName }`

---

## 10. Environment Variables

```env
GEMINI_API_KEY=
SARVAM_API_KEY=
GOOGLE_MAPS_API_KEY=
MONGODB_URI=
MONGODB_DB_NAME=forge
ENVIRONMENT=development
LOG_LEVEL=INFO
ALLOWED_ORIGINS=http://localhost:3000
```

All loaded via `pydantic_settings.BaseSettings` with `@lru_cache` getter.
`ALLOWED_ORIGINS` is a comma-separated string parsed into a list via field_validator.
*(Mistral API key has been completely removed).*

---

## 11. Deployment

**Platform:** Railway — no Dockerfile required
**Auto-detection:** Railway detects Python from requirements.txt automatically

**railway.toml:**
```toml
[build]
builder = "nixpacks"

[deploy]
startCommand = "uvicorn app.main:app --host 0.0.0.0 --port $PORT"
healthcheckPath = "/api/health"
healthcheckTimeout = 300
restartPolicyType = "on_failure"
```

**Deploy process:**
1. Push to GitHub main branch
2. Railway auto-deploys via Nixpacks
3. Set all env vars in Railway dashboard
4. Verify at `/api/health`

---

## 12. Requirements
```
fastapi==0.111.0
uvicorn[standard]==0.30.0
motor==3.4.0
pydantic==2.7.1
pydantic-settings==2.3.0
google-genai==0.8.0
httpx==0.27.0
reportlab==4.2.0
slowapi==0.1.9
cachetools==5.3.3
pytest==8.2.0
pytest-asyncio==0.23.7
python-multipart==0.0.9
```

---

## 13. Testing

**pytest.ini — required, do not skip:**
```ini
[pytest]
asyncio_mode = auto
```

**Run tests:**
```powershell
pytest tests/ -v
```

All tests use mocks — no real API keys needed.
20+ tests covering: full analysis pipeline, conflict detection, TTS non-fatal, vendor non-fatal, standards structure, failure structure, pricing tiers, report generation. `test_mistral_service.py` remains to test the deprecated facade's backward compatibility.

---

## 14. Critical Implementation Rules

1. **Gemini SDK:** Use `google-genai` and specifically `client.aio` for async processing. The old SDK `google-generativeai` is deprecated.
2. **Unified AI:** Gemini 3 Flash handles all vision and NLP. Mistral is no longer used.
3. **Motor pattern:** Always `await db["col"].find(q).limit(n).to_list(length=n)` — not `.to_list()` on a cursor variable.
4. **TTS non-fatal:** Bulbul failure returns `tts_audio_base64: null` — never raises to client.
5. **Vendor non-fatal:** Vendor failure returns `vendors: []` — never raises to client.
6. **No secrets in code:** All API keys via `get_settings()` only.
7. **Strip MongoDB _id:** Always `result.pop("_id", None)` before returning to client.
8. **JSON from AI:** Always strip markdown fences before `json.loads()`.
9. **Single entry point:** Flutter calls `/api/full-analysis` for everything. All other endpoints are supplementary.
10. **Service singletons:** All services instantiated at module level — never inside route handlers.
11. **lru_cache on data maps:** `get_standards()`, `get_failure_modes()`, `get_pricing()` all cached.
12. **Rate limiting:** 10 requests/minute per IP on `/api/full-analysis` via slowapi.

---

## 15. Flutter API Integration (for frontend reference)

The Flutter app connects to the backend via a single `ApiService` class:

```dart
// Base URL — swap for Railway URL after deployment
const String BASE_URL = 'https://your-railway-app.up.railway.app';

Future<Map<String, dynamic>> fullAnalysis({
  required String inputType,
  String? text,
  String? photoBase64,
  Map<String, dynamic>? advancedParams,
  required double lat,
  required double lng,
  String language = 'en-IN',
}) async {
  final response = await http.post(
    Uri.parse('$BASE_URL/api/full-analysis'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'input_type': inputType,
      'text': text,
      'photo_base64': photoBase64,
      'advanced_params': advancedParams,
      'location': {'lat': lat, 'lng': lng},
      'language': language,
    }),
  );
  if (response.statusCode == 200) return jsonDecode(response.body);
  throw Exception('API error ${response.statusCode}: ${response.body}');
}
```

**Flutter pubspec dependencies:**
```yaml
http: ^1.2.0
speech_to_text: ^6.6.0
image_picker: ^1.0.7
google_maps_flutter: ^2.5.0
geolocator: ^11.0.0
permission_handler: ^11.3.0
url_launcher: ^6.2.5
audioplayers: ^5.2.1
```

---

## 16. What Is Already Done

- **Backend:** 100% complete and verified. 49 files generated across core infra, routing, AI integration, tests, and deployment config.
- **Architectural Shift:** Consolidated NLP and Vision into Gemini 3 Flash. Removed Mistral dependency. Converted AI calls to native async (`client.aio`) to unblock the FastAPI event loop for high-res photo payloads.
- MongoDB Atlas provisioned and populated with materials data.
- UI base generated via Google Stitch — Hamish and Vibhas refining.

## 17. What Needs To Be Built

**Frontend (Hamish + Vibhas):**
- [ ] Flutter project setup
- [ ] Home screen — text, voice, photo inputs
- [ ] Advanced mode panel
- [ ] Result screen — all 7 output components
- [ ] Vendor map screen
- [ ] PDF export trigger
- [ ] TTS audio playback
- [ ] Desktop responsive layout
- [ ] Demo video

---

## 18. Non-Negotiable Demo Features

These five must work by 6AM regardless of everything else:

1. Voice input → recommendation output on screen
2. Standards compliance pass/fail displayed
3. Failure mode warning card visible
4. Vendor map with live Google Maps markers
5. Desktop two-column layout working in browser

PDF export and TTS are bonuses — important but not blocking the demo.
