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
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: ApiEndpoints.postCityLike(cityName),
        method: 'POST',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return LikeResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to update city');
      }
    } on FormatException {
      throw Exception('Invalid response format');
    } on Exception {
      // Re-throw API exceptions as-is
      rethrow;
    } catch (e) {
      // Log or rethrow the original error to debug better
      throw Exception('An unexpected error occurred');
    }
  }
}
