/// Model for the like/unlike response
class LikeResponse {
  final String detail;
  final LikeData? data;

  LikeResponse({
    required this.detail,
    this.data,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
      detail: json['detail'],
      data: json['data'] != null ? LikeData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

/// Model for the like data containing user and city information
class LikeData {
  final int id;
  final LikeUser user;
  final LikeCity city;
  final DateTime createdAt;

  LikeData({
    required this.id,
    required this.user,
    required this.city,
    required this.createdAt,
  });

  factory LikeData.fromJson(Map<String, dynamic> json) {
    return LikeData(
      id: json['id'],
      user: LikeUser.fromJson(json['user']),
      city: LikeCity.fromJson(json['city']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'city': city.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model for the user information in like response
class LikeUser {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateJoined;
  final bool isStaff;

  LikeUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateJoined,
    required this.isStaff,
  });

  factory LikeUser.fromJson(Map<String, dynamic> json) {
    return LikeUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dateJoined: DateTime.parse(json['date_joined']),
      isStaff: json['is_staff'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'date_joined': dateJoined.toIso8601String(),
      'is_staff': isStaff,
    };
  }
}

/// Model for the city information in like response
class LikeCity {
  final int id;
  final String name;
  final bool isReviewed;

  LikeCity({
    required this.id,
    required this.name,
    required this.isReviewed,
  });

  factory LikeCity.fromJson(Map<String, dynamic> json) {
    return LikeCity(
      id: json['id'],
      name: json['name'],
      isReviewed: json['isReviewed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isReviewed': isReviewed,
    };
  }
}
