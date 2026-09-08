import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Hub screen: New Game, Load Game, Leaderboard, Quit.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.gapL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Academia Heights',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.gapXl),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.newGame),
                    child: const Text('New Game'),
                  ),
                  const SizedBox(height: AppTheme.gapM),
                  FilledButton.tonal(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.loadGame),
                    child: const Text('Load Game'),
                  ),
                  const SizedBox(height: AppTheme.gapM),
                  FilledButton.tonal(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.leaderboard),
                    child: const Text('Leaderboard'),
                  ),
                  const SizedBox(height: AppTheme.gapM),
                  TextButton(
                    onPressed: () {
                      context.read<GameState>().endRun();
                      SystemNavigator.pop();
                    },
                    child: const Text('Quit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
