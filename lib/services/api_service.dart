class ApiService {
  static const String baseUrl = 'http://192.168.1.101:8000/api/v1';

  // Auth endpoints
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh';
  static const String getCurrentUserEndpoint = '$baseUrl/auth/me';
  static const String forgotPasswordEndpoint = '$baseUrl/auth/forgot-password';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
  static const String learningTopicsEndpoint = '$baseUrl/learning/topics';
  static const String learningLessonsByTopicEndpoint =
      '$baseUrl/learning/topics/{topic_id}/lessons';
  static const String learningLessonDetailEndpoint =
      '$baseUrl/learning/lessons/{lesson_id}';
  static const String lessonSubmitEndpoint =
      '$baseUrl/lessons/{lesson_id}/submit';

  // User endpoints
  static const String dashboardEndpoint = '$baseUrl/user/dashboard';
  static const String profileEndpoint = '$baseUrl/user/profile';
  static const String settingsEndpoint = '$baseUrl/user/settings';
  static const String changePasswordEndpoint = '$baseUrl/user/security';
  static const String notificationsEndpoint = '$baseUrl/user/notifications';
  static const String appearanceEndpoint = '$baseUrl/user/appearance';
}
