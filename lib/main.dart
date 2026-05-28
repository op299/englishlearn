import 'package:englishlearn/screens/auth/onboarding_screen.dart'
    show OnboardingScreen;
import 'package:englishlearn/widgets/main_navigation_shell.dart'
    show MainNavigationShell;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/lessons/lessons_list_screen.dart';
import 'screens/lessons/quiz_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  await themeService.initialize();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    brightness: Brightness.light,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    brightness: Brightness.dark,
  );

  Future<String> _getInitialRoute() async {
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
        return '/home';
      } catch (_) {
        await authService.clearTokens();
      }
    }

    if (!hasSeenOnboarding) {
      return '/onboarding';
    }

    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeService.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'LexiRise',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: FutureBuilder<String>(
            future: _getInitialRoute(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              switch (snapshot.data) {
                case '/home':
                  return const MainNavigationShell();
                case '/onboarding':
                  return const OnboardingScreen();
                default:
                  return const LoginScreen();
              }
            },
          ),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const MainNavigationShell(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name?.startsWith('/lessons/') ?? false) {
              final parts = settings.name!.split('/');
              if (parts.length == 4 && parts[1] == 'lessons') {
                final topicId = parts[2];
                final topicTitle = Uri.decodeComponent(parts[3]);
                return MaterialPageRoute(
                  builder: (context) => LessonsListScreen(
                    topicId: topicId,
                    topicTitle: topicTitle,
                  ),
                );
              }
            }

            if (settings.name?.startsWith('/reset-password') ?? false) {
              final uri = Uri.parse(settings.name!);
              final token =
                  uri.queryParameters['token'] ??
                  (settings.arguments is String
                      ? settings.arguments as String
                      : '');
              return MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(token: token),
              );
            }

            if (settings.name?.startsWith('/quiz/') ?? false) {
              final parts = settings.name!.split('/');
              if (parts.length == 4 && parts[1] == 'quiz') {
                final lessonId = parts[2];
                final lessonOrder = int.tryParse(parts[3]) ?? 0;
                return MaterialPageRoute(
                  builder: (context) =>
                      QuizScreen(lessonId: lessonId, lessonOrder: lessonOrder),
                );
              }
            }

            return null;
          },
        );
      },
    );
  }
}
