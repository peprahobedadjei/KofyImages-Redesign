// services/popular_cities_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/popular_cities_model.dart';

class PopularCitiesService {
  static const String _baseUrl = 'https://kofyimages-9dae18892c9f.herokuapp.com/api';

  static Future<List<PopularCity>> getPopularCities() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cities/popular/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PopularCity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching popular cities: $e');
    }
  }
}