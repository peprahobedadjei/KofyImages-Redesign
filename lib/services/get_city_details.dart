// services/get_city_details.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/city_details_model.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/endpoints.dart';

class GetCityDetailsService {
  /// Returns detailed info for a single city.
  /// If the user is logged in, the request is made with the
  /// authenticated client; otherwise it falls back to the public endpoint.
  static Future<CityDetail> getCityDetails(String cityName) async {
    try {
      http.Response response;

      // Unauthenticated fallback
      response = await http.get(
        Uri.parse(ApiEndpoints.getCityDetails(cityName)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CityDetail.fromJson(data);
      } else {
        throw Exception(
          'Failed to load city details. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching city details: $e');
    }
  }
}
