import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_logo.dart';
import '../theme/app_theme.dart';

/// Hub screen: New Game, Load Game, Leaderboard, Quit.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxHeight < 500;
            final double logoSize = compact ? 48 : 72;
            final double sectionGap = compact ? AppTheme.gapM : AppTheme.gapXl;
            final double itemGap = compact ? AppTheme.gapS : AppTheme.gapM;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.gapL),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppLogo(iconSize: logoSize),
                        SizedBox(height: sectionGap),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.newGame),
                          child: const Text('New Game'),
                        ),
                        SizedBox(height: itemGap),
                        FilledButton.tonal(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.loadGame),
                          child: const Text('Load Game'),
                        ),
                        SizedBox(height: itemGap),
                        FilledButton.tonal(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.leaderboard),
                          child: const Text('Leaderboard'),
                        ),
                        SizedBox(height: itemGap),
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
            );
          },
        ),
      ),
    );
  }
}
