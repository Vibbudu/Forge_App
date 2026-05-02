// ═══════════════════════════════════════════════════════════════════════════
// FORGE — App Constants (reads from .env via flutter_dotenv)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// FastAPI backend base URL — loaded from .env
final String kApiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://forgeapp-production-e708.up.railway.app';

/// Google Maps API Key — loaded from .env
final String kGoogleMapsKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

/// Default fallback location (Bengaluru, India)
const kDefaultLat = 12.9716;
const kDefaultLng = 77.5946;

/// API endpoints
const kEndpointFullAnalysis = '/api/full-analysis';
const kEndpointVendors = '/api/vendors';
const kEndpointReport = '/api/report';
