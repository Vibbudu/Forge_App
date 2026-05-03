import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forge_response.dart';
import '../config/constants.dart';
import 'auth_service.dart';

/// Service for all HTTP calls to the FastAPI backend.
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  final AuthService _auth = AuthService();

  /// Analyze a query (text, voice transcript, or photo)
  Future<ForgeResponse> analyzeQuery({
    required String inputType,
    String? text,
    String? photoBase64,
    Map<String, dynamic>? advancedParams,
    required double lat,
    required double lng,
    String language = 'en-IN',
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl$kEndpointFullAnalysis'),
      headers: _auth.authHeaders,
      body: jsonEncode({
        'input_type': inputType,
        'text': text,
        'photo_base64': photoBase64,
        'advanced_params': advancedParams,
        'location': {'lat': lat, 'lng': lng},
        'language': language,
      }),
    );
    
    if (response.statusCode == 200) {
      return ForgeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to analyze query. Status: ${response.statusCode}');
    }
  }

  /// Save a completed analysis as a project
  Future<Map<String, dynamic>> saveProject(ForgeResponse data) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/projects/save'),
      headers: _auth.authHeaders,
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save project. Status: ${response.statusCode}');
    }
  }

  /// Fetch list of saved projects/analyses
  Future<List<Map<String, dynamic>>> listProjects() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/api/projects/list'),
      headers: _auth.authHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final projects = data['projects'] ?? data;
      return List<Map<String, dynamic>>.from(projects is List ? projects : []);
    } else {
      throw Exception('Failed to load projects. Status: ${response.statusCode}');
    }
  }

  /// Transcribe audio using Sarvam AI (server-side STT for Indian languages)
  Future<Map<String, dynamic>> transcribeAudio({
    required String audioBase64,
    String languageCode = 'en-IN',
    String audioFormat = 'wav',
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/voice/transcribe'),
      headers: _auth.authHeaders,
      body: jsonEncode({
        'audio_base64': audioBase64,
        'language_code': languageCode,
        'audio_format': audioFormat,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Transcription failed. Status: ${response.statusCode}');
    }
  }

  /// Synthesize speech from text using Sarvam AI (standalone TTS)
  Future<String?> synthesizeSpeech({
    required String text,
    String languageCode = 'en-IN',
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/api/voice/synthesize'),
      headers: _auth.authHeaders,
      body: jsonEncode({
        'text': text.length > 500 ? text.substring(0, 500) : text,
        'language_code': languageCode,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['audio_base64'];
    } else {
      throw Exception('TTS failed. Status: ${response.statusCode}');
    }
  }
}
