// services/get_city_details.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/city_details_model.dart';
import 'package:kofyimages/services/endpoints.dart';


class GetCityDetailsService {
  static Future<CityDetail> getCityDetails(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getCityDetails(cityName)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CityDetail.fromJson(data);
      } else {
        print(response.statusCode);
        throw Exception('Failed to load city details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching city details: $e');
    }
  }
}