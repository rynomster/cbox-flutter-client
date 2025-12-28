import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Authentication service for handling JWT tokens, login, and logout operations
class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  final FlutterSecureStorage _secureStorage;
  final String baseUrl;

  AuthService({
    required this.baseUrl,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Login method that authenticates user and stores JWT token
  /// 
  /// Parameters:
  ///   - email: User's email address
  ///   - password: User's password
  /// 
  /// Returns: Map containing user data and authentication token
  /// 
  /// Throws: Exception if authentication fails
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Login request timed out'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract tokens and user data
        final token = responseData['token'] as String?;
        final refreshToken = responseData['refreshToken'] as String?;
        final userData = responseData['user'] as Map<String, dynamic>?;

        if (token == null) {
          throw Exception('No authentication token received');
        }

        // Store tokens securely
        await _secureStorage.write(key: _tokenKey, value: token);

        if (refreshToken != null) {
          await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
        }

        if (userData != null) {
          await _secureStorage.write(
            key: _userKey,
            value: jsonEncode(userData),
          );
        }

        return {
          'success': true,
          'token': token,
          'user': userData,
          'message': 'Login successful',
        };
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 429) {
        throw Exception('Too many login attempts. Please try again later.');
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout method that clears stored tokens and user data
  /// 
  /// Returns: true if logout was successful
  Future<bool> logout() async {
    try {
      // Optionally notify server about logout
      final token = await getToken();
      if (token != null) {
        try {
          await http.post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));
        } catch (e) {
          // Continue with local logout even if server request fails
          print('Warning: Failed to notify server of logout: $e');
        }
      }

      // Clear secure storage
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userKey);

      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  /// Retrieve the stored JWT token
  /// 
  /// Returns: JWT token string or null if not authenticated
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  /// Retrieve the stored refresh token
  /// 
  /// Returns: Refresh token string or null if not available
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      print('Error retrieving refresh token: $e');
      return null;
    }
  }

  /// Retrieve the stored user data
  /// 
  /// Returns: Map containing user data or null if not authenticated
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userData = await _secureStorage.read(key: _userKey);
      if (userData != null) {
        return jsonDecode(userData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  /// Check if user is currently authenticated
  /// 
  /// Returns: true if token exists, false otherwise
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Refresh the JWT token using refresh token
  /// 
  /// Returns: New token string or null if refresh fails
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = responseData['token'] as String?;

        if (newToken != null) {
          await _secureStorage.write(key: _tokenKey, value: newToken);
          return newToken;
        }
      } else if (response.statusCode == 401) {
        // Refresh token is invalid, clear all tokens
        await logout();
      }

      return null;
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  /// Clear all authentication data from secure storage
  /// 
  /// This is useful for testing or complete account cleanup
  Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
