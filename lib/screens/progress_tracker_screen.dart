import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/courses.dart';
import '../models/exam.dart';
import '../models/player_profile.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Academic Progress Tracker: shows Prelim / Midterm / Finals status and the
/// best score for each.
class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameState state = context.watch<GameState>();
    final profile = state.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No active run.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Progress')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.gapM),
          children: [
            for (final course in courses)
              _CourseCard(
                title: course.title,
                progress: profile.progressFor(course.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.title, required this.progress});

  final String title;
  final CourseProgress progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.gapM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.gapS),
            for (final stage in ExamStage.values)
              _StageRow(
                stage: stage,
                passed: progress.isPassed(stage),
                bestAttempt: progress.bestAt(stage),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.passed,
    required this.bestAttempt,
  });

  final ExamStage stage;
  final bool passed;
  final ExamAttempt? bestAttempt;

  @override
  Widget build(BuildContext context) {
    // A dash if the stage hasn't been attempted, otherwise the best score.
    String scoreText = '—';
    final ExamAttempt? attempt = bestAttempt;
    if (attempt != null) {
      scoreText = '${attempt.percent}%';
    }

    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: passed ? AppTheme.ivy : null,
        ),
        const SizedBox(width: AppTheme.gapS),
        Expanded(child: Text(examStageLabel(stage))),
        Text(scoreText),
      ],
    );
  }
}
