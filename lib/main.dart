import 'package:flame/game.dart';
import 'package:flame_app/action_button.dart';
import 'package:flame_app/rain_particle.dart';
import 'package:flutter/material.dart';
import 'sprite_sheet.dart';

void main() {
  runApp(const MyApp());
}

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
                      child: GameWidget<RainEffect>(
                          game: game,
                          overlayBuilderMap: {
                        'userArea': (ctx, game) {
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 80),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    TextField(
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: 'Username')),
                                    TextField(
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: 'Password'))
                                  ]));
                        },
                        'container1': (ctx, game) {
                          return ActionButtonWidget(Colors.blueAccent,
                              "Sign in", Alignment.bottomCenter, () {
                            print(
                                "=== This is Flutter widget inside Flutter Flame ===");
                          });
                        },
                      },
                          initialActiveOverlays: const [
                        'userArea',
                        'container1'
                      ])),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent.shade400),
                          color: Colors.white,
                        ),
                        height: 200,
                      ),
                      ActionButtonWidget(
                          Colors.redAccent, "Sign out", Alignment.bottomCenter,
                          () {
                        print("=== This is normal Flutter widget ===");
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
