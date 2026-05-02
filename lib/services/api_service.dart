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
}

