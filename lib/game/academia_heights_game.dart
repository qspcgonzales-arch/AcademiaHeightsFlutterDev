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
  // Start in the open strip at the bottom centre of the imported map.
  static const int _oldPlayerColumn = 20;
  static const int _oldPlayerRow = 47;

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
  late List<NpcComponent> _npcs;

  @override
  Color backgroundColor() => AppTheme.ink;

  @override
  Future<void> onLoad() async {
    _map = await TileMapComponent.fromOldProject();
    await world.add(_map);

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
      spawn: _oldWorldPosition(_oldPlayerColumn, _oldPlayerRow),
    );
    await world.add(_player);

    // Keep the player at the exact center of the screen. The old map is
    // allowed to move beyond the viewport near its edges.
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 1.0;
    camera.follow(_player);

    _npcs = [
      NpcComponent(
        id: '$courseId.teacher1',
        displayName: 'Teacher 1',
        position: _oldWorldPosition(9, 26),
      ),
      NpcComponent(
        id: '$courseId.teacher2',
        displayName: 'Teacher 2',
        position: _oldWorldPosition(41, 26),
      ),
      NpcComponent(
        id: '$courseId.instructor',
        displayName: instructorName,
        position: _oldWorldPosition(25, 9),
        isInstructor: true,
      ),
      NpcComponent(
        id: '$courseId.principal',
        displayName: 'Principal',
        position: _oldWorldPosition(24, 41),
      ),
    ];
    _instructor = _npcs[2];
    for (final NpcComponent npc in _npcs) {
      await world.add(npc);
    }

    // These positions are the six book positions from the old Java project.
    final List<Vector2> bookPositions = [
      _oldWorldPosition(15, 31),
      _oldWorldPosition(13, 23),
      _oldWorldPosition(37, 22),
      _oldWorldPosition(39, 31),
      _oldWorldPosition(23, 12),
      _oldWorldPosition(29, 12),
    ];

    for (int i = 0; i < bookPositions.length; i++) {
      final CollectibleBook book = CollectibleBook(
        id: '$courseId.book.$i',
        topic: 'topic-$i',
        position: bookPositions[i],
        onCollected: _onBookCollected,
      );
      await world.add(book);
    }
  }

  // The old Java positions were top-left coordinates. Flame uses centered
  // components, so move each imported position to the center of its tile.
  Vector2 _oldWorldPosition(int column, int row) {
    return tileCenter(column, row);
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
    for (final Component child in world.children) {
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
