import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/lessons/lessons_list_screen.dart';
import '../screens/lessons/quiz_screen.dart';
import '../screens/lessons/result_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'app_routes.dart';
import 'main_shell.dart';

part 'app_router.gr.dart';

// =============================================================================
// AppRouter — auto_route code-generated type-safe router
// =============================================================================
// Run: dart run build_runner build --delete-conflicting-outputs
// Produces: app_router.gr.dart

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    // ── Auth flow ──
    AutoRoute(page: OnboardingRoute.page, path: AppRoutes.onboardingPath),
    AutoRoute(page: LoginRoute.page, path: AppRoutes.loginPath),
    AutoRoute(page: RegisterRoute.page, path: AppRoutes.registerPath),
    AutoRoute(page: ResetPasswordRoute.page, path: AppRoutes.resetPasswordPath),

    // ── Main shell with bottom tabs ──
    AutoRoute(
      page: MainShellRoute.page,
      path: AppRoutes.homePath,
      children: [
        AutoRoute(page: HomeRoute.page, path: AppRoutes.homeTabPath),
        AutoRoute(page: ExploreRoute.page, path: AppRoutes.exploreTabPath),
        AutoRoute(page: ProgressRoute.page, path: AppRoutes.progressTabPath),
        AutoRoute(page: ProfileRoute.page, path: AppRoutes.profileTabPath),
      ],
    ),

    // ── Standalone ──
    AutoRoute(page: SettingsRoute.page, path: AppRoutes.settingsPath),

    // ── Dynamic ──
    AutoRoute(page: LessonsListRoute.page, path: AppRoutes.lessonsPath),
    AutoRoute(page: QuizRoute.page, path: AppRoutes.quizPath),
    AutoRoute(page: ResultRoute.page, path: AppRoutes.resultPath),
  ];
}
