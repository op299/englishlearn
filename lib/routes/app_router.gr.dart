// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ExploreScreen]
class ExploreRoute extends PageRouteInfo<void> {
  const ExploreRoute({List<PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExploreScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LessonsListScreen]
class LessonsListRoute extends PageRouteInfo<LessonsListRouteArgs> {
  LessonsListRoute({
    Key? key,
    required String topicId,
    required String topicTitle,
    List<PageRouteInfo>? children,
  }) : super(
         LessonsListRoute.name,
         args: LessonsListRouteArgs(
           key: key,
           topicId: topicId,
           topicTitle: topicTitle,
         ),
         initialChildren: children,
       );

  static const String name = 'LessonsListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LessonsListRouteArgs>();
      return LessonsListScreen(
        key: args.key,
        topicId: args.topicId,
        topicTitle: args.topicTitle,
      );
    },
  );
}

class LessonsListRouteArgs {
  const LessonsListRouteArgs({
    this.key,
    required this.topicId,
    required this.topicTitle,
  });

  final Key? key;

  final String topicId;

  final String topicTitle;

  @override
  String toString() {
    return 'LessonsListRouteArgs{key: $key, topicId: $topicId, topicTitle: $topicTitle}';
  }
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainShellScreen]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellScreen();
    },
  );
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [ProgressScreen]
class ProgressRoute extends PageRouteInfo<void> {
  const ProgressRoute({List<PageRouteInfo>? children})
    : super(ProgressRoute.name, initialChildren: children);

  static const String name = 'ProgressRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProgressScreen();
    },
  );
}

/// generated route for
/// [QuizScreen]
class QuizRoute extends PageRouteInfo<QuizRouteArgs> {
  QuizRoute({
    Key? key,
    required String lessonId,
    required int lessonOrder,
    List<PageRouteInfo>? children,
  }) : super(
         QuizRoute.name,
         args: QuizRouteArgs(
           key: key,
           lessonId: lessonId,
           lessonOrder: lessonOrder,
         ),
         initialChildren: children,
       );

  static const String name = 'QuizRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuizRouteArgs>();
      return QuizScreen(
        key: args.key,
        lessonId: args.lessonId,
        lessonOrder: args.lessonOrder,
      );
    },
  );
}

class QuizRouteArgs {
  const QuizRouteArgs({
    this.key,
    required this.lessonId,
    required this.lessonOrder,
  });

  final Key? key;

  final String lessonId;

  final int lessonOrder;

  @override
  String toString() {
    return 'QuizRouteArgs{key: $key, lessonId: $lessonId, lessonOrder: $lessonOrder}';
  }
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    required String token,
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(key: key, token: token),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>();
      return ResetPasswordScreen(key: args.key, token: args.token);
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({this.key, required this.token});

  final Key? key;

  final String token;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, token: $token}';
  }
}

/// generated route for
/// [ResultScreen]
class ResultRoute extends PageRouteInfo<ResultRouteArgs> {
  ResultRoute({
    Key? key,
    required String lessonId,
    required int lessonOrder,
    List<PageRouteInfo>? children,
  }) : super(
         ResultRoute.name,
         args: ResultRouteArgs(
           key: key,
           lessonId: lessonId,
           lessonOrder: lessonOrder,
         ),
         initialChildren: children,
       );

  static const String name = 'ResultRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultRouteArgs>();
      return ResultScreen(
        key: args.key,
        lessonId: args.lessonId,
        lessonOrder: args.lessonOrder,
      );
    },
  );
}

class ResultRouteArgs {
  const ResultRouteArgs({
    this.key,
    required this.lessonId,
    required this.lessonOrder,
  });

  final Key? key;

  final String lessonId;

  final int lessonOrder;

  @override
  String toString() {
    return 'ResultRouteArgs{key: $key, lessonId: $lessonId, lessonOrder: $lessonOrder}';
  }
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}
