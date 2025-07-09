class HeroImagesResponse {
  final bool success;
  final int count;
  final List<CityPhoto> data;
  final String message;

  HeroImagesResponse({
    required this.success,
    required this.count,
    required this.data,
    required this.message,
  });

  factory HeroImagesResponse.fromJson(Map<String, dynamic> json) {
    return HeroImagesResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => CityPhoto.fromJson(item))
          .toList() ?? [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
    };
  }
}

class CityPhoto {
  final int id;
  final String cityName;
  final List<String> photos;
  final int photoCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CityPhoto({
    required this.id,
    required this.cityName,
    required this.photos,
    required this.photoCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityPhoto.fromJson(Map<String, dynamic> json) {
    return CityPhoto(
      id: json['id'] ?? 0,
      cityName: json['city_name'] ?? '',
      photos: (json['photos'] as List<dynamic>?)
          ?.map((photo) => photo.toString())
          .toList() ?? [],
      photoCount: json['photo_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_name': cityName,
      'photos': photos,
      'photo_count': photoCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}