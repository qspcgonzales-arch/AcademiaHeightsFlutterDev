import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';

/// The opening screen: game name, tagline, a loading bar, and a mute button.
/// When the loading bar fills, it moves on to the main menu.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  // Drives the loading bar. "late" = created in initState, before first use.
  late final AnimationController _loadingBar;

  @override
  void initState() {
    super.initState();

    _loadingBar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Go to the main menu once the bar has finished filling.
    _loadingBar.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.mainMenu);
      }
    });

    _loadingBar.forward();
  }

  @override
  void dispose() {
    _loadingBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = context.watch<SettingsController>();

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.gapXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Academia Heights',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.gapS),
                  const Text('Study. Explore. Graduate.'),
                  const SizedBox(height: AppTheme.gapXl),
                  AnimatedBuilder(
                    animation: _loadingBar,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _loadingBar.value,
                      );
                    },
                  ),
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
