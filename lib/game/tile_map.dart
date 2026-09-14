import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Draws the tile grid and answers "is this spot blocked?" questions.
///
/// The grid is a list of rows, and each row is a list of numbers
/// (`List<List<int>>`). `0` means the player can walk there; any other
/// number means it's blocked (a wall, a tree, etc). This is the Module 4
/// "arrays + loops" part of the project.
class TileMapComponent extends PositionComponent {
  TileMapComponent({required this.grid}) : super(size: _pixelSize(grid));

  final List<List<int>> grid;

  int get rows => grid.length;
  int get columns => grid[0].length;
  double get tileSize => AppTheme.tileSize;

  // The main ground and wall tiles. The old project also contains campus
  // props like trees, stones, and seating, which we render as decorations.
  final Map<String, Sprite> _sprites = {};
  late final List<_MapDecoration> _decorations = [
    const _MapDecoration(row: 2, column: 2, assetName: 'tree00', size: 1.15),
    const _MapDecoration(row: 2, column: 16, assetName: 'tree00', size: 1.1),
    const _MapDecoration(row: 8, column: 4, assetName: 'bush', size: 1.0),
    const _MapDecoration(row: 9, column: 12, assetName: 'stone', size: 1.0),
    const _MapDecoration(row: 7, column: 17, assetName: 'ChairD', size: 0.9),
    const _MapDecoration(row: 10, column: 7, assetName: 'CabinetR', size: 0.9),
    const _MapDecoration(row: 10, column: 14, assetName: 'tree00', size: 1.2),
    const _MapDecoration(row: 11, column: 18, assetName: 'bush', size: 1.0),
  ];

  /// Total map size in pixels, from the number of rows and columns.
  static Vector2 _pixelSize(List<List<int>> grid) {
    final int rows = grid.length;
    final int columns = grid[0].length;
    return Vector2(columns * AppTheme.tileSize, rows * AppTheme.tileSize);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprites['grass'] = await Sprite.load('tiles/grass.png');
    _sprites['wall'] = await Sprite.load('tiles/Wall.png');
    _sprites['tree00'] = await Sprite.load('tiles/tree00.png');
    _sprites['bush'] = await Sprite.load('tiles/bush.png');
    _sprites['stone'] = await Sprite.load('tiles/Stone.png');
    _sprites['ChairD'] = await Sprite.load('tiles/ChairD.png');
    _sprites['CabinetR'] = await Sprite.load('tiles/CabinetR.png');
  }

  /// True if the cell is a wall, or outside the map.
  bool isBlockedCell(int row, int column) {
    if (row < 0 || row >= rows) return true;
    if (column < 0 || column >= columns) return true;
    return grid[row][column] != 0;
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
        final Sprite tileSprite =
            grid[row][column] == 0 ? _sprites['grass']! : _sprites['wall']!;
        tileSprite.render(
          canvas,
          position: cellPosition,
          size: Vector2.all(tileSize),
        );
      }
    }

    for (final decoration in _decorations) {
      final Sprite? sprite = _sprites[decoration.assetName];
      if (sprite == null) continue;

      final Vector2 position = Vector2(
        decoration.column * tileSize + (tileSize / 2),
        decoration.row * tileSize + (tileSize / 2),
      );

      sprite.render(
        canvas,
        position: position,
        size: Vector2.all(tileSize * decoration.size),
        anchor: Anchor.center,
      );
    }
  }
}

class _MapDecoration {
  const _MapDecoration({
    required this.row,
    required this.column,
    required this.assetName,
    required this.size,
  });

  final int row;
  final int column;
  final String assetName;
  final double size;
}

/// A small hand-made placeholder map: a wall around the edge plus two inner
/// walls. Real maps come from Tiled in milestone M1.
List<List<int>> demoGrid() {
  const int rows = 14;
  const int columns = 20;

  final List<List<int>> grid = [];
  for (int row = 0; row < rows; row++) {
    final List<int> rowCells = [];
    for (int column = 0; column < columns; column++) {
      rowCells.add(_demoCell(row, column, rows, columns));
    }
    grid.add(rowCells);
  }
  return grid;
}

/// 1 = wall, 0 = walkable, for the demo map.
int _demoCell(int row, int column, int rows, int columns) {
  final bool onEdge =
      row == 0 || column == 0 || row == rows - 1 || column == columns - 1;
  if (onEdge) return 1;

  final bool onHorizontalWall = row == 5 && column >= 6 && column <= 12;
  final bool onVerticalWall = column == 14 && row >= 3 && row <= 9;
  if (onHorizontalWall || onVerticalWall) return 1;

  return 0;
}
