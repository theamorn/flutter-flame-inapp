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
// Check Circles, Boundcing Ball, Widget in Forge2DGame
// add splash of raindrop - use sprite sheet to replace with that position, play once and remove
// add feedback or animation to show that we can do callback
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: false,
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
  late RainEffect game;

  @override
  void initState() {
    super.initState();
    game = RainEffect();
  }

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
                      child: GameWidget<
                          RainEffect>(game: game, overlayBuilderMap: {
                    'userArea': (ctx, game) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                TextField(
                                    decoration:
                                        InputDecoration(hintText: 'Username')),
                                TextField(
                                    decoration:
                                        InputDecoration(hintText: 'Password'))
                              ]));
                    },
                    'container1': (ctx, game) {
                      return ActionButtonWidget(game, 1, Colors.blueAccent,
                          "Sign in", Alignment.bottomCenter, () {
                        print("=== Widget inside Flutter Flame ===");
                      });
                    },
                  }, initialActiveOverlays: const [
                    'userArea',
                    'container1'
                  ])),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent.shade400),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        width: 300,
                        height: 200,
                      ),
                      ActionButtonWidget(game, 2, Colors.redAccent, "Sign out",
                          Alignment.bottomCenter, () {
                        print("=== Normal Widget in Flutter ===");
                      })
                    ],
                  ),
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
