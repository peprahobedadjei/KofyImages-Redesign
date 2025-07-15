import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/services/endpoints.dart';

class GetAllCitiesService {
  static Future<List<City>> getAllCities() async {
    try {
      http.Response response;

      // Use unauthenticated public endpoint
      response = await http.get(
        Uri.parse(ApiEndpoints.getAllCities),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => City.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load cities. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }
}
