import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_app/rain_drop.dart';
import 'package:flutter/animation.dart';

import 'dynamic_island_button.dart';

class RainEffect extends FlameGame
    with HasGameRef<FlameGame>, HasCollisionDetection, TapDetector {
  late SpriteSheet rainSprite;
  var isRaining = true;
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    // on load run once
    // load rain splash effect randomly with sprite sheet
    // on object collosion hide the rain drop and run sprite sheet instead

    rainSprite = SpriteSheet(
      image: await images.load('rain_effect.png'),
      srcSize: Vector2(1024.0, 60.0),
    );
    final spriteSize = Vector2(256.0, 240.0);

    final animation = rainSprite.createAnimation(row: 0, stepTime: 0.1, to: 4);
    final rainComponent = SpriteAnimationComponent(
      animation: animation,
      scale: Vector2(3.5, 3.5),
      size: spriteSize,
    );

    add(ScreenHitbox());
    // add(DynamicIslandButton());
    // add(rainComponent);
  }

  @override
  Future<void> onTapDown(TapDownInfo info) async {
    while (true) {
      final randomX = Random();
      final xPos = randomX.nextDouble() * gameRef.size.x;
      final position = Vector2(xPos, 0);
      add(RainDrop(position));
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }
}
