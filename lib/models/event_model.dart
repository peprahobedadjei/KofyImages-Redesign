// models/event_model.dart
class EventModel {
  final int id;
  final String thumbnail;
  final String thumbnailUrl;
  final String name;
  final String city;
  final String country;
  final String location;
  final String eventDate;
  final String eventTime;
  final String description;
  final DateTime dateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.thumbnail,
    required this.thumbnailUrl,
    required this.name,
    required this.city,
    required this.country,
    required this.location,
    required this.eventDate,
    required this.eventTime,
    required this.description,
    required this.dateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      location: json['location'] ?? '',
      eventDate: json['event_date'] ?? '',
      eventTime: json['event_time'] ?? '',
      description: json['description'] ?? '',
      dateTime: DateTime.parse(json['date_time'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thumbnail': thumbnail,
      'thumbnail_url': thumbnailUrl,
      'name': name,
      'city': city,
      'country': country,
      'location': location,
      'event_date': eventDate,
      'event_time': eventTime,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}