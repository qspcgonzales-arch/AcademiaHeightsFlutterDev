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
  // Start near the bottom centre on the beige floor tiles.
  static const int _oldPlayerColumn = 25;
  static const int _oldPlayerRow = 44;

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
    // The viewport is the camera's own screen-space layer, drawn after the
    // world no matter what — so the joystick always stays on top and never
    // scrolls, zooms, or gets covered by map tiles, NPCs, or books.
    joystick.priority = 1000;
    await camera.viewport.add(joystick);

    _player = PlayerComponent(
      joystick: joystick,
      map: _map,
      spawn: _oldWorldPosition(_oldPlayerColumn, _oldPlayerRow),
    );
    await world.add(_player);

    // Keep the player at the exact center of the screen. The old map is
    // allowed to move beyond the viewport near its edges.
    camera.viewfinder.anchor = Anchor.center;
    // Show more of the campus at once so map features are not tightly cropped
    // by the edge of a wide phone viewport.
    camera.viewfinder.zoom = 1.7;
    camera.follow(_player);

    _npcs = [
      NpcComponent(
        id: '$courseId.teacher1',
        displayName: 'Teacher 1',
        position: _oldWorldPosition(9, 26),
        map: _map,
        patrolWaypoints: [
          _oldWorldPosition(9, 26),
          _oldWorldPosition(12, 26),
        ],
      ),
      NpcComponent(
        id: '$courseId.teacher2',
        displayName: 'Teacher 2',
        position: _oldWorldPosition(41, 26),
        map: _map,
        patrolWaypoints: [
          _oldWorldPosition(41, 26),
          _oldWorldPosition(38, 26),
        ],
      ),
      NpcComponent(
        id: '$courseId.instructor',
        displayName: instructorName,
        position: _oldWorldPosition(25, 9),
        isInstructor: true,
        map: _map,
        patrolWaypoints: [
          _oldWorldPosition(25, 9),
          _oldWorldPosition(29, 9),
        ],
      ),
      NpcComponent(
        id: '$courseId.principal',
        displayName: 'Principal',
        position: _oldWorldPosition(24, 41),
        map: _map,
        patrolWaypoints: [
          _oldWorldPosition(24, 41),
          _oldWorldPosition(27, 41),
        ],
      ),
      // Reuse the available teacher portraits until student art is added.
      NpcComponent(
        id: '$courseId.student.1',
        displayName: 'Student',
        position: _oldWorldPosition(9, 22),
        isInteractable: false,
        portraitFile: 'Teacher1.png',
      ),
      NpcComponent(
        id: '$courseId.student.2',
        displayName: 'Student',
        position: _oldWorldPosition(12, 22),
        isInteractable: false,
        portraitFile: 'Teacher2.png',
      ),
      NpcComponent(
        id: '$courseId.student.3',
        displayName: 'Student',
        position: _oldWorldPosition(16, 22),
        isInteractable: false,
        portraitFile: 'Teacher3.png',
      ),
      NpcComponent(
        id: '$courseId.student.4',
        displayName: 'Student',
        position: _oldWorldPosition(36, 22),
        isInteractable: false,
        portraitFile: 'Teacher1.png',
      ),
      NpcComponent(
        id: '$courseId.student.5',
        displayName: 'Student',
        position: _oldWorldPosition(38, 22),
        isInteractable: false,
        portraitFile: 'Teacher2.png',
      ),
      NpcComponent(
        id: '$courseId.student.6',
        displayName: 'Student',
        position: _oldWorldPosition(40, 22),
        isInteractable: false,
        portraitFile: 'Teacher3.png',
      ),
    ];
    _player.npcs = _npcs; // let the player collide with NPCs
    for (final NpcComponent npc in _npcs) {
      npc.isBlockedByActor = (Vector2 nextPosition) {
        return _isBlockedByAnotherActor(npc, nextPosition);
      };
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

  bool _isBlockedByAnotherActor(
    NpcComponent movingNpc,
    Vector2 nextPosition,
  ) {
    final double playerMinimumDistance =
        (movingNpc.size.x + _player.size.x) / 2;
    if (nextPosition.distanceTo(_player.position) < playerMinimumDistance) {
      return true;
    }

    for (final NpcComponent otherNpc in _npcs) {
      if (otherNpc == movingNpc) continue;
      final double npcMinimumDistance =
          (movingNpc.size.x + otherNpc.size.x) / 2;
      if (nextPosition.distanceTo(otherNpc.position) < npcMinimumDistance) {
        return true;
      }
    }

    return false;
  }

  void setNpcMovementPaused(bool paused) {
    for (final NpcComponent npc in _npcs) {
      npc.movementPaused = paused;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _refreshNearby();
  }

  /// Works out what the player is next to and updates [nearby] if it changed.
  void _refreshNearby() {
    final Vector2 playerPosition = _player.position;

    // Books take priority over NPCs.
    for (final Component child in world.children) {
      if (child is CollectibleBook && child.isPlayerInRange(playerPosition)) {
        _setNearby(NearbyTarget.book(child));
        return;
      }
    }

    // Any NPC can be talked to, not just the instructor.
    for (final NpcComponent npc in _npcs) {
      if (!npc.isInteractable) continue;
      if (npc.isPlayerInRange(playerPosition)) {
        _setNearby(NearbyTarget.npc(npc));
        return;
      }
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
