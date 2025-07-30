// services/get_city_details.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/city_details_model.dart';
import 'package:kofyimages/services/endpoints.dart';
import 'package:kofyimages/services/auth_login.dart';

class GetCityDetailsService {
  static Future<CityDetail> getCityDetails(String cityName) async {
    try {
      http.Response response;
      
      // Check if user is logged in first
      final isLoggedIn = await AuthLoginService.isLoggedIn();
      
      if (isLoggedIn) {
        // Check token validity by hitting the token validation endpoint
        final tokenValid = await _checkTokenValidity();
        
        if (tokenValid) {
          // Token is valid, use authenticated endpoint
          response = await _getCityDetailsAuthenticated(cityName);
        } else {
          // Token is invalid, logout and use public endpoint
          await AuthLoginService.logout();
          response = await _getCityDetailsPublic(cityName);
        }
      } else {
        // User not logged in, use public endpoint
        response = await _getCityDetailsPublic(cityName);
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CityDetail.fromJson(data);
      } else {
        throw Exception(
          'Failed to load city details. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching city details: $e');
    }
  }

  /// Check if access token is valid by calling the token validation endpoint
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
      
      // For any other status codes, assume token is invalid
      return false;
    } catch (e) {
      // If any error occurs during token validation, assume token is invalid
      return false;
    }
  }

  static Future<http.Response> _getCityDetailsAuthenticated(String cityName) async {
    final accessToken = await AuthLoginService.getAccessToken();
    
    return await http.get(
      Uri.parse(ApiEndpoints.getCityDetails(cityName)), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

 
  static Future<http.Response> _getCityDetailsPublic(String cityName) async {
    return await http.get(
      Uri.parse(ApiEndpoints.getCityDetails(cityName)),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }
}