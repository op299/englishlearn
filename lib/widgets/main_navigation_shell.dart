import 'dart:async';

import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../services/auth_service.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;
  StreamSubscription<void>? _sessionExpiredSubscription;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _sessionExpiredSubscription = AuthService.sessionExpiredStream.listen((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    });
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'EXPLORE'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'PROGRESS',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
}
