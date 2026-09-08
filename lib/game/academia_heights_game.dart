import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'collectible_book.dart';
import 'npc.dart';
import 'player.dart';
import 'tile_map.dart';

/// What the player can currently interact with, published once per change
/// (not every frame) so the Flutter HUD can rebuild cheaply.
sealed class Interactable {
  const Interactable();
}

class TalkTarget extends Interactable {
  const TalkTarget(this.npc);
  final NpcComponent npc;
}

class PickupTarget extends Interactable {
  const PickupTarget(this.book);
  final CollectibleBook book;
}

/// The Flame game for one course area. Scaffold version: fixed-view demo map,
/// virtual joystick, one player, one instructor, a few books. Camera follow,
/// real tile art, and multiple areas land in M1.
class AcademiaHeightsGame extends FlameGame {
  AcademiaHeightsGame({required this.courseId, required this.instructorName});

  final String courseId;
  final String instructorName;

  /// Books picked up this session, by topic. Read by the gameplay screen.
  final ValueNotifier<int> booksCollected = ValueNotifier<int>(0);

  /// Current interact target, or null. The HUD listens to this.
  final ValueNotifier<Interactable?> nearby =
      ValueNotifier<Interactable?>(null);

  late final TileMapComponent _map;
  late final PlayerComponent _player;
  late final NpcComponent _instructor;

  @override
  Color backgroundColor() => AppTheme.ink;

  @override
  Future<void> onLoad() async {
    _map = TileMapComponent(grid: demoGrid());
    await add(_map);

    final joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 20,
        paint: Paint()..color = AppTheme.parchment.withValues(alpha: 0.9),
      ),
      background: CircleComponent(
        radius: 48,
        paint: Paint()..color = AppTheme.parchment.withValues(alpha: 0.25),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    await add(joystick);

    _player = PlayerComponent(
      joystick: joystick,
      map: _map,
      spawn: Vector2(AppTheme.tileSize * 3, AppTheme.tileSize * 3),
    );
    await add(_player);

    _instructor = NpcComponent(
      id: '$courseId.instructor',
      displayName: instructorName,
      position: Vector2(AppTheme.tileSize * 16, AppTheme.tileSize * 10),
      isInstructor: true,
    );
    await add(_instructor);

    for (var i = 0; i < 3; i++) {
      await add(
        CollectibleBook(
          id: '$courseId.book.$i',
          topic: 'topic-$i',
          position: Vector2(
            AppTheme.tileSize * (5 + i * 3),
            AppTheme.tileSize * (8 - i),
          ),
          onCollected: (_) => booksCollected.value++,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _refreshNearby();
  }

  void _refreshNearby() {
    final playerPos = _player.position;

    for (final book in children.whereType<CollectibleBook>()) {
      if (book.isPlayerInRange(playerPos)) {
        _setNearby(PickupTarget(book));
        return;
      }
    }

    if (_instructor.isPlayerInRange(playerPos)) {
      _setNearby(TalkTarget(_instructor));
      return;
    }

    _setNearby(null);
  }

  void _setNearby(Interactable? value) {
    final current = nearby.value;
    final same = switch ((current, value)) {
      (null, null) => true,
      (TalkTarget a, TalkTarget b) => identical(a.npc, b.npc),
      (PickupTarget a, PickupTarget b) => identical(a.book, b.book),
      _ => false,
    };
    if (!same) nearby.value = value;
  }

  /// Called by the HUD interact button. Returns the NPC to talk to, if any.
  NpcComponent? interact() {
    final target = nearby.value;
    switch (target) {
      case PickupTarget(:final book):
        book.collect();
        _setNearby(null);
        return null;
      case TalkTarget(:final npc):
        return npc;
      case null:
        return null;
    }
  }

  @override
  void onRemove() {
    booksCollected.dispose();
    nearby.dispose();
    super.onRemove();
  }
}
