import 'package:flutter/material.dart';

/// One place for the colours, spacing sizes, and shared numbers used across
/// the app, so screens stay consistent. Holds constants only — the private
/// `AppTheme._()` constructor stops anyone making an instance.
///
/// Set [_fontFamily] once a pixel-art .ttf is added to `assets/fonts/` and
/// listed in `pubspec.yaml`.
class AppTheme {
  AppTheme._();

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

  /// The app's dark theme.
  static ThemeData dark() {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: ivy,
      brightness: Brightness.dark,
    ).copyWith(surface: ink);

    final ButtonStyle bigButton = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: ink,
      fontFamily: _fontFamily,
      appBarTheme: const AppBarTheme(centerTitle: true),
      filledButtonTheme: FilledButtonThemeData(style: bigButton),
    );
  }
}
