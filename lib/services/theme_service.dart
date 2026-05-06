import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme';
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  ValueNotifier<ThemeMode> get themeNotifier => _themeNotifier;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey) ?? 'light';
    _themeNotifier.value = savedTheme == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
    _themeNotifier.value = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  String getCurrentTheme() {
    return _themeNotifier.value == ThemeMode.dark ? 'dark' : 'light';
  }
}
