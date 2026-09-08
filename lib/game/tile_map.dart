import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Renders a tile grid and answers collision queries.
///
/// The grid is `List<List<int>>`, row-major. `0` is walkable; any non-zero
/// value is blocked (later: mapped to a specific tile sprite). Loops iterate
/// rows/columns — this is the Module 4 "arrays + loops" piece.
class TileMapComponent extends PositionComponent {
  TileMapComponent({required this.grid})
      : assert(grid.isNotEmpty && grid.first.isNotEmpty, 'grid must be non-empty'),
        super(
          size: Vector2(
            grid.first.length * AppTheme.tileSize,
            grid.length * AppTheme.tileSize,
          ),
        );

  final List<List<int>> grid;

  int get rows => grid.length;
  int get columns => grid.first.length;
  double get tile => AppTheme.tileSize;

  bool isBlockedAtCell(int row, int column) {
    if (row < 0 || column < 0 || row >= rows || column >= columns) return true;
    return grid[row][column] != 0;
  }

  bool isBlockedAtPoint(Vector2 worldPoint) {
    final column = (worldPoint.x / tile).floor();
    final row = (worldPoint.y / tile).floor();
    return isBlockedAtCell(row, column);
  }

  /// True if an axis-aligned box (in world space) overlaps any blocked tile.
  bool collidesWithBox(Vector2 topLeft, Vector2 boxSize) {
    final firstColumn = (topLeft.x / tile).floor();
    final lastColumn = ((topLeft.x + boxSize.x) / tile).floor();
    final firstRow = (topLeft.y / tile).floor();
    final lastRow = ((topLeft.y + boxSize.y) / tile).floor();
    for (var row = firstRow; row <= lastRow; row++) {
      for (var column = firstColumn; column <= lastColumn; column++) {
        if (isBlockedAtCell(row, column)) return true;
      }
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    final walkable = Paint()..color = AppTheme.chalkboard.withValues(alpha: 0.35);
    final blocked = Paint()..color = AppTheme.ink;
    final gridLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final rect = Rect.fromLTWH(
          column * tile,
          row * tile,
          tile,
          tile,
        );
        canvas.drawRect(rect, grid[row][column] == 0 ? walkable : blocked);
        canvas.drawRect(rect, gridLine);
      }
    }
  }
}

/// A small hand-authored placeholder map (border wall + a couple of blocks).
/// Real maps come from Tiled in M1.
List<List<int>> demoGrid() {
  const rows = 14;
  const columns = 20;
  return List.generate(rows, (row) {
    return List.generate(columns, (column) {
      final onBorder =
          row == 0 || column == 0 || row == rows - 1 || column == columns - 1;
      if (onBorder) return 1;
      if ((row == 5 && column >= 6 && column <= 12) ||
          (column == 14 && row >= 3 && row <= 9)) {
        return 1;
      }
      return 0;
    });
  });
}
