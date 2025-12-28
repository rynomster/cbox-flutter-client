import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service class for handling HTTP requests with Bearer token authentication
class ApiService {
  final String baseUrl;
  final String? authToken;
  final http.Client httpClient;

  ApiService({
    required this.baseUrl,
    this.authToken,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Generates headers with Authorization Bearer token
  Map<String, String> _getHeaders({
    bool includeContentType = true,
  }) {
    final headers = <String, String>{};

    // Add Content-Type header if needed
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    // Add Authorization Bearer token if available
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  /// Performs a GET request
  /// 
  /// [endpoint] - The API endpoint (relative to baseUrl)
  /// [headers] - Optional additional headers to include
  /// 
  /// Returns the parsed response body as a Map
  /// Throws [http.ClientException] on network errors
  /// Throws [ApiException] on HTTP error status codes
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {..._getHeaders(includeContentType: false), ...?headers};

      final response = await httpClient.get(url, headers: mergedHeaders);

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a POST request
  /// 
  /// [endpoint] - The API endpoint (relative to baseUrl)
  /// [body] - The request body as a Map (will be JSON encoded)
  /// [headers] - Optional additional headers to include
  /// 
  /// Returns the parsed response body as a Map
  /// Throws [http.ClientException] on network errors
  /// Throws [ApiException] on HTTP error status codes
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {..._getHeaders(includeContentType: true), ...?headers};
      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await httpClient.post(
        url,
        headers: mergedHeaders,
        body: encodedBody,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Handles the HTTP response and returns decoded JSON or throws an exception
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success response
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // Unauthorized
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unauthorized - Invalid or expired token',
        body: response.body,
      );
    } else if (response.statusCode == 403) {
      // Forbidden
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Forbidden - Access denied',
        body: response.body,
      );
    } else if (response.statusCode == 404) {
      // Not Found
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Not Found - Resource does not exist',
        body: response.body,
      );
    } else {
      // Other error responses
      throw ApiException(
        statusCode: response.statusCode,
        message: 'HTTP Error ${response.statusCode}',
        body: response.body,
      );
    }
  }

  /// Updates the authentication token
  void setAuthToken(String token) {
    // Note: This would need to be implemented with proper state management
    // For now, this is a placeholder that shows the intent
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String body;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.body,
  });

  @override
  String toString() => 'ApiException($statusCode): $message\nBody: $body';
}
