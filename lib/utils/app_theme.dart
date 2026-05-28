import 'package:flutter/material.dart';

/// Material Design 3 compliant theme configuration for LexiRise.
///
/// This class centralizes all theme-related styling to ensure:
/// - Consistent color usage across the app (via ColorScheme)
/// - Proper typography hierarchy (via TextTheme)
/// - Accessibility compliance (minimum font sizes, proper contrast)
/// - Easy dark/light mode switching
class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ============================================================================
  // PRIMARY COLOR
  // ============================================================================
  static const Color _primaryColor = Colors.deepPurple;

  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    textTheme: _buildLightTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ).surface,
      elevation: 0,
      iconTheme: IconThemeData(
        color: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ).onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ).surfaceContainer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  // ============================================================================
  // DARK THEME
  // ============================================================================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: _buildDarkTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ).surface,
      elevation: 0,
      iconTheme: IconThemeData(
        color: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        ).onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ).surfaceContainer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  // ============================================================================
  // LIGHT TEXT THEME
  // ============================================================================
  static TextTheme _buildLightTextTheme() {
    return TextTheme(
      // Display styles — for large, prominent headings
      displayLarge: const TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: 0,
      ),
      displayMedium: const TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
        letterSpacing: 0,
      ),
      displaySmall: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
        letterSpacing: 0,
      ),
      // Headline styles — for section headings
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
        color: Colors.deepPurple.shade900,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        letterSpacing: 0,
        color: Colors.deepPurple.shade900,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: 0,
        color: Colors.deepPurple.shade900,
      ),
      // Title styles — for prominent labels
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
        letterSpacing: 0,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.43,
        letterSpacing: 0.1,
      ),
      // Body styles — for main content
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
      ),
      // Label styles — for buttons, chips, etc.
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
      ),
    );
  }

  // ============================================================================
  // DARK TEXT THEME
  // ============================================================================
  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      // Display styles
      displayLarge: const TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: 0,
        color: Colors.white,
      ),
      displayMedium: const TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
        letterSpacing: 0,
        color: Colors.white,
      ),
      displaySmall: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
        letterSpacing: 0,
        color: Colors.white,
      ),
      // Headline styles
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
        color: Colors.white,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        letterSpacing: 0,
        color: Colors.white,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: 0,
        color: Colors.white,
      ),
      // Title styles
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
        letterSpacing: 0,
        color: Colors.white,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0.15,
        color: Colors.white,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.43,
        letterSpacing: 0.1,
        color: Colors.white,
      ),
      // Body styles
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
        color: Colors.white,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: Colors.white,
      ),
      // Label styles
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: Colors.white,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
    );
  }
}
