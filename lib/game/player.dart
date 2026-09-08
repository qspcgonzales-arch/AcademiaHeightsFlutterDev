import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tile_map.dart';

/// The player character. The virtual joystick moves it, and walls in the
/// [TileMapComponent] stop it.
///
/// It's just a rounded rectangle for now; a real animated sprite comes in
/// milestone M1.
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

  /// Movement speed in pixels per second.
  double speed = 140;

  // "..color =" sets the colour on the new Paint and keeps the Paint.
  final Paint _paint = Paint()..color = AppTheme.parchment;

  @override
  void update(double dt) {
    super.update(dt);

    // Nothing to do while the joystick is centred.
    if (joystick.direction == JoystickDirection.idle) return;

    // How far to move this frame: direction * speed * time since last frame.
    final Vector2 move = joystick.relativeDelta * speed * dt;

    // Move one axis at a time so hitting a wall on one axis doesn't stop the
    // other.
    _tryMove(Vector2(move.x, 0));
    _tryMove(Vector2(0, move.y));
  }

  /// Moves by [step] unless that would put the player inside a wall.
  void _tryMove(Vector2 step) {
    if (step.x == 0 && step.y == 0) return;

    final Vector2 nextPosition = position + step;
    final Vector2 nextTopLeft = nextPosition - (size / 2);
    if (map.collidesWithBox(nextTopLeft, size)) return;

    position = nextPosition;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      _paint,
    );
  }
}
