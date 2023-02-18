import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class DynamicIslandButton extends SpriteComponent {
  @override
  void onTapDown(TapDownInfo info) {
    print(info.eventPosition.game);
  }

  @override
  Future<void> onLoad() async {
    final sprite = SpriteButton.asset(
      path: 'buttons.png',
      pressedPath: 'buttons.png',
      srcPosition: Vector2(0, 0),
      srcSize: Vector2(60, 20),
      pressedSrcPosition: Vector2(0, 20),
      pressedSrcSize: Vector2(60, 20),
      onPressed: () {
        // Do something
      },
      label: const Text(
        'Sprite Button',
        style: TextStyle(color: Color(0xFF5D275D)),
      ),
      width: 250,
      height: 75,
    );
  }
}
