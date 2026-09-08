import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exam.dart';
import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Shows the score, EXP earned, level progress, and a short remark. Routes
/// on to the certificate if the course is now complete, else back to
/// gameplay.
class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  String _remark(int percent) {
    if (percent >= 90) return 'Outstanding work!';
    if (percent >= 75) return 'Well done.';
    if (percent >= 60) return 'You passed — keep studying.';
    return 'Not quite. Review your materials and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final GameState state = context.watch<GameState>();
    final ExamAttempt? attempt = state.lastAttempt;
    final profile = state.profile;

    if (attempt == null || profile == null) {
      return const Scaffold(body: Center(child: Text('No result to show.')));
    }

    final bool passed = attempt.passed(AppTheme.examPassMark);

    // Passing the Finals is what finishes the game.
    bool graduated = false;
    if (attempt.stage == ExamStage.finals) {
      graduated = profile.isCourseComplete(attempt.courseId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${examStageLabel(attempt.stage)} Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.gapL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.cancel,
                size: 72,
                color: passed ? AppTheme.ivy : AppTheme.danger,
              ),
              const SizedBox(height: AppTheme.gapM),
              Text(
                '${attempt.correct} / ${attempt.total}  (${attempt.percent}%)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.gapS),
              Text(_remark(attempt.percent), textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.gapL),
              ListTile(
                leading: const Icon(Icons.star),
                title: Text('EXP earned: ${attempt.expEarned}'),
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: Text('Level ${profile.level}'),
                subtitle: LinearProgressIndicator(
                  value: (profile.exp % 100) / 100,
                ),
              ),
              const Spacer(),
              if (graduated)
                FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(Routes.certificate),
                  child: const Text('View Certificate'),
                )
              else
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(passed ? 'Continue' : 'Back to studying'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
