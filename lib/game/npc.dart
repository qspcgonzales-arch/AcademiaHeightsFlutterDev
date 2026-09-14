import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A talk-to NPC (the Principal, or a course instructor). The gameplay layer
/// checks [isPlayerInRange] each frame and shows the interact button; the
/// dialogue itself is a Flutter overlay, not drawn here.
class NpcComponent extends PositionComponent {
  NpcComponent({
    required this.id,
    required this.displayName,
    required Vector2 position,
    this.isInstructor = false,
  }) : super(
          position: position,
          size: Vector2.all(AppTheme.tileSize * 0.9),
          anchor: Anchor.center,
        );

  final String id;
  final String displayName;
  final bool isInstructor;

  /// How close (world pixels) the player must be to interact.
  double interactRadius = AppTheme.tileSize * 1.4;

  Sprite? _portrait;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _portrait = await Sprite.load('npc/${_portraitFileFor(id)}');
  }

  /// The Principal gets their own portrait; every instructor cycles through
  /// the three teacher portraits, picked from the course id so the same
  /// course always shows the same teacher.
  String _portraitFileFor(String npcId) {
    if (!isInstructor) return 'Principal.png';

    final int teacherNumber = 1 + (npcId.hashCode.abs() % 3);
    return 'Teacher$teacherNumber.png';
  }

  bool isPlayerInRange(Vector2 playerPosition) {
    final double distance = playerPosition.distanceTo(position);
    return distance <= interactRadius;
  }

  @override
  void render(Canvas canvas) {
    final Sprite? portrait = _portrait;
    if (portrait == null) return; // not loaded yet
    portrait.render(canvas, size: size);
  }
}
