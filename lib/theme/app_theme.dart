import 'package:flutter/material.dart';

/// Central place for colors, spacing, and text styles so screens stay
/// visually consistent. Swap [_fontFamily] once a pixel-art .ttf is added to
/// `assets/fonts/` and registered in `pubspec.yaml`.
abstract final class AppTheme {
  static const String? _fontFamily = null; // e.g. 'PressStart2P'

  // Palette — school / chalkboard feel.
  static const Color ink = Color(0xFF1B2430);
  static const Color chalkboard = Color(0xFF2E4739);
  static const Color parchment = Color(0xFFF4E9D8);
  static const Color brass = Color(0xFFC7A249);
  static const Color ivy = Color(0xFF6FB98F);
  static const Color danger = Color(0xFFC85C5C);

  // Spacing scale.
  static const double gapXs = 4;
  static const double gapS = 8;
  static const double gapM = 16;
  static const double gapL = 24;
  static const double gapXl = 40;

  // Gameplay constants.
  static const double tileSize = 48;
  static const int maxPlayerNameLength = 16;

  /// Exam pass mark as a fraction of questions correct.
  static const double examPassMark = 0.6;

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ivy,
        brightness: Brightness.dark,
      ).copyWith(surface: ink),
      scaffoldBackgroundColor: ink,
      fontFamily: _fontFamily,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: true),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
