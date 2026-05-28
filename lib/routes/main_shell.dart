import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../models/navigation_item.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'app_router.dart';

// =============================================================================
// MainShellScreen — custom tab shell with CustomBottomNavigationBar
// =============================================================================
// Registered as a @RoutePage so auto_route generates MainShellRoute.
// Uses AutoTabsRouter to manage tab switching with a custom bottom nav bar.

@RoutePage()
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  StreamSubscription<void>? _sessionExpiredSubscription;

  // Use static final (not const) because Icons.x.codePoint is not a const expression.
  static final List<NavigationItem> _navItems = [
    NavigationItem(iconCodePoint: Icons.home.codePoint, label: 'HOME'),
    NavigationItem(iconCodePoint: Icons.search.codePoint, label: 'EXPLORE'),
    NavigationItem(
      iconCodePoint: Icons.trending_up.codePoint,
      label: 'PROGRESS',
    ),
    NavigationItem(iconCodePoint: Icons.person.codePoint, label: 'PROFILE'),
  ];

  static const List<Widget> _pages = [
    HomeScreen(),
    ExploreScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _sessionExpiredSubscription = AuthService.sessionExpiredStream.listen((_) {
      if (!mounted) return;
      context.router.replaceAll([const LoginRoute()]);
    });
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        ExploreRoute(),
        ProgressRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = context.tabsRouter;
        return Scaffold(
          body: child,
          bottomNavigationBar: CustomBottomNavigationBar.themed(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) => tabsRouter.setActiveIndex(index),
            items: _navItems,
            context: context,
          ),
        );
      },
    );
  }
}
