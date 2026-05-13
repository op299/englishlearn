import 'package:flutter/material.dart';
import 'screens/lessons/lessons_list_screen.dart';
import 'screens/lessons/quiz_screen.dart';
import 'screens/explore/explore_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final themeService = ThemeService();
//   await themeService.initialize();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   static final ThemeData lightTheme = ThemeData(
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: Colors.deepPurple,
//       brightness: Brightness.light,
//     ),
//     useMaterial3: true,
//     brightness: Brightness.light,
//   );

//   static final ThemeData darkTheme = ThemeData(
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: Colors.deepPurple,
//       brightness: Brightness.dark,
//     ),
//     useMaterial3: true,
//     brightness: Brightness.dark,
//   );

//   Future<String> _getInitialRoute() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSeenOnboarding = prefs.getBool('onboarding_seen') ?? false;
//     final isLoggedIn = prefs.getString('access_token') != null;

//     if (isLoggedIn) {
//       return '/home';
//     }

//     if (!hasSeenOnboarding) {
//       return '/onboarding';
//     }

//     return '/login';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeService = ThemeService();
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeService.themeNotifier,
//       builder: (context, themeMode, _) {
//         return MaterialApp(
//           title: 'LexiRise',
//           debugShowCheckedModeBanner: false,
//           theme: lightTheme,
//           darkTheme: darkTheme,
//           themeMode: themeMode,
//           home: FutureBuilder<String>(
//             future: _getInitialRoute(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }

//               switch (snapshot.data) {
//                 case '/home':
//                   return const MainNavigationShell();
//                 case '/onboarding':
//                   return const OnboardingScreen();
//                 default:
//                   return const LoginScreen();
//               }
//             },
//           ),
//           routes: {
//             '/onboarding': (context) => const OnboardingScreen(),
//             '/login': (context) => const LoginScreen(),
//             '/register': (context) => const RegisterScreen(),
//             '/forgot-password': (context) => const ForgotPasswordScreen(),
//             '/home': (context) => const MainNavigationShell(),
//             '/profile': (context) => const ProfileScreen(),
//             '/settings': (context) => const SettingsScreen(),
//           },
//           onGenerateRoute: (RouteSettings settings) {
//             if (settings.name?.startsWith('/lessons/') ?? false) {
//               final parts = settings.name!.split('/');
//               if (parts.length == 4 && parts[1] == 'lessons') {
//                 final topicId = parts[2];
//                 final topicTitle = Uri.decodeComponent(parts[3]);
//                 return MaterialPageRoute(
//                   builder: (context) => LessonsListScreen(
//                     topicId: topicId,
//                     topicTitle: topicTitle,
//                   ),
//                 );
//               }
//             }

//             if (settings.name?.startsWith('/quiz/') ?? false) {
//               final parts = settings.name!.split('/');
//               if (parts.length == 4 && parts[1] == 'quiz') {
//                 final lessonId = parts[2];
//                 final lessonOrder = int.tryParse(parts[3]) ?? 0;
//                 return MaterialPageRoute(
//                   builder: (context) =>
//                       QuizScreen(lessonId: lessonId, lessonOrder: lessonOrder),
//                 );
//               }
//             }

//             return null;
//           },
//         );
//       },
//     );
//   }
// }

// ============ TEST MODE ============
const bool TEST_MODE = true;
const String TEST_SCREEN = 'quiz'; // 'explore', 'lessons', 'quiz'

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiRise - Test',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: _buildTestScreen(),
    );
  }

  Widget _buildTestScreen() {
    switch (TEST_SCREEN) {
      case 'explore':
        return const ExploreScreen();
      case 'lessons':
        return const LessonsListScreen(
          topicId: 'business-1',
          topicTitle: 'Business',
        );
      case 'quiz':
        return const QuizScreen(lessonId: 'lesson-001', lessonOrder: 1);
      default:
        return const ExploreScreen();
    }
  }
}
