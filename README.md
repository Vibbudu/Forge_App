# Forge — Construction Materials Intelligence Platform

> Backend API for the Forge mobile app. Built with FastAPI, MongoDB Atlas, Gemini 3 Flash (NLP + Vision), and Sarvam Bulbul TTS.

## Architecture

```
Client (Flutter) → FastAPI Backend → AI Services (Gemini 3 Flash, Sarvam Bulbul)
                                   → MongoDB Atlas (materials DB)
                                   → Google Maps Places (vendor search)
                                   → ReportLab (PDF generation)
```

## Quick Start

### 1. Clone & Setup
```bash
cd forge-backend
python -m venv venv

# Windows
.\venv\Scripts\Activate

# macOS/Linux
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure Environment
```bash
copy .env.example .env   # Windows
cp .env.example .env     # macOS/Linux
```

Fill in your API keys in `.env`:
- `GEMINI_API_KEY` — Google AI Studio (used for NLP + Vision)
- `SARVAM_API_KEY` — Sarvam AI Dashboard
- `GOOGLE_MAPS_API_KEY` — Google Cloud Console (Places API enabled)
- `MONGODB_URI` — MongoDB Atlas connection string

### 4. MongoDB Setup

Create a `materials` collection in your Atlas cluster and add compound indexes:

```javascript
// Run in MongoDB Atlas shell or Compass
db.materials.createIndex({ "category": 1, "properties.corrosion_resistance": -1 })
db.materials.createIndex({ "name": 1 }, { unique: true })
db.materials.createIndex({ "properties.tensile_strength": -1 })
```

#### Sample Material Document
```json
{
  "name": "316 Stainless Steel",
  "category": "metal",
  "composition": { "Fe": 68.0, "Cr": 18.0, "Ni": 10.0, "Mo": 3.0, "C": 0.08 },
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
}
```

### 5. Run Development Server
```bash
uvicorn app.main:app --reload --port 8000
```

### 6. API Docs
Open [http://localhost:8000/docs](http://localhost:8000/docs) for Swagger UI (development mode only).

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Health check + DB status |
| `POST` | `/api/full-analysis` | **Primary endpoint** — full material analysis pipeline |
| `POST` | `/api/identify-photo` | Standalone photo material identification |
| `GET` | `/api/materials` | Browse & filter materials from DB |
| `POST` | `/api/vendors` | Search nearby material vendors |
| `POST` | `/api/report/generate` | Generate PDF analysis report |

## Testing

```bash
# Run all tests (mocks only, no API keys needed for data map tests)
pytest tests/ -v

# Run specific test files
pytest tests/test_standards.py tests/test_failure.py tests/test_cost.py -v
```

## Deployment (Railway)

1. Push to GitHub
2. Connect repo in Railway dashboard
3. Set all environment variables from `.env.example`
4. Railway auto-deploys via nixpacks (detects Python from `requirements.txt`)

## Tech Stack

- **Framework**: FastAPI 0.111
- **Database**: MongoDB Atlas (Motor async driver)
- **AI/NLP + Vision**: Google Gemini 3 Flash (`google-genai`, native async via `client.aio`)
- **TTS**: Sarvam Bulbul (en-IN, hi-IN, kn-IN)
- **Vendors**: Google Maps Places API
- **Reports**: ReportLab PDF
- **Rate Limiting**: slowapi
- **Caching**: cachetools TTLCache

## License

Private — Forge Team

---

# forge_app (Frontend)

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
