import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_app/rain_drop.dart';
import 'package:flutter/animation.dart';

class DropSplash extends FlameGame {
  final Vector2 position;

  DropSplash(this.position) : super();

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('drop_splash.png'),
      srcSize: Vector2(85.0, 90.0),
    );
    final spriteSize = Vector2(85.0, 90.0);

    final animation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 12);
    final component1 = SpriteAnimationComponent(
        animation: animation,
        position: position,
        size: spriteSize,
        removeOnFinish: false);

    add(component1);
  }
}
