import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';

/// Title screen: game name, tagline, a loading bar, and a mute toggle.
/// Advances to the main menu when the bar fills.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loader = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void initState() {
    super.initState();
    _loader.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.mainMenu);
      }
    });
  }

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
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
                    animation: _loader,
                    builder: (context, _) => LinearProgressIndicator(
                      value: _loader.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(settings.muted ? Icons.volume_off : Icons.volume_up),
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
