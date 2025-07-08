// services/get_events.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kofyimages/models/event_model.dart';
import 'package:kofyimages/services/endpoints.dart';

class GetEventsService {
  static Future<List<EventModel>> getAllEvents() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getAllEvents),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => EventModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}