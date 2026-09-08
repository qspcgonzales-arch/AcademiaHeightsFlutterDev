import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tile_map.dart';

/// The player character. Movement is driven by a [JoystickComponent] and
/// blocked by non-walkable tiles in [TileMapComponent].
///
/// This is deliberately a plain rectangle for the scaffold; swap in a
/// `SpriteAnimationComponent` in M1 once art is wired.
class PlayerComponent extends PositionComponent {
  PlayerComponent({
    required this.joystick,
    required this.map,
    required Vector2 spawn,
  }) : super(
          position: spawn,
          size: Vector2.all(AppTheme.tileSize * 0.8),
          anchor: Anchor.center,
        );

  final JoystickComponent joystick;
  final TileMapComponent map;

  double speed = 140; // logical pixels/second

  final Paint _paint = Paint()..color = AppTheme.parchment;

  @override
  void update(double dt) {
    super.update(dt);
    if (joystick.direction == JoystickDirection.idle) return;

    final delta = joystick.relativeDelta * speed * dt;
    _moveAxis(Vector2(delta.x, 0));
    _moveAxis(Vector2(0, delta.y));
  }

  /// Move along one axis, cancelling it if the new box would hit a wall.
  void _moveAxis(Vector2 step) {
    if (step.isZero()) return;
    final next = position + step;
    final topLeft = next - size / 2;
    if (map.collidesWithBox(topLeft, size)) return;
    position = next;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      _paint,
    );
  }
}
