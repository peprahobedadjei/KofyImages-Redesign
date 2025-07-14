// services/like_lifestyle_image.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/endpoints.dart';

class LikeLifestyleImageService {
  /// Toggle like/unlike for a lifestyle image
  /// Returns a Map with 'action' key indicating 'liked' or 'unliked'
  static Future<Map<String, dynamic>> toggleLikeLifestyleImage(String imageId) async {
    try {
      // Get the auth token
      final token = await AuthLoginService.getAccessToken();
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}/api/lifestyle-photos/$imageId/like/');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        // Photo liked
        final responseData = json.decode(response.body);
        return {
          'action': 'liked',
          'detail': responseData['detail'] ?? 'Photo liked'
        };
      } else if (response.statusCode == 200) {
        // Photo unliked
        final responseData = json.decode(response.body);
        return {
          'action': 'unliked',
          'detail': responseData['detail'] ?? 'Photo unliked'
        };
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}