
class PhotoOfWeekResponse {
  final int count;
  final List<PhotoOfWeek> photos;

  PhotoOfWeekResponse({
    required this.count,
    required this.photos,
  });

  factory PhotoOfWeekResponse.fromJson(Map<String, dynamic> json) {
    return PhotoOfWeekResponse(
      count: json['count'] ?? 0,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((x) => PhotoOfWeek.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'photos': photos.map((x) => x.toJson()).toList(),
    };
  }
}

class PhotoOfWeek {
  final int id;
  final String title;
  final String cityName;
  final String imageUrl;
  final String creatorName;
  final String photoOfWeekDescription;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool likedByUser;

  PhotoOfWeek({
    required this.id,
    required this.title,
    required this.cityName,
    required this.imageUrl,
    required this.creatorName,
    required this.photoOfWeekDescription,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByUser,
  });

  factory PhotoOfWeek.fromJson(Map<String, dynamic> json) {
    return PhotoOfWeek(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      cityName: json['city_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      creatorName: json['creator_name'] ?? '',
      photoOfWeekDescription: json['photo_of_week_description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      likedByUser: json['liked_by_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'city_name': cityName,
      'image_url': imageUrl,
      'creator_name': creatorName,
      'photo_of_week_description': photoOfWeekDescription,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'liked_by_user': likedByUser,
    };
  }
}