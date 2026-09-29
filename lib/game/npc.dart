import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tile_map.dart';

/// A talk-to NPC (the Principal, or a course instructor). The gameplay layer
/// checks [isPlayerInRange] each frame and shows the interact button; the
/// dialogue itself is a Flutter overlay, not drawn here.
class NpcComponent extends PositionComponent {
  NpcComponent({
    required this.id,
    required this.displayName,
    required Vector2 position,
    this.isInstructor = false,
    this.isInteractable = true,
    this.map,
    this.patrolWaypoints = const [],
    this.patrolSpeed = 36,
    this.pauseAtWaypoint = 1.2,
    this.portraitFile,
  }) : super(
          position: position,
          size: Vector2.all(AppTheme.tileSize * 0.9),
          anchor: Anchor.center,
          priority: 50,
        ) {
    if (patrolWaypoints.length > 1 && map == null) {
      throw ArgumentError('A patrol route needs a tile map for collision.');
    }
    if (patrolWaypoints.length > 1) {
      _waypointIndex = 1;
    }
  }

  final String id;
  final String displayName;
  final bool isInstructor;
  final bool isInteractable;
  final TileMapComponent? map;
  final List<Vector2> patrolWaypoints;
  final double patrolSpeed;
  final double pauseAtWaypoint;
  final String? portraitFile;

  int _waypointIndex = 0;
  int _waypointDirection = 1;
  double _pauseRemaining = 0;
  bool movementPaused = false;

  /// How close (world pixels) the player must be to interact.
  double interactRadius = AppTheme.tileSize * 1.4;

  /// How close (world pixels) the player's center may get before being
  /// blocked, so the player can't stand on top of an NPC.
  double get solidRadius => size.x / 2;

  Sprite? _portrait;

  @override
  void update(double dt) {
    super.update(dt);

    if (movementPaused || patrolWaypoints.length < 2) return;

    if (_pauseRemaining > 0) {
      _pauseRemaining -= dt;
      return;
    }

    final Vector2 target = patrolWaypoints[_waypointIndex];
    final Vector2 difference = target - position;
    final double distance = difference.length;
    final double movementDistance = patrolSpeed * dt;

    if (distance <= movementDistance) {
      position = target.clone();
      _pauseRemaining = pauseAtWaypoint;
      _moveToNextWaypoint();
      return;
    }

    final Vector2 nextPosition =
        position + difference * (movementDistance / distance);
    final Vector2 nextTopLeft = nextPosition - (size / 2);
    final TileMapComponent? collisionMap = map;
    if (collisionMap != null &&
        collisionMap.collidesWithBox(nextTopLeft, size)) {
      _waypointDirection = -_waypointDirection;
      _moveToNextWaypoint();
      _pauseRemaining = pauseAtWaypoint;
      return;
    }

    position = nextPosition;
  }

  void _moveToNextWaypoint() {
    if (_waypointIndex == patrolWaypoints.length - 1) {
      _waypointDirection = -1;
    } else if (_waypointIndex == 0) {
      _waypointDirection = 1;
    }
    _waypointIndex += _waypointDirection;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _portrait = await Sprite.load('npc/${_portraitFileFor(id)}');
  }

  /// The Principal gets their own portrait; every instructor cycles through
  /// the three teacher portraits, picked from the course id so the same
  /// course always shows the same teacher.
  String _portraitFileFor(String npcId) {
    final String? selectedPortrait = portraitFile;
    if (selectedPortrait != null) return selectedPortrait;
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
