import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Certificate of Excellence: player name, overall score, and honors.
/// Shown after a course is completed, or after the final course is won.
class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  String _honors(int percent) {
    if (percent >= 95) return 'Summa Cum Laude — Highest Honors';
    if (percent >= 90) return 'Magna Cum Laude — High Honors';
    if (percent >= 85) return 'Cum Laude — With Honors';
    return 'With Distinction';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final profile = state.profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No active run.')));
    }

    final won = state.hasWon;
    final average = profile.averagePercent;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.gapL),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.gapL),
              decoration: BoxDecoration(
                color: AppTheme.parchment,
                border: Border.all(color: AppTheme.brass, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    won
                        ? 'Certificate of Excellence'
                        : 'Certificate of Completion',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppTheme.ink),
                  ),
                  const SizedBox(height: AppTheme.gapL),
                  Text(
                    'Awarded to',
                    style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: AppTheme.gapXs),
                  Text(
                    profile.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: AppTheme.ink),
                  ),
                  const SizedBox(height: AppTheme.gapL),
                  Text(
                    'Overall score: $average%',
                    style: TextStyle(color: AppTheme.ink),
                  ),
                  const SizedBox(height: AppTheme.gapXs),
                  Text(
                    _honors(average),
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.gapXl),
                  FilledButton(
                    onPressed: () {
                      if (won) {
                        state.endRun();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.mainMenu,
                          (route) => false,
                        );
                      } else {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.gameplay,
                          ModalRoute.withName(Routes.mainMenu),
                        );
                      }
                    },
                    child: Text(won ? 'Back to Menu' : 'Next Course'),
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
