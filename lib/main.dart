import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'utils/app_theme.dart';

final _appRouter = AppRouter();

Future<PageRouteInfo> _resolveInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('onboarding_seen') ?? false;
  final hasAccessToken = prefs.getString('access_token') != null;
  final hasRefreshToken = prefs.getString('refresh_token') != null;

  if (hasAccessToken || hasRefreshToken) {
    final authService = AuthService();
    try {
      if (!hasAccessToken && hasRefreshToken) {
        await authService.refreshAccessToken();
      }
      await authService.getCurrentUser();
      return const MainShellRoute();
    } catch (_) {
      await authService.clearTokens();
    }
  }

  if (!hasSeenOnboarding) {
    return const OnboardingRoute();
  }

  return const LoginRoute();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  await themeService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final initialRoute = await _resolveInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final PageRouteInfo initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeService.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'LexiRise',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: _appRouter.config(
            deepLinkBuilder: (_) => DeepLink([initialRoute]),
          ),
        );
      },
    );
  }
}
