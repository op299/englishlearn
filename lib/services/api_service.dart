class ApiService {
  static const String baseUrl =
      'https://my-python-backend-euti.onrender.com/api/v1';

  // Auth endpoints
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh';
  static const String getCurrentUserEndpoint = '$baseUrl/auth/me';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
  static const String learningTopicsEndpoint = '$baseUrl/learning/topics';
  static const String learningExploreEndpoint = '$baseUrl/learning/explore';
  static const String learningLessonsByTopicEndpoint =
      '$baseUrl/learning/topics/{topic_id}/lessons';
  static const String learningLessonDetailEndpoint =
      '$baseUrl/learning/lessons/{lesson_id}';
  static const String lessonSubmitEndpoint =
      '$baseUrl/lessons/{lesson_id}/submit';
  static const String progressSummaryEndpoint = '$baseUrl/progress/summary';
  static const String reviewEndpoint = '$baseUrl/review';
  static const String reviewMistakesEndpoint = '$baseUrl/review/mistakes';

  // User endpoints
  static const String dashboardEndpoint = '$baseUrl/user/dashboard';
  static const String profileEndpoint = '$baseUrl/user/profile';
  static const String settingsEndpoint = '$baseUrl/user/settings';
  static const String changePasswordEndpoint = '$baseUrl/user/security';
  static const String notificationsEndpoint = '$baseUrl/user/notifications';
  static const String appearanceEndpoint = '$baseUrl/user/appearance';
}
