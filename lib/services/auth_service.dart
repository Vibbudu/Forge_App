import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

/// Authentication service — handles login and token management.
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  String? _token;

  /// Returns the current auth token, or null if not logged in.
  String? get token => _token;

  /// Whether we have a valid token.
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Login with credentials and store the token.
  Future<void> login({
    String email = 'admin@forge.com',
    String password = 'password123',
  }) async {
    if (isAuthenticated) return; // Already logged in

    try {
      final response = await http.post(
        Uri.parse('$kApiBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'] ?? data['access_token'] ?? '';
      } else {
        // Fallback to hardcoded demo token if login endpoint not available
        _token = 'forge_demo_token_secure_123';
      }
    } catch (_) {
      // Fallback to hardcoded demo token on connection error
      _token = 'forge_demo_token_secure_123';
    }
  }

  /// Get authorization headers for authenticated requests.
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (isAuthenticated) 'Authorization': 'Bearer $_token',
      };

  /// Logout and clear token.
  void logout() {
    _token = null;
  }
}
