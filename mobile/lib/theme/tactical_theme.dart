import 'package:flutter/material.dart';

class TacticalTheme {
  // Theme Colors from Tailwind spec
  static const Color background = Color(0xFF131313);
  static const Color surfaceLowest = Color(0xFF0E0E0E);
  static const Color surfaceLow = Color(0xFF1B1B1B);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainer = Color(0xFF1F1F1F);
  static const Color surfaceHigh = Color(0xFF2A2A2A);
  static const Color surfaceHighest = Color(0xFF353535);

  static const Color primary = Color(0xFF98CBFF);
  static const Color onPrimary = Color(0xFF003354);
  static const Color primaryFixedDim = Color(0xFF98CBFF);
  static const Color primaryContainer = Color(0xFF00A3FF);

  static const Color secondary = Color(0xFFFFE2AB);
  static const Color onSecondary = Color(0xFF402D00);
  static const Color secondaryContainer = Color(0xFFFFBF00); // Amber alert accent
  static const Color onSecondaryContainer = Color(0xFF6D5000);

  static const Color successGreen = Color(0xFF00FF9D);

  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);

  static const Color onBackground = Color(0xFFE2E2E2);
  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFBEC7D4);

  static const Color outline = Color(0xFF88919D);
  static const Color outlineVariant = Color(0xFF3F4852);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        error: error,
        errorContainer: errorContainer,
        onBackground: onBackground,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: primary,
        ),
      ),
    );
  }
}
