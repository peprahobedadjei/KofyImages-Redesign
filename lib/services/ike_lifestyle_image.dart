// services/like_lifestyle_image.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/endpoints.dart';

class LikeLifestyleImageService {

  
  /// Like a lifestyle image
  static Future<Map<String, dynamic>> likeLifestyleImage(String imageId) async {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Already liked this image');
      } else {
        throw Exception('Failed to like image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

}