class User {
  final String userId;
  final String email;
  final String fullName;
  final String currentLevel;

  User({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.currentLevel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      currentLevel: json['current_level'] ?? 'A1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'current_level': currentLevel,
    };
  }
}

class AuthResponse {
  final String userId;
  final String email;
  final String fullName;
  final String? currentLevel;
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.fullName,
    this.currentLevel,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      currentLevel: json['current_level'],
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'current_level': currentLevel,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final int dailyGoalMinutes;
  final String currentLevel;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.dailyGoalMinutes = 10,
    this.currentLevel = 'A1',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'daily_goal_minutes': dailyGoalMinutes,
      'current_level': currentLevel,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
