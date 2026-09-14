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

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Six book-cover designs (B1-B6.png); pick one from the book's id so the
    // same book always looks the same.
    final int bookNumber = 1 + (id.hashCode.abs() % 6);
    _sprite = await Sprite.load('books/B$bookNumber.png');
  }

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
    final Sprite? sprite = _sprite;
    if (sprite == null) return; // not loaded yet
    sprite.render(canvas, size: size);
  }
}
