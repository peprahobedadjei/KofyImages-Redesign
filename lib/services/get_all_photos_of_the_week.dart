// services/get_all_photos_of_the_week.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/photo_of_week_model.dart';
import 'package:kofyimages/services/endpoints.dart';

class PhotoOfWeekService {
  static Future<PhotoOfWeekResponse?> getAllPhotosOfTheWeek() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getAllPhotosOfTheWeek),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PhotoOfWeekResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
