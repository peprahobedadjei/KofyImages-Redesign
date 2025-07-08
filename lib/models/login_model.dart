// models/login_models.dart

class LoginRequest {
  final String username;
  final String password;
  
  LoginRequest({
    required this.username,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;
  
  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'password_confirm': passwordConfirm,
    };
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final bool isStaff;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isStaff: json['is_staff'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'is_staff': isStaff,
    };
  }
}

class RegisterUser {
  final String username;
  final String email;
  
  RegisterUser({
    required this.username,
    required this.email,
  });
  
  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      username: json['username'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }
}

class LoginResponse {
  final String message;
  final String accessToken;
  final String refreshToken;
  final User user;
  
  LoginResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      accessToken: json['access'],
      refreshToken: json['refresh'],
      user: User.fromJson(json['user']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'access': accessToken,
      'refresh': refreshToken,
      'user': user.toJson(),
    };
  }
}

class RegisterResponse {
  final String message;
  final RegisterUser user;
  
  RegisterResponse({
    required this.message,
    required this.user,
  });
  
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      user: RegisterUser.fromJson(json['user']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
    };
  }
}

class LoginError {
  final String error;
  
  LoginError({required this.error});
  
  factory LoginError.fromJson(Map<String, dynamic> json) {
    return LoginError(
      error: json['error'] ?? 'Login failed',
    );
  }
}

class RegisterError {
  final Map<String, List<String>> errors;
  
  RegisterError({required this.errors});
  
  factory RegisterError.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> errorMap = {};
    
    json.forEach((key, value) {
      if (value is List) {
        errorMap[key] = value.map((e) => e.toString()).toList();
      } else {
        errorMap[key] = [value.toString()];
      }
    });
    
    return RegisterError(errors: errorMap);
  }
  
  String get firstError {
    if (errors.isEmpty) return 'Registration failed';
    
    final firstKey = errors.keys.first;
    final firstErrorList = errors[firstKey];
    
    return firstErrorList?.isNotEmpty == true 
        ? firstErrorList!.first 
        : 'Registration failed';
  }
  
  String getAllErrors() {
    List<String> allErrors = [];
    
    errors.forEach((field, fieldErrors) {
      for (String error in fieldErrors) {
        allErrors.add('$field: $error');
      }
    });
    
    return allErrors.join('\n');
  }
}