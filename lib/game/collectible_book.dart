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
  final void Function(CollectibleBook book) onCollected;

  double pickupRadius = AppTheme.tileSize;
  bool _collected = false;

  final Paint _paint = Paint()..color = AppTheme.ivy;

  bool isPlayerInRange(Vector2 playerPosition) =>
      !_collected && playerPosition.distanceTo(position) <= pickupRadius;

  void collect() {
    if (_collected) return;
    _collected = true;
    onCollected(this);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
