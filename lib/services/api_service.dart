import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forge_response.dart';
import '../config/constants.dart';

/// Service for all HTTP calls to the FastAPI backend.
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

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
    
    if (response.statusCode == 200) {
      return ForgeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to analyze query. Status: ${response.statusCode}');
    }
  }
}
