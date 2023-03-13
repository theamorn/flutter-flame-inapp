import 'package:flame_app/rain_particle.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ActionButtonWidget extends StatefulWidget {
  final RainEffect _game;
  final int _bodyId;
  final VoidCallback onPressed;
  final String title;
  final MaterialAccentColor color;
  final Alignment align;

  const ActionButtonWidget(
    this._game,
    this._bodyId,
    this.color,
    this.title,
    this.align,
    this.onPressed, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButtonWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: widget.align,
        child: SizedBox(
            width: 100,
            child: TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(widget.color.shade200),
                    foregroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () {
                  widget.onPressed();
                },
                child: Text(widget.title))));
  }
}
