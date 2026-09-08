import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'collectible_book.dart';
import 'npc.dart';
import 'player.dart';
import 'tile_map.dart';

/// Whatever the player is currently standing next to. Exactly one of [npc] or
/// [book] is set. The HUD uses this to show the right interact button.
class NearbyTarget {
  NearbyTarget.npc(this.npc) : book = null;
  NearbyTarget.book(this.book) : npc = null;

  final NpcComponent? npc;
  final CollectibleBook? book;

  bool get isNpc => npc != null;
}

/// The Flame game for the school map.
///
/// Scaffold version: a fixed-view demo map, a virtual joystick, one player,
/// one instructor, and a few books. Real tile art, a following camera, and
/// more NPCs come in milestone M1/M2.
///
/// Note: Flame runs its own `update`/`render` loop every frame. It does NOT
/// use Flutter's rebuild system. We tell the Flutter HUD about changes
/// through the `ValueNotifier`s below, and only when something actually
/// changes — never every frame.
class AcademiaHeightsGame extends FlameGame {
  AcademiaHeightsGame({
    required this.courseId,
    required this.instructorName,
  });

  final String courseId;
  final String instructorName;

  /// How many books the player has picked up this session. The HUD listens
  /// to this.
  final ValueNotifier<int> booksCollected = ValueNotifier<int>(0);

  /// What the player can interact with right now, or null. The HUD listens
  /// to this to show/hide the interact button.
  final ValueNotifier<NearbyTarget?> nearby =
      ValueNotifier<NearbyTarget?>(null);

  // Filled in during onLoad(). "late" means "set once, before first use".
  late TileMapComponent _map;
  late PlayerComponent _player;
  late NpcComponent _instructor;

  @override
  Color backgroundColor() => AppTheme.ink;

  @override
  Future<void> onLoad() async {
    _map = TileMapComponent(grid: demoGrid());
    await add(_map);

    final JoystickComponent joystick = JoystickComponent(
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

    // Drop three books around the map.
    for (int i = 0; i < 3; i++) {
      final CollectibleBook book = CollectibleBook(
        id: '$courseId.book.$i',
        topic: 'topic-$i',
        position: Vector2(
          AppTheme.tileSize * (5 + i * 3),
          AppTheme.tileSize * (8 - i),
        ),
        onCollected: _onBookCollected,
      );
      await add(book);
    }
  }

  void _onBookCollected(CollectibleBook book) {
    booksCollected.value = booksCollected.value + 1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _refreshNearby();
  }

  /// Works out what the player is next to and updates [nearby] if it changed.
  void _refreshNearby() {
    final Vector2 playerPosition = _player.position;

    // Books take priority over the instructor.
    for (final Component child in children) {
      if (child is CollectibleBook && child.isPlayerInRange(playerPosition)) {
        _setNearby(NearbyTarget.book(child));
        return;
      }
    }

    if (_instructor.isPlayerInRange(playerPosition)) {
      _setNearby(NearbyTarget.npc(_instructor));
      return;
    }

    _setNearby(null);
  }

  /// Only writes to [nearby] when the target actually changed, so the HUD
  /// doesn't rebuild every frame.
  void _setNearby(NearbyTarget? next) {
    if (_isSameTarget(nearby.value, next)) return;
    nearby.value = next;
  }

  bool _isSameTarget(NearbyTarget? a, NearbyTarget? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.npc != null && a.npc == b.npc) return true;
    if (a.book != null && a.book == b.book) return true;
    return false;
  }

  /// Called by the HUD's interact button. If the player is next to a book it
  /// is collected and this returns null. If they are next to an NPC, that
  /// NPC is returned so the screen can open its dialogue.
  NpcComponent? interactWithNearby() {
    final NearbyTarget? target = nearby.value;
    if (target == null) return null;

    if (target.book != null) {
      target.book!.collect();
      _setNearby(null);
      return null;
    }

    return target.npc;
  }

  @override
  void onRemove() {
    booksCollected.dispose();
    nearby.dispose();
    super.onRemove();
  }
}
