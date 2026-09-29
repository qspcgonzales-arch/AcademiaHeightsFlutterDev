import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/tile_map.dart';
import '../routes.dart';
import '../state/settings_controller.dart';
import '../theme/app_logo.dart';
import '../theme/app_theme.dart';

/// The opening screen: game name, tagline, a loading bar, and a mute button.
/// Moves on to the main menu as soon as the gameplay images are preloaded —
/// no artificial delay, so entering a game doesn't stutter on first draw but
/// also doesn't wait around once it's ready.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  @override
  void initState() {
    super.initState();
    _preloadGameplayImages();
  }

  /// Loads the gameplay sprites into Flame's image cache now, while the
  /// player is looking at the loading bar, instead of the first time the
  /// game screen draws them.
  Future<void> _preloadGameplayImages() async {
    await Flame.images.loadAll([
      ...TileMapComponent.allTileImagePaths,
      'player/boy_down_1.png',
      'player/boy_down_2.png',
      'player/boy_up_1.png',
      'player/boy_up_2.png',
      'player/boy_left_1.png',
      'player/boy_left_2.png',
      'player/boy_right_1.png',
      'player/boy_right_2.png',
      'npc/Teacher1.png',
      'npc/Teacher2.png',
      'npc/Teacher3.png',
      'npc/Principal.png',
      'books/B1.png',
      'books/B2.png',
      'books/B3.png',
      'books/B4.png',
      'books/B5.png',
      'books/B6.png',
    ]);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(Routes.mainMenu);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = context.watch<SettingsController>();

    return Scaffold(
      body: Stack(
        children: [
          // Old project's splash art, filling the screen behind everything.
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/SplashScreen.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dim the art so the white title text and progress bar stay readable.
          Positioned.fill(
            child: Container(color: AppTheme.ink.withValues(alpha: 0.45)),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.gapXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(iconSize: 96, textColor: AppTheme.parchment),
                  SizedBox(height: AppTheme.gapS),
                  Text(
                    'Study. Explore. Graduate.',
                    style: TextStyle(color: AppTheme.parchment),
                  ),
                  SizedBox(height: AppTheme.gapXl),
                  // Indeterminate — it just fills while assets load, with no
                  // fixed length, so it never waits around after they're
                  // ready.
                  LinearProgressIndicator(),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  settings.muted ? Icons.volume_off : Icons.volume_up,
                ),
                tooltip: settings.muted ? 'Unmute' : 'Mute',
                onPressed: () => settings.setMuted(!settings.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
