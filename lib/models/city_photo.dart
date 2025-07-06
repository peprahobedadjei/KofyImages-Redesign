class CityPhotosResponse {
  final bool success;
  final CityPhotosData data;
  final String message;

  CityPhotosResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory CityPhotosResponse.fromJson(Map<String, dynamic> json) {
    return CityPhotosResponse(
      success: json['success'] ?? false,
      data: CityPhotosData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class CityPhotosData {
  final int id;
  final String cityName;
  final List<String> photos;
  final int photoCount;
  final String createdAt;
  final String updatedAt;

  CityPhotosData({
    required this.id,
    required this.cityName,
    required this.photos,
    required this.photoCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityPhotosData.fromJson(Map<String, dynamic> json) {
    return CityPhotosData(
      id: json['id'] ?? 0,
      cityName: json['city_name'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      photoCount: json['photo_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_name': cityName,
      'photos': photos,
      'photo_count': photoCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}