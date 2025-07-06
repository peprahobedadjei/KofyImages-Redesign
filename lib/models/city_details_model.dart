// models/city_detail_model.dart
class CityDetail {
  final int id;
  final String name;
  final String country;
  final String thumbnailUrl;
  final String cityPart;
  final String countryPart;
  final Map<String, Category> categories;
  final String createdAt;

  CityDetail({
    required this.id,
    required this.name,
    required this.country,
    required this.thumbnailUrl,
    required this.cityPart,
    required this.countryPart,
    required this.categories,
    required this.createdAt,
  });

  factory CityDetail.fromJson(Map<String, dynamic> json) {
    Map<String, Category> categoriesMap = {};
    if (json['categories'] != null) {
      json['categories'].forEach((key, value) {
        categoriesMap[key] = Category.fromJson(value);
      });
    }

    return CityDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      cityPart: json['city_part'] ?? '',
      countryPart: json['country_part'] ?? '',
      categories: categoriesMap,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class Category {
  final int id;
  final String name;
  final String nameDisplay;
  final String thumbnailUrl;
  final CityInfo city;
  final String createdAt;
  final List<ContentItem> content;

  Category({
    required this.id,
    required this.name,
    required this.nameDisplay,
    required this.thumbnailUrl,
    required this.city,
    required this.createdAt,
    required this.content,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameDisplay: json['name_display'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      city: json['city'] != null ? CityInfo.fromJson(json['city']) : CityInfo(id: 0, name: ''),
      createdAt: json['created_at'] ?? '',
      content: json['content'] != null 
          ? (json['content'] as List).map((item) => ContentItem.fromJson(item)).toList()
          : [],
    );
  }
}

class CityInfo {
  final int id;
  final String name;

  CityInfo({
    required this.id,
    required this.name,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ContentItem {
  final int id;
  final String title;
  final String? youtubeUrl;
  final String? thumbnailUrl;
  final String? imageUrl;
  final String categoryName;
  final String cityName;
  final String createdAt;
  final String? content;
  final String? creatorName;
  final bool? isPhotoOfWeek;
  final int? likesCount;
  final int? commentsCount;
  final bool? likedByUser;

  ContentItem({
    required this.id,
    required this.title,
    this.youtubeUrl,
    this.thumbnailUrl,
    this.imageUrl,
    required this.categoryName,
    required this.cityName,
    required this.createdAt,
    this.content,
    this.creatorName,
    this.isPhotoOfWeek,
    this.likedByUser,
    this.likesCount,
    this.commentsCount,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      youtubeUrl: json['youtube_url'],
      thumbnailUrl: json['thumbnail_url'],
      imageUrl: json['image_url'],
      categoryName: json['category_name'] ?? '',
      cityName: json['city_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      content: json['content'],
      creatorName: json['creator_name'],
      isPhotoOfWeek: json['is_photo_of_week'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      likedByUser: json['liked_by_user'],
    );
  }
}