import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A study-material book on the map. Walk near it and tap interact to
/// collect it. `onCollected` is called once, then the component removes
/// itself.
class CollectibleBook extends PositionComponent {
  CollectibleBook({
    required this.id,
    required this.topic,
    required Vector2 position,
    required this.onCollected,
  }) : super(
          position: position,
          size: Vector2.all(AppTheme.tileSize * 0.5),
          anchor: Anchor.center,
        );

  final String id;
  final String topic;

  /// The game gives us a function to call when this book is picked up.
  final void Function(CollectibleBook book) onCollected;

  /// How close (in pixels) the player must be to pick it up.
  double pickupRadius = AppTheme.tileSize;

  bool _collected = false;

  // "..color =" sets the colour on the new Paint and keeps the Paint.
  final Paint _paint = Paint()..color = AppTheme.ivy;

  bool isPlayerInRange(Vector2 playerPosition) {
    if (_collected) return false;
    final double distance = playerPosition.distanceTo(position);
    return distance <= pickupRadius;
  }

  void collect() {
    if (_collected) return;
    _collected = true;
    onCollected(this);
    removeFromParent(); // take the book off the map
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
