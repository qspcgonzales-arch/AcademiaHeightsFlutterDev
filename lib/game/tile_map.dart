import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Draws the tile grid and answers "is this spot blocked?" questions.
///
/// The grid is a list of rows, and each row is a list of numbers
/// (`List<List<int>>`). `0` means the player can walk there; any other
/// number means it's blocked (a wall, a tree, etc). This is the Module 4
/// "arrays + loops" part of the project.
class TileMapComponent extends PositionComponent {
  TileMapComponent({required this.grid}) : super(size: _pixelSize(grid));

  /// Loads the original 50 by 50 map used by the Java project.
  static Future<TileMapComponent> fromOldProject() async {
    final String mapText = await rootBundle.loadString(
      'AcademiaHeightsGame(FINALS)2/res/maps/worldV3.txt',
    );
    final List<List<int>> grid = [];
    final List<String> lines = mapText.split('\n');

    for (final String line in lines) {
      final String trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final List<String> values = trimmedLine.split(RegExp(r'\s+'));
      final List<int> row = [];
      for (final String value in values) {
        row.add(int.parse(value));
      }
      grid.add(row);
    }

    if (grid.length != 50 || grid[0].length != 50) {
      throw StateError('The old project map must contain 50 rows of 50 tiles.');
    }

    return TileMapComponent(grid: grid);
  }

  final List<List<int>> grid;

  int get rows => grid.length;
  int get columns => grid[0].length;
  double get tileSize => AppTheme.tileSize;

  final Map<int, Sprite> _sprites = {};

  // These are the tile IDs marked as collidable in the old Java TileManager.
  static const Set<int> _collisionTileIds = {
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
  };

  static const Map<int, String> _tileNames = {
    0: 'grass',
    1: 'grass',
    2: 'grass',
    3: 'grass',
    4: 'grass',
    5: 'grass',
    6: 'grass',
    7: 'grass',
    8: 'grass',
    9: 'grass',
    10: 'grass',
    11: 'grassUL',
    12: 'grassU',
    13: 'grassUR',
    14: 'grassL',
    15: 'grassR',
    16: 'grassBL',
    17: 'grassBR',
    18: 'grassUL',
    19: 'Wall',
    20: 'wallUL',
    21: 'WallU',
    22: 'WallUR',
    23: 'WallL',
    24: 'WallR',
    25: 'WallBL',
    26: 'WallB',
    27: 'WallBR',
    28: 'Stone',
    29: 'StoneUL',
    30: 'StoneU',
    31: 'StoneUR',
    32: 'StoneL',
    33: 'StoneR',
    34: 'StoneBL',
    35: 'StoneB',
    36: 'StoneBR',
    37: 'Break',
    38: 'BreakUL',
    39: 'BreakU',
    40: 'BreakUR',
    41: 'BreakL',
    42: 'BreakR',
    43: 'BreakBL',
    44: 'BreakB',
    45: 'BreakBR',
    46: 'treeL',
    47: 'treeLR',
    48: 'treeLV',
    49: 'treeS',
    50: 'treeSR',
    51: 'treeSV',
    52: 'tree00',
    53: 'tree01',
    54: 'tree02',
    55: 'tree03',
    56: 'tree04',
    57: 'tree05',
    58: 'tree06',
    59: 'tree07',
    60: 'tree08',
    61: 'tri-tree',
    62: 'cir-tree',
    63: 'ChairD',
    64: 'ChairU',
    65: 'ChairL',
    66: 'ChairR',
    67: 'CabinetD',
    68: 'CabinetR',
    69: 'CabinetL',
    70: 'RoundTU',
    71: 'RoundTD',
    72: 'RoundTL',
    73: 'RoundTR',
    74: 'BoxTU',
    75: 'BoxTD',
    76: 'BoxTL',
    77: 'BoxTR',
    78: 'BlueChairUL',
    79: 'BlueChairUR',
    80: 'BlueChairDL',
    81: 'BlueChairDR',
    82: 'BlueChairL',
    83: 'BlueChairR',
    84: 'bush',
    85: 'BooksD',
    86: 'BooksL',
    87: 'BooksR',
    88: 'BooksU',
  };

  /// Total map size in pixels, from the number of rows and columns.
  static Vector2 _pixelSize(List<List<int>> grid) {
    final int rows = grid.length;
    final int columns = grid[0].length;
    return Vector2(columns * AppTheme.tileSize, rows * AppTheme.tileSize);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (final MapEntry<int, String> entry in _tileNames.entries) {
      _sprites[entry.key] = await Sprite.load('tiles/${entry.value}.png');
    }
  }

  /// True if the cell is a wall, or outside the map.
  bool isBlockedCell(int row, int column) {
    if (row < 0 || row >= rows) return true;
    if (column < 0 || column >= columns) return true;
    return _collisionTileIds.contains(grid[row][column]);
  }

  /// True if a box (given by its top-left corner and size, in pixels)
  /// overlaps any blocked cell.
  bool collidesWithBox(Vector2 topLeft, Vector2 boxSize) {
    final int firstColumn = (topLeft.x / tileSize).floor();
    final int lastColumn = ((topLeft.x + boxSize.x) / tileSize).floor();
    final int firstRow = (topLeft.y / tileSize).floor();
    final int lastRow = ((topLeft.y + boxSize.y) / tileSize).floor();

    for (int row = firstRow; row <= lastRow; row++) {
      for (int column = firstColumn; column <= lastColumn; column++) {
        if (isBlockedCell(row, column)) return true;
      }
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        final Vector2 cellPosition = Vector2(column * tileSize, row * tileSize);
        final Sprite tileSprite = _sprites[grid[row][column]]!;
        tileSprite.render(
          canvas,
          position: cellPosition,
          size: Vector2.all(tileSize),
        );
      }
    }
  }
}

/// The pixel position of the center of tile ([column], [row]). Use this for
/// anything placed by tile coordinates because centered components expect a
/// center point, not a tile's top-left corner.
Vector2 tileCenter(int column, int row) {
  return Vector2(
    (column + 0.5) * AppTheme.tileSize,
    (row + 0.5) * AppTheme.tileSize,
  );
}
