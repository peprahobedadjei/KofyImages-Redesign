import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/hero_images_modal.dart';
import 'package:kofyimages/services/endpoints.dart';


class HeroImagesService {
  static Future<HeroImagesResponse?> getAllHeroImages() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getAllHeroImages),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return HeroImagesResponse.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> getAllPhotosUrls() async {
    try {
      final response = await getAllHeroImages();
      if (response != null && response.success) {
        List<String> allPhotos = [];
        for (var city in response.data) {
          allPhotos.addAll(city.photos);
        }
        return allPhotos;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}