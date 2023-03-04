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
  // final SpriteSheetWidget _game;
  // final int _bodyId;
  // Body? _body;

  // _ActionButtonState(this._game, this._bodyId) {
  //   _game.updateStates.add(() {
  //     setState(() {
  //       _body = _game.bodyIdMap[_bodyId];
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final body = widget._bodyId;
    // widget._game.children.first.

    // final bodyPosition = _game.screenPosition(body);
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: widget.color),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: 300,
        height: 200,
      ),
      Align(
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
                  child: Text(widget.title))))
    ]));
    // return Positioned(
    //   top: bodyPosition.y - 18,
    //   left: bodyPosition.x - 90,
    //   child: Transform.rotate(
    //     angle: body.angle,
    //     child: ElevatedButton(
    //       onPressed: () {
    //         setState(
    //           () => body.applyLinearImpulse(Vector2(0.0, 1000)),
    //         );
    //       },
    //       child: const Text(
    //         'Flying button!',
    //         textScaleFactor: 2.0,
    //       ),
    //     ),
    //   ),
    // );
  }
}
