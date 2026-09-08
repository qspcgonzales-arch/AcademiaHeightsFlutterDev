import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/academia_heights_game.dart';
import '../game/npc.dart';
import '../models/exam.dart';
import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Hosts the Flame game plus the HUD. HUD and overlays are Flutter widgets
/// layered over `GameWidget` in a `Stack` — the two loops stay separate.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  AcademiaHeightsGame? _game;

  AcademiaHeightsGame _buildGame(GameState state) {
    return AcademiaHeightsGame(
      courseId: state.currentCourse.id,
      instructorName: state.currentCourse.instructorName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final profile = state.profile;
    if (profile == null) {
      // No active run — bounce back to the menu.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final game = _game ??= _buildGame(state);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),

          // Top-left: name / level / EXP.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.gapM),
              child: Align(
                alignment: Alignment.topLeft,
                child: _HudStats(
                  name: profile.name,
                  level: profile.level,
                  exp: profile.exp,
                ),
              ),
            ),
          ),

          // Top-right: menu.
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (value) => Navigator.of(context).pushNamed(value),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: Routes.progressTracker,
                    child: Text('Academic Progress'),
                  ),
                  PopupMenuItem(
                    value: Routes.saveLoad,
                    child: Text('Save / Load'),
                  ),
                  PopupMenuItem(
                    value: Routes.settings,
                    child: Text('Settings'),
                  ),
                ],
              ),
            ),
          ),

          // Bottom-right: interact button, shown only when something is near.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.gapL),
                child: ValueListenableBuilder<Interactable?>(
                  valueListenable: game.nearby,
                  builder: (context, target, _) {
                    if (target == null) return const SizedBox.shrink();
                    final label = switch (target) {
                      PickupTarget() => 'Pick up',
                      TalkTarget(:final npc) => 'Talk to ${npc.displayName}',
                    };
                    return FilledButton.icon(
                      onPressed: () => _onInteract(game, state),
                      icon: const Icon(Icons.touch_app),
                      label: Text(label),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onInteract(
    AcademiaHeightsGame game,
    GameState state,
  ) async {
    final npc = game.interact();
    if (npc == null) return; // was a pickup
    if (!npc.isInstructor) {
      await _showDialogue(npc.displayName, 'Good luck with your studies!');
      return;
    }
    await _showInstructorFlow(state);
  }

  Future<void> _showDialogue(String speaker, String line) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(speaker),
        content: Text(line),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showInstructorFlow(GameState state) async {
    final stage = _nextStage(state);
    if (stage == null) {
      await _showDialogue(
        state.currentCourse.instructorName,
        'You have passed every exam for this course. Well done!',
      );
      return;
    }

    if (!state.isStageUnlocked(stage)) {
      await _showDialogue(
        state.currentCourse.instructorName,
        'You must pass the ${stage.prerequisite?.label} first.',
      );
      return;
    }

    if (!mounted) return;
    final takeNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${stage.label} Exam'),
        content: const Text('Take the exam now, or review first?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('I will review first'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Take the exam now'),
          ),
        ],
      ),
    );

    if (takeNow == true && mounted) {
      Navigator.of(context).pushNamed(Routes.exam, arguments: stage);
    }
  }

  ExamStage? _nextStage(GameState state) {
    for (final stage in ExamStage.values) {
      if (!state.isStagePassed(stage)) return stage;
    }
    return null;
  }
}

class _HudStats extends StatelessWidget {
  const _HudStats({
    required this.name,
    required this.level,
    required this.exp,
  });

  final String name;
  final int level;
  final int exp;

  @override
  Widget build(BuildContext context) {
    final intoLevel = exp % 100;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.gapM,
        vertical: AppTheme.gapS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.ink.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          Text('Level $level'),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(value: intoLevel / 100),
          ),
        ],
      ),
    );
  }
}
