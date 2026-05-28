/// Centralized route name & path constants for auto_route code generation.
///
/// Path constants use the format expected by auto_route:
/// - Static paths: `/login`, `/home`
/// - Dynamic paths: `/lessons/:topicId/:topicTitle`
class AppRoutes {
  AppRoutes._();

  // ── Auth ──
  static const String onboardingPath = '/onboarding';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String resetPasswordPath = '/reset-password';

  // ── Main shell ──
  static const String homePath = '/home';

  // ── Tab children (relative paths under /home) ──
  static const String homeTabPath = 'home-tab';
  static const String exploreTabPath = 'explore-tab';
  static const String progressTabPath = 'progress-tab';
  static const String profileTabPath = 'profile-tab';

  // ── Standalone ──
  static const String settingsPath = '/settings';

  // ── Dynamic routes ──
  static const String lessonsPath = '/lessons/:topicId/:topicTitle';
  static const String quizPath = '/quiz/:lessonId/:lessonOrder';
  static const String resultPath = '/result/:lessonId/:lessonOrder';

  // ── Legacy name aliases (used by non-auto_route navigator calls) ──
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String lessons = '/lessons';
  static const String quiz = '/quiz';
}
