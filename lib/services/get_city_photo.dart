import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/city_photo.dart';
import 'package:kofyimages/services/endpoints.dart';

class CityPhotoService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetches city photos from the API
  /// Returns a [CityPhotosResponse] if successful, null if failed
  static Future<CityPhotosResponse?> getCityPhotos(String cityName) async {
    try {
      final uri = Uri.parse(ApiEndpoints.getCityDetailsPhotos(cityName));
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return CityPhotosResponse.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Fetches multiple city photos with retry logic
  /// Returns a [CityPhotosResponse] if successful, null if failed after retries
  static Future<CityPhotosResponse?> getCityPhotosWithRetry(
    String cityName, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final result = await getCityPhotos(cityName);
        if (result != null) {
          return result;
        }
      } catch (e) {
        if (attempt < maxRetries - 1) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        }
      }
    }
    return null;
  }

  /// Validates if the city photos response is valid and has photos
  static bool isValidResponse(CityPhotosResponse? response) {
    return response != null && 
           response.success && 
           response.data.photos.isNotEmpty;
  }

  /// Extracts photo URLs from the response
  static List<String> getPhotoUrls(CityPhotosResponse? response) {
    if (isValidResponse(response)) {
      return response!.data.photos;
    }
    return [];
  }
}