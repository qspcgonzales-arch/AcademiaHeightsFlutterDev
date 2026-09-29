import 'package:academia_heights/game/npc.dart';
import 'package:academia_heights/game/tile_map.dart';
import 'package:academia_heights/theme/app_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('patrol moves toward its next waypoint', () {
    final TileMapComponent map = TileMapComponent(grid: _openGrid());
    final NpcComponent npc = NpcComponent(
      id: 'teacher.test',
      displayName: 'Teacher',
      position: Vector2(72, 72),
      map: map,
      patrolWaypoints: [Vector2(72, 72), Vector2(168, 72)],
      patrolSpeed: 36,
      pauseAtWaypoint: 0,
    );

    npc.update(1);

    expect(npc.position.x, 108);
    expect(npc.position.y, 72);
  });

  test('paused NPC does not move', () {
    final TileMapComponent map = TileMapComponent(grid: _openGrid());
    final NpcComponent npc = NpcComponent(
      id: 'teacher.test',
      displayName: 'Teacher',
      position: Vector2(72, 72),
      map: map,
      patrolWaypoints: [Vector2(72, 72), Vector2(168, 72)],
      patrolSpeed: 36,
    );
    npc.movementPaused = true;

    npc.update(1);

    expect(npc.position.x, 72);
    expect(npc.position.y, 72);
  });

  test('patrol stops before entering a blocked map cell', () {
    final List<List<int>> grid = _openGrid();
    grid[1][2] = 20;
    final TileMapComponent map = TileMapComponent(grid: grid);
    final NpcComponent npc = NpcComponent(
      id: 'teacher.test',
      displayName: 'Teacher',
      position: Vector2(72, 72),
      map: map,
      patrolWaypoints: [Vector2(72, 72), Vector2(168, 72)],
      patrolSpeed: 36,
      pauseAtWaypoint: 0,
    );

    npc.update(1);

    expect(npc.position.x, 72);
    expect(npc.position.y, 72);
  });

  test('ambient NPC can be marked non-interactive', () {
    final NpcComponent student = NpcComponent(
      id: 'student.test',
      displayName: 'Student',
      position: Vector2(72, 72),
      isInteractable: false,
    );

    expect(student.isInteractable, isFalse);
  });

  test('school NPC positions and patrol lanes are clear on the campus map',
      () async {
    final TileMapComponent map = await TileMapComponent.fromOldProject();
    final List<Vector2> studentPositions = [
      tileCenter(9, 22),
      tileCenter(12, 22),
      tileCenter(16, 22),
      tileCenter(36, 22),
      tileCenter(38, 22),
      tileCenter(40, 22),
    ];

    for (final Vector2 position in studentPositions) {
      final Vector2 topLeft =
          position - (Vector2.all(AppTheme.tileSize * 0.9) / 2);
      expect(map.collidesWithBox(topLeft, Vector2.all(AppTheme.tileSize * 0.9)),
          isFalse);
    }

    _expectClearLane(map, 26, 9, 12);
    _expectClearLane(map, 26, 38, 41);
    _expectClearLane(map, 9, 25, 29);
    _expectClearLane(map, 41, 24, 27);
  });
}

void _expectClearLane(
  TileMapComponent map,
  int row,
  int firstColumn,
  int lastColumn,
) {
  for (int column = firstColumn; column <= lastColumn; column++) {
    final Vector2 position = tileCenter(column, row);
    final Vector2 npcSize = Vector2.all(AppTheme.tileSize * 0.9);
    final Vector2 topLeft = position - (npcSize / 2);
    expect(
      map.collidesWithBox(topLeft, npcSize),
      isFalse,
      reason: 'NPC lane crosses a blocked tile at row $row, column $column',
    );
  }
}

List<List<int>> _openGrid() {
  final List<List<int>> grid = [];
  for (int row = 0; row < 8; row++) {
    final List<int> cells = [];
    for (int column = 0; column < 8; column++) {
      cells.add(0);
    }
    grid.add(cells);
  }
  return grid;
}
