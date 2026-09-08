import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/courses.dart';
import '../models/exam.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Academic Progress Tracker: Prelim / Midterm / Finals status per course,
/// overall completion, and the next exam to take.
class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.gapM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.gapS),
                      for (final stage in ExamStage.values)
                        _StageRow(
                          stage: stage,
                          passed: profile
                              .progressFor(course.id)
                              .isPassed(stage),
                          percent: profile
                              .progressFor(course.id)
                              .bestAt(stage)
                              ?.percent,
                        ),
                    ],
                  ),
                ),
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
    required this.percent,
  });

  final ExamStage stage;
  final bool passed;
  final int? percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: passed ? AppTheme.ivy : null,
        ),
        const SizedBox(width: AppTheme.gapS),
        Expanded(child: Text(stage.label)),
        Text(percent == null ? '—' : '$percent%'),
      ],
    );
  }
}
