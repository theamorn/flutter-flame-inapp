import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/widgets.dart';
import 'package:flame_app/rain_particle.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

enum ButtonState { unpressed, pressed }

class DynamicIslandButton extends SpriteGroupComponent<ButtonState>
    with HasGameRef<RainEffect>, Tappable {
  @override
  Future<void> onLoad() async {
    final pressedSprite = await gameRef.loadSprite(
      'buttons.png',
      srcPosition: Vector2(0, 20),
      srcSize: Vector2(60, 20),
    );
    final unpressedSprite = await gameRef.loadSprite(
      'buttons.png',
      srcSize: Vector2(60, 20),
    );

    add(TextComponent(
        text: 'Sign in',
        textRenderer:
            TextPaint(style: TextStyle(color: BasicPalette.white.color)))
      ..anchor = Anchor.center
      ..x = size.x / 2
      ..y = size.y / 2);

    sprites = {
      ButtonState.pressed: pressedSprite,
      ButtonState.unpressed: unpressedSprite,
    };

    current = ButtonState.unpressed;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    current = ButtonState.unpressed;
    return true;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    current = ButtonState.pressed;
    return true;
  }
}
