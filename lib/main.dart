import 'dart:async';
import 'dart:ui' as ui;

import 'package:after_layout/after_layout.dart';
import 'package:flame/game.dart';
import 'package:flame_app/action_button.dart';
import 'package:flame_app/rain_particle.dart';
import 'package:flutter/material.dart';
import 'sprite_sheet.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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

class ShaderPainter extends CustomPainter {
  ShaderPainter({required this.shader, required this.time});
  ui.FragmentShader shader;
  final double time;
  double seaHeight = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    // shader.setFloat(3, seaHeight.clamp(0, 1));

    paint.shader = shader;

    // canvas
    //   ..translate(size.width, size.height)
    //   ..rotate(180 * degrees2Radians)
    //   ..drawRect(
    //     Rect.fromLTWH(0, 0, size.width, size.height),
    //     Paint()..shader = shader,
    //   );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  double maxWidth = 0.0;
  double maxHeight = 0.0;
  late RainEffect game;
  late Timer timer;
  double delta = 0;

  @override
  void initState() {
    super.initState();
    game = RainEffect();
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        delta += 1 / 60;
      });
    });
  }

  @override
  Future<FutureOr<void>> afterFirstLayout(BuildContext context) async {
    // final program = await ui.FragmentProgram.fromAsset('shaders/myshader.frag');
  }

  void updateShader(Canvas canvas, Rect rect, ui.FragmentProgram program) {
    var shader = program.fragmentShader();
    shader.setFloat(0, 42.0);
    canvas.drawRect(rect, Paint()..shader = shader);
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
                  // SizedBox(
                  //   height: 1000,
                  //   child: ShaderBuilder(
                  //       (context, shader, child) => CustomPaint(
                  //             size: MediaQuery.of(context).size,
                  //             painter:
                  //                 ShaderPainter(shader: shader, time: delta),
                  //           ),
                  //       assetKey: 'shaders/myshader.frag',
                  //       child: const Center(
                  //         child: CircularProgressIndicator(),
                  //       )),
                  // ),
                  // SizedBox(
                  //   height: 200,
                  //   child: ShaderBuilder(
                  //       (context, shader, child) => CustomPaint(
                  //             size: MediaQuery.of(context).size,
                  //             painter:
                  //                 ShaderPainter(shader: shader, time: delta),
                  //           ),
                  //       assetKey: 'shaders/rain.frag',
                  //       child: const Center(
                  //         child: CircularProgressIndicator(),
                  //       )),
                  // ),
                  SizedBox(
                    height: 200,
                    child: ShaderBuilder(
                        (context, shader, child) => CustomPaint(
                              size: MediaQuery.of(context).size,
                              painter:
                                  ShaderPainter(shader: shader, time: delta),
                            ),
                        assetKey: 'shaders/snow.frag',
                        child: const Center(
                          child: CircularProgressIndicator(),
                        )),
                  ),
                  SizedBox(
                    height: 200,
                    child: ShaderBuilder(
                        (context, shader, child) => CustomPaint(
                              size: MediaQuery.of(context).size,
                              painter:
                                  ShaderPainter(shader: shader, time: delta),
                            ),
                        assetKey: 'shaders/star.frag',
                        child: const Center(
                          child: CircularProgressIndicator(),
                        )),
                  ),
                  SizedBox(
                    height: 200,
                    child: ShaderBuilder(
                        (context, shader, child) => CustomPaint(
                              size: MediaQuery.of(context).size,
                              painter:
                                  ShaderPainter(shader: shader, time: delta),
                            ),
                        assetKey: 'shaders/wave.frag',
                        child: const Center(
                          child: CircularProgressIndicator(),
                        )),
                  ),

                  Expanded(
                      child: GameWidget<RainEffect>(
                          game: game,
                          overlayBuilderMap: {
                        'userArea': (ctx, game) {
                          return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 80),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
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
