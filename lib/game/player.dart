import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tile_map.dart';

/// The player character. The virtual joystick moves it, and walls in the
/// [TileMapComponent] stop it.
///
/// Draws a small walk-cycle (two frames per direction) built from the
/// sprites in `assets/images/player/`.
class PlayerComponent extends PositionComponent {
  PlayerComponent({
    required this.joystick,
    required this.map,
    required Vector2 spawn,
  }) : super(
          position: spawn,
          size: Vector2.all(AppTheme.tileSize * 0.9),
          anchor: Anchor.center,
          priority: 100,
        );

  final JoystickComponent joystick;
  final TileMapComponent map;

  /// Movement speed in pixels per second.
  double speed = 140;

  // Two walk frames per facing direction.
  late Map<String, List<Sprite>> _walkFrames;

  String _facing = 'down';
  int _frameIndex = 0;
  double _frameTimer = 0;

  // How long each walk frame is shown before swapping to the next one.
  static const double _frameDuration = 0.18;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _walkFrames = {
      'down': await _loadPair('boy_down_1.png', 'boy_down_2.png'),
      'up': await _loadPair('boy_up_1.png', 'boy_up_2.png'),
      'left': await _loadPair('boy_left_1.png', 'boy_left_2.png'),
      'right': await _loadPair('boy_right_1.png', 'boy_right_2.png'),
    };
  }

  Future<List<Sprite>> _loadPair(String frame1, String frame2) async {
    final Sprite first = await Sprite.load('player/$frame1');
    final Sprite second = await Sprite.load('player/$frame2');
    return [first, second];
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Nothing to do while the joystick is centred.
    if (joystick.direction == JoystickDirection.idle) {
      _frameIndex = 0;
      _frameTimer = 0;
      return;
    }

    // How far to move this frame: direction * speed * time since last frame.
    final Vector2 move = joystick.relativeDelta * speed * dt;

    _updateFacing(move);
    _advanceWalkFrame(dt);

    // Move one axis at a time so hitting a wall on one axis doesn't stop the
    // other.
    _tryMove(Vector2(move.x, 0));
    _tryMove(Vector2(0, move.y));
  }

  /// Picks a facing direction from whichever axis the joystick is pushed
  /// harder on.
  void _updateFacing(Vector2 move) {
    if (move.x.abs() > move.y.abs()) {
      _facing = move.x > 0 ? 'right' : 'left';
    } else if (move.y != 0) {
      _facing = move.y > 0 ? 'down' : 'up';
    }
  }

  /// Swaps between the two walk frames for the current direction on a timer.
  void _advanceWalkFrame(double dt) {
    _frameTimer += dt;
    if (_frameTimer < _frameDuration) return;
    _frameTimer = 0;
    _frameIndex = _frameIndex == 0 ? 1 : 0;
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
    final List<Sprite>? frames = _walkFrames[_facing];
    if (frames == null) return; // not loaded yet
    frames[_frameIndex].render(canvas, size: size);
  }
}
