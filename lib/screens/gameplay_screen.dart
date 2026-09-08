import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/academia_heights_game.dart';
import '../game/npc.dart';
import '../models/exam.dart';
import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Hosts the Flame game and the on-screen HUD. The game is drawn by
/// `GameWidget`; the HUD (stats, menu, interact button) and the dialogue
/// pop-ups are ordinary Flutter widgets stacked on top.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  // Built once, the first time the screen is shown.
  AcademiaHeightsGame? _game;

  AcademiaHeightsGame _gameFor(GameState state) {
    final AcademiaHeightsGame? existing = _game;
    if (existing != null) return existing;

    final AcademiaHeightsGame created = AcademiaHeightsGame(
      courseId: state.currentCourse.id,
      instructorName: state.currentCourse.instructorName,
    );
    _game = created;
    return created;
  }

  @override
  Widget build(BuildContext context) {
    final GameState state = context.watch<GameState>();
    final profile = state.profile;

    // No run in progress (e.g. after "quit") — show a spinner while the
    // navigator returns to the menu.
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final AcademiaHeightsGame game = _gameFor(state);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),

          // Top-left: name, level, EXP.
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
                onSelected: (route) => Navigator.of(context).pushNamed(route),
                itemBuilder: (context) => const [
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

          // Bottom-right: interact button, only visible when something is
          // in range.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.gapL),
                child: ValueListenableBuilder<NearbyTarget?>(
                  valueListenable: game.nearby,
                  builder: (context, target, child) {
                    if (target == null) return const SizedBox.shrink();

                    String label;
                    if (target.isNpc) {
                      label = 'Talk to ${target.npc!.displayName}';
                    } else {
                      label = 'Pick up';
                    }

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
    final NpcComponent? npc = game.interactWithNearby();

    // It was a book pickup — nothing more to do.
    if (npc == null) return;

    if (!npc.isInstructor) {
      await _showLine(npc.displayName, 'Good luck with your studies!');
      return;
    }

    await _showInstructorFlow(state);
  }

  Future<void> _showLine(String speaker, String line) {
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
    final ExamStage? stage = _nextStage(state);

    if (stage == null) {
      await _showLine(
        state.currentCourse.instructorName,
        'You have passed every exam. Well done!',
      );
      return;
    }

    if (!state.isStageUnlocked(stage)) {
      final ExamStage? needsFirst = prerequisiteOf(stage);
      final String needsFirstLabel =
          needsFirst == null ? '' : examStageLabel(needsFirst);
      await _showLine(
        state.currentCourse.instructorName,
        'You must pass the $needsFirstLabel exam first.',
      );
      return;
    }

    if (!mounted) return;

    final bool? takeNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${examStageLabel(stage)} Exam'),
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

  /// The first exam stage the player has not passed yet, or null if they are
  /// all done.
  ExamStage? _nextStage(GameState state) {
    for (final ExamStage stage in ExamStage.values) {
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
    // EXP earned toward the next level (0-99).
    final int expIntoLevel = exp % 100;

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
            child: LinearProgressIndicator(value: expIntoLevel / 100),
          ),
        ],
      ),
    );
  }
}
