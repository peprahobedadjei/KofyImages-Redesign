import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/services/endpoints.dart';
import 'package:kofyimages/services/auth_login.dart';

class GetAllCitiesService {
  static Future<List<City>> getAllCities() async {
    try {
      http.Response response;
      
      // Check if user is logged in first
      final isLoggedIn = await AuthLoginService.isLoggedIn();
      
      if (isLoggedIn) {
        // Check token validity by hitting the token validation endpoint
        final tokenValid = await _checkTokenValidity();
        
        if (tokenValid) {
          // Token is valid, use authenticated endpoint
          response = await _getAuthenticatedCities();
        } else {
          // Token is invalid, logout and use public endpoint
          await AuthLoginService.logout();
          response = await _getPublicCities();
        }
      } else {
        // User not logged in, use public endpoint
        response = await _getPublicCities();
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => City.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load cities. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }

  static Future<bool> _checkTokenValidity() async {
    try {
      final accessToken = await AuthLoginService.getAccessToken();
      
      if (accessToken == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.tokenAccess), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['valid'] == true;
      } else if (response.statusCode == 401) {
        final errorData = json.decode(response.body);
        if (errorData['code'] == 'token_not_valid') {
          return false;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get cities using authenticated endpoint
  static Future<http.Response> _getAuthenticatedCities() async {
    final accessToken = await AuthLoginService.getAccessToken();
    
    return await http.get(
      Uri.parse(ApiEndpoints.getAllCities), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  /// Get cities using public/unauthenticated endpoint
  static Future<http.Response> _getPublicCities() async {
    return await http.get(
      Uri.parse(ApiEndpoints.getAllCities), 
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }
}