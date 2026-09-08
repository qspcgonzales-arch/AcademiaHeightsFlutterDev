import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/certificate_screen.dart';
import 'screens/controls_screen.dart';
import 'screens/exam_result_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/gameplay_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/load_game_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/new_game_screen.dart';
import 'screens/progress_tracker_screen.dart';
import 'screens/save_load_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/title_screen.dart';
import 'theme/app_theme.dart';

/// Root widget. Owns the [MaterialApp], the theme, and the named-route table.
class AcademiaHeightsApp extends StatelessWidget {
  const AcademiaHeightsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academia Heights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: Routes.title,
      routes: {
        Routes.title: (_) => const TitleScreen(),
        Routes.mainMenu: (_) => const MainMenuScreen(),
        Routes.newGame: (_) => const NewGameScreen(),
        Routes.loadGame: (_) => const LoadGameScreen(),
        Routes.leaderboard: (_) => const LeaderboardScreen(),
        Routes.controls: (_) => const ControlsScreen(),
        Routes.settings: (_) => const SettingsScreen(),
        Routes.saveLoad: (_) => const SaveLoadScreen(),
        Routes.gameplay: (_) => const GameplayScreen(),
        Routes.exam: (_) => const ExamScreen(),
        Routes.examResult: (_) => const ExamResultScreen(),
        Routes.progressTracker: (_) => const ProgressTrackerScreen(),
        Routes.certificate: (_) => const CertificateScreen(),
      },
    );
  }
}
