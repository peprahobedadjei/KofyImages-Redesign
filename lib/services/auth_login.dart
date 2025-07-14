// services/auth_login.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/login_model.dart';
import 'package:kofyimages/services/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for handling login, registration, and token management
class AuthLoginService {
  
  // ===========================================
  // LOGIN FUNCTIONALITY
  // ===========================================
  
  /// Performs login with username and password
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);
        
        // Save login data to SharedPreferences
        await _saveLoginData(loginResponse);
        
        return loginResponse;
      } else {
        // Handle error response
        final errorData = jsonDecode(response.body);
        throw Exception(LoginError.fromJson(errorData).error);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Please check your internet connection');
    }
  }

  // ===========================================
  // REGISTRATION FUNCTIONALITY
  // ===========================================
  
  /// Performs user registration
  static Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final registerResponse = RegisterResponse.fromJson(responseData);
        
        return registerResponse;
      } else {
        // Handle error response
        final errorData = jsonDecode(response.body);
        final registerError = RegisterError.fromJson(errorData);
        throw Exception(registerError.getAllErrors());
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Please check your internet connection');
    }
  }

  /// Register user and automatically login
  static Future<LoginResponse> registerAndLogin(RegisterRequest request) async {
    try {
      // First, register the user
      // ignore: unused_local_variable
      final registerResponse = await register(request);
      
      // If registration successful, automatically login
      final loginRequest = LoginRequest(
        username: request.username,
        password: request.password,
      );
      
      final loginResponse = await login(loginRequest);
      
      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================
  // TOKEN REFRESH FUNCTIONALITY
  // ===========================================
  
  /// Refresh access token using refresh token
  static Future<TokenRefreshResponse> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final refreshResponse = TokenRefreshResponse.fromJson(responseData);
        
        // Update stored tokens
        await _updateTokens(refreshResponse.access, refreshResponse.refresh);
        
        return refreshResponse;
      } else {
        // Handle error response
        final errorData = jsonDecode(response.body);
        
        // Check if refresh token is expired
        if (errorData['code'] == 'token_not_valid' && 
            errorData['detail'] == 'Token is expired') {
          // Refresh token is expired, user needs to login again
          await logout(); // Clear all stored data
          throw TokenExpiredException('Refresh token expired. Please login again.');
        }
        
        throw Exception(errorData['detail'] ?? 'Failed to refresh token');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Please check your internet connection');
    }
  }

  // ===========================================
  // AUTHENTICATED API REQUESTS
  // ===========================================
  
  /// Make authenticated API request with automatic token refresh
  static Future<http.Response> makeAuthenticatedRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    String? accessToken = await getAccessToken();
    
    if (accessToken == null) {
      throw Exception('No access token available');
    }

    // Prepare headers with authorization
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      ...?headers,
    };

    http.Response response;
    
    // Make the initial request
    response = await _makeHttpRequest(url, method, requestHeaders, body);

    // Check if token is expired
    if (response.statusCode == 401) {
      final errorData = jsonDecode(response.body);
      
      if (errorData['code'] == 'token_not_valid') {
        try {
          // Try to refresh the token
          await refreshToken();
          
          // Get the new access token
          accessToken = await getAccessToken();
          
          if (accessToken != null) {
            // Update headers with new token
            requestHeaders['Authorization'] = 'Bearer $accessToken';
            
            // Retry the request with new token
            response = await _makeHttpRequest(url, method, requestHeaders, body);
          }
        } catch (e) {
          if (e is TokenExpiredException) {
            // Both tokens are expired, user needs to login
            rethrow;
          }
          // If refresh fails, return the original response
        }
      }
    }

    return response;
  }

  /// Helper method to make HTTP requests
  static Future<http.Response> _makeHttpRequest(
    String url, 
    String method, 
    Map<String, String> headers, 
    Object? body
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: headers);
      case 'POST':
        return await http.post(Uri.parse(url), headers: headers, body: body);
      case 'PUT':
        return await http.put(Uri.parse(url), headers: headers, body: body);
      case 'DELETE':
        return await http.delete(Uri.parse(url), headers: headers, body: body);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // ===========================================
  // DATA PERSISTENCE (SharedPreferences)
  // ===========================================
  
  /// Save login data to SharedPreferences
  static Future<void> _saveLoginData(LoginResponse loginResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save tokens
      await prefs.setString('access_token', loginResponse.accessToken);
      await prefs.setString('refresh_token', loginResponse.refreshToken);
      
      // Save user data
      await prefs.setString('user_data', jsonEncode(loginResponse.user.toJson()));
      
      // Save login status
      await prefs.setBool('is_logged_in', true);
      
      // Save login timestamp
      await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
      
    } catch (e) {
      throw Exception('Failed to save login data');
    }
  }

  /// Update stored tokens after refresh
  static Future<void> _updateTokens(String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      
      // Update login timestamp
      await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to update tokens');
    }
  }

  // ===========================================
  // DATA RETRIEVAL METHODS
  // ===========================================
  
  /// Get saved access token
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      return null;
    }
  }

  /// Get saved refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('refresh_token');
    } catch (e) {
      return null;
    }
  }

  /// Get saved user data
  static Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_logged_in') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get login timestamp
  static Future<DateTime?> getLoginTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('login_timestamp');
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===========================================
  // LOGOUT FUNCTIONALITY
  // ===========================================
  
  /// Clear all login data (logout)
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all authentication related data
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
      await prefs.remove('is_logged_in');
      await prefs.remove('login_timestamp');
      
    } catch (e) {
      throw Exception('Failed to logout');
    }
  }

  // ===========================================
  // VALIDATION METHODS
  // ===========================================
  
  /// Validate login credentials locally
  static bool validateLoginCredentials(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }
    
    // Additional validation can be added here
    return true;
  }

  /// Validate registration credentials locally
  static String? validateRegistrationCredentials(RegisterRequest request) {
    // Username validation
    if (request.username.isEmpty) {
      return 'Username cannot be empty';
    }
    
    if (request.username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    // Email validation
    if (request.email.isEmpty) {
      return 'Email cannot be empty';
    }
    
    if (!_isValidEmail(request.email)) {
      return 'Please enter a valid email address';
    }
    
    // Password validation
    if (request.password.isEmpty) {
      return 'Password cannot be empty';
    }
    
    if (request.password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    // Password confirmation validation
    if (request.passwordConfirm.isEmpty) {
      return 'Password confirmation cannot be empty';
    }
    
    if (request.password != request.passwordConfirm) {
      return 'Passwords do not match';
    }
    
    return null; // No validation errors
  }

  /// Helper method to validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================
  
  /// Check if token is expired based on timestamp
  static Future<bool> isTokenExpired() async {
    try {
      final loginTimestamp = await getLoginTimestamp();
      if (loginTimestamp == null) return true;
      
      final now = DateTime.now();
      final difference = now.difference(loginTimestamp);
      
      // Assuming tokens expire after 24 hours (adjust as needed)
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  /// Get user full name or username
  static Future<String?> getUserDisplayName() async {
    try {
      final user = await getSavedUser();
      return user?.username;
    } catch (e) {
      return null;
    }
  }

  /// Check if user has admin privileges
  static Future<bool> isUserAdmin() async {
    try {
      final user = await getSavedUser();
      return user?.isStaff ?? false;
    } catch (e) {
      return false;
    }
  }
}

// ===========================================
// CUSTOM EXCEPTIONS
// ===========================================

/// Custom exception for token expiration
class TokenExpiredException implements Exception {
  final String message;
  
  TokenExpiredException(this.message);
  
  @override
  String toString() => 'TokenExpiredException: $message';
}

// ===========================================
// RESPONSE MODELS
// ===========================================

/// Token refresh response model
class TokenRefreshResponse {
  final String access;
  final String refresh;
  
  TokenRefreshResponse({
    required this.access,
    required this.refresh,
  });
  
  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      access: json['access'],
      refresh: json['refresh'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}