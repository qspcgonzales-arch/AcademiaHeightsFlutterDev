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
  // Required before using shared_preferences at startup.
  WidgetsFlutterBinding.ensureInitialized();

  // One shared_preferences instance, shared by every service.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final SaveService saveService = SaveService(prefs);
  final LeaderboardService leaderboardService = LeaderboardService(prefs);

  final SettingsController settings = SettingsController(prefs);
  settings.load();

  final AudioController audio = AudioController(settings);
  final GameState gameState = GameState(
    saveService: saveService,
    leaderboardService: leaderboardService,
  );

  // "provider" makes these objects available to every screen. `.value` is
  // used for objects we built above; `create:` is used when provider should
  // build (and later dispose) the object itself.
  runApp(
    MultiProvider(
      providers: [
        Provider<SaveService>.value(value: saveService),
        Provider<LeaderboardService>.value(value: leaderboardService),
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<AudioController>.value(value: audio),
        ChangeNotifierProvider<GameState>.value(value: gameState),
      ],
      child: const AcademiaHeightsApp(),
    ),
  );
}
