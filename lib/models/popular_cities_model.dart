// models/popular_cities_model.dart
class PopularCity {
  final int id;
  final String name;
  final String country;
  final String formattedName;
  final String thumbnailUrl;
  final String cityPart;
  final String countryPart;
  final int reviewsCount;
  final int likesCount;
  final bool isLiked;
  final bool isReviewed;
  final String createdAt;

  PopularCity({
    required this.id,
    required this.name,
    required this.country,
    required this.formattedName,
    required this.thumbnailUrl,
    required this.cityPart,
    required this.countryPart,
    required this.reviewsCount,
    required this.likesCount,
    required this.isLiked,
    required this.isReviewed,
    required this.createdAt,
  });

  factory PopularCity.fromJson(Map<String, dynamic> json) {
    return PopularCity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      formattedName: json['formatted_name'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      cityPart: json['city_part'] ?? '',
      countryPart: json['country_part'] ?? '',
      reviewsCount: json['reviews_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isReviewed: json['isReviewed'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'formatted_name': formattedName,
      'thumbnail_url': thumbnailUrl,
      'city_part': cityPart,
      'country_part': countryPart,
      'reviews_count': reviewsCount,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'isReviewed': isReviewed,
      'created_at': createdAt,
    };
  }
}