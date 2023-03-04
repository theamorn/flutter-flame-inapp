import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flame_app/action_button.dart';
import 'package:flame_app/rain_particle.dart';
import 'package:flutter/material.dart';
import 'sprite_sheet.dart';

void main() {
  runApp(const MyApp());
}

// TODO
// create rain effect - done
// create rain drop from random - done
// add collosion of raindrop to UI - find the way to has collionsion detection on overlayui, if not need to create own sprite button to interact with it
// seem like you need to create flame button and make collision instead using flutter widget ->
// Check Circles, Boundcing Ball, Widget in Forge2DGame
// add splash of raindrop - use sprite sheet to replace with that position, play once and remove
// add feedback or animation to show that we can do callback
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double maxWidth = 0.0;
  double maxHeight = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    final height = AppBar().preferredSize.height;
    maxWidth = size.width;
    maxHeight = size.height - height;
  }

  @override
  Widget build(BuildContext context) {
    final game = RainEffect();
    return Stack(children: [
      Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: GameWidget<RainEffect>(
                    game: game,
                    overlayBuilderMap: {
                      'container1': (ctx, game) {
                        return ActionButtonWidget(game, 1, Colors.blueAccent,
                            "Sign in", Alignment.center, () {
                          print("=== press ===");
                        });
                      },
                      'button1': (ctx, game) {
                        return ActionButtonWidget(game, 2, Colors.redAccent,
                            "Sign out", Alignment.bottomCenter, () {
                          print("=== press ===");
                        });
                      },
                    },
                    initialActiveOverlays: const ['button1', 'container1'],
                  )),
                ],
              ),
            ),
          )),
      SizedBox(
          width: 12,
          height: 12,
          child: Align(
              alignment: Alignment.topCenter,
              child: GameWidget(game: SpriteSheetWidget()))),
    ]);
  }
}
