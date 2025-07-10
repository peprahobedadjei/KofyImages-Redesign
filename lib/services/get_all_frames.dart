// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/frame_models.dart';
import 'package:kofyimages/services/endpoints.dart';


class ApiService {
  static Future<List<FrameItem>> fetchPictureFrames() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.getallpictures));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => FrameItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load picture frames');
      }
    } catch (e) {
      throw Exception('Error fetching picture frames: $e');
    }
  }

  static Future<List<FrameItem>> fetchPaintingFrames() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.getallpaintings));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => FrameItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load painting frames');
      }
    } catch (e) {
      throw Exception('Error fetching painting frames: $e');
    }
  }
}

