import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class RainDrop extends PositionComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  late Vector2 velocity;
  late ShapeHitbox hitbox;
  final _defaultColor = Colors.blueAccent.shade100;
  final gravity = 9.8;

  RainDrop(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(5),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.fill;

    hitbox = CircleHitbox()
      ..paint = defaultPaint
      ..renderShape = true;

    add(hitbox);

    final center = gameRef.size / 2;
    velocity = (center - position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += gravity;
    position.y += velocity.y * dt;
  }

  // @override
  // void onCollisionStart(
  //   Set<Vector2> intersectionPoints,
  //   PositionComponent other,
  // ) {
  //   super.onCollisionStart(intersectionPoints, other);
  //   hitbox.paint.color = _collisionColor;
  //   if (other is ScreenHitbox) {
  //     removeFromParent();
  //     return;
  //   }
  // }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is ScreenHitbox) {
      final collisionPoint = intersectionPoints.first;
      if (collisionPoint.x == 0) {
        // splash image random with sprite sheet
        // removeFromParent();
        velocity.x = -velocity.x;
        velocity.y = velocity.y;
      }

      if (collisionPoint.x.floor() == gameRef.size.x.floor()) {
        removeFromParent();
      }

      if (collisionPoint.y == 0) {
        removeFromParent();
      }

      if (collisionPoint.y.floor() == gameRef.size.y.floor()) {
        removeFromParent();
      }
    }
  }
}
