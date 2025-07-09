// services/like_city.dart
import 'dart:convert';
import 'package:kofyimages/models/like_model.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/endpoints.dart';

/// Service for handling city like/unlike operations
class LikeCityService {
  
  /// Like a city
  static Future<LikeResponse> likeCity(String cityName) async {
    try {
      // Make authenticated request to like the city
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: ApiEndpoints.postCityLike(cityName),
        method: 'POST',
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return LikeResponse.fromJson(responseData);
      } else {
        // Handle error response
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to like city');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Please check your internet connection');
    }
  }

}