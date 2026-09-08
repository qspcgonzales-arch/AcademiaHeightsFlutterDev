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

  final Paint _paint = Paint()..color = AppTheme.brass;

  bool isPlayerInRange(Vector2 playerPosition) =>
      playerPosition.distanceTo(position) <= interactRadius;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      (size / 2).toOffset(),
      size.x / 2,
      _paint,
    );
  }
}
