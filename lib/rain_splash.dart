import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class RainSplash extends FlameGame {
  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('splash_ground.png'),
      srcSize: Vector2(50.0, 50.0),
    );
    final spriteSize = Vector2(50.0, 50.0);

    final animation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 60);
    final component1 = SpriteAnimationComponent(
      animation: animation,
      scale: Vector2(0.4, 0.4),
      position: Vector2(160, -5),
      size: spriteSize,
    );

    add(
      component1
        ..add(
          MoveEffect.to(
            Vector2(250, -5),
            EffectController(
              duration: 10,
              reverseDuration: 10,
              infinite: true,
              curve: Curves.linear,
            ),
          ),
        ),
    );
  }
}
