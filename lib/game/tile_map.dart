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
  TileMapComponent({required this.grid})
      : super(size: _pixelSize(grid));

  final List<List<int>> grid;

  int get rows => grid.length;
  int get columns => grid[0].length;
  double get tileSize => AppTheme.tileSize;

  /// Total map size in pixels, from the number of rows and columns.
  static Vector2 _pixelSize(List<List<int>> grid) {
    final int rows = grid.length;
    final int columns = grid[0].length;
    return Vector2(columns * AppTheme.tileSize, rows * AppTheme.tileSize);
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
    final Paint walkablePaint = Paint();
    walkablePaint.color = AppTheme.chalkboard.withValues(alpha: 0.35);

    final Paint blockedPaint = Paint();
    blockedPaint.color = AppTheme.ink;

    final Paint gridLinePaint = Paint();
    gridLinePaint.color = Colors.white.withValues(alpha: 0.05);
    gridLinePaint.style = PaintingStyle.stroke;

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        final Rect cell = Rect.fromLTWH(
          column * tileSize,
          row * tileSize,
          tileSize,
          tileSize,
        );

        if (grid[row][column] == 0) {
          canvas.drawRect(cell, walkablePaint);
        } else {
          canvas.drawRect(cell, blockedPaint);
        }
        canvas.drawRect(cell, gridLinePaint);
      }
    }
  }
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
  final bool onEdge = row == 0 ||
      column == 0 ||
      row == rows - 1 ||
      column == columns - 1;
  if (onEdge) return 1;

  final bool onHorizontalWall = row == 5 && column >= 6 && column <= 12;
  final bool onVerticalWall = column == 14 && row >= 3 && row <= 9;
  if (onHorizontalWall || onVerticalWall) return 1;

  return 0;
}
