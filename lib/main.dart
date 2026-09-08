import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/leaderboard_service.dart';
import 'services/save_service.dart';
import 'state/audio_controller.dart';
import 'state/game_state.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Single shared_preferences instance for every service.
  final prefs = await SharedPreferences.getInstance();
  final saveService = SaveService(prefs);
  final leaderboardService = LeaderboardService(prefs);
  final settings = SettingsController(prefs)..load();

  runApp(
    MultiProvider(
      providers: [
        Provider<SaveService>.value(value: saveService),
        Provider<LeaderboardService>.value(value: leaderboardService),
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<AudioController>(
          create: (_) => AudioController(settings),
        ),
        ChangeNotifierProvider<GameState>(
          create: (_) => GameState(
            saveService: saveService,
            leaderboardService: leaderboardService,
          ),
        ),
      ],
      child: const AcademiaHeightsApp(),
    ),
  );
}
