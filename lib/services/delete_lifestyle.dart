// services/delete_lifestyle_image.dart
import 'dart:convert';
import 'package:kofyimages/services/auth_login.dart';


class DeleteLifestyleImageService {
  static const String baseUrl = 'https://kofyimages-9dae18892c9f.herokuapp.com/api';

  /// Delete a lifestyle image
  static Future<Map<String, dynamic>> deleteLifestyleImage(String imageId) async {
    try {

      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: 'https://kofyimages-9dae18892c9f.herokuapp.com/api/lifestyle-photos/$imageId/',
        method: 'DELETE',
        body: json.encode({}),
      );


      if (response.statusCode == 204) {
        // Successfully deleted
        return {
          'success': true,
          'message': 'Image deleted successfully',
        };
      } else if (response.statusCode == 404) {
        throw Exception('Image not found');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to delete this image');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to delete image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting image: ${e.toString()}');
    }
  }
}