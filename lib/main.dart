import 'dart:async';
import 'dart:ui' as ui;

import 'package:after_layout/after_layout.dart';
import 'package:flame/game.dart';
import 'package:flame_app/action_button.dart';
import 'package:flame_app/rain_particle.dart';
import 'package:flame_app/water.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sprite_sheet.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vec;

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
    // canvas.translate(size.width, size.height);
    // canvas.rotate(180 * vec.degrees2Radians);
    // canvas.drawRect(
    //   Rect.fromLTWH(0, 0, size.width, size.height),
    //   Paint()..shader = shader,
    // );
    // canvas
    //   ..translate(size.width, size.height)
    //   ..rotate(180 * degrees2Radians)
    //   ..drawRect(
    //     Offset.zero & size,
    //     Paint()..shader = shader,
    //   );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  double maxWidth = 0.0;
  double maxHeight = 0.0;
  late RainEffect game;
  late Timer timer;
  double delta = 0;
  late Water waterGame;
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    game = RainEffect();
    waterGame = Water();
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        delta += 1 / 60;
      });
    });
  }

  @override
  Future<FutureOr<void>> afterFirstLayout(BuildContext context) async {
    final imageData = await rootBundle.load('assets/images/street.jpg');
    image = await decodeImageFromList(imageData.buffer.asUint8List());

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
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Water'),
    //   ),
    //   body: GameWidget(game: waterGame),
    //   floatingActionButton: Column(
    //     mainAxisAlignment: MainAxisAlignment.end,
    //     crossAxisAlignment: CrossAxisAlignment.end,
    //     children: [
    //       FloatingActionButton(
    //         heroTag: Object(),
    //         onPressed: () => waterGame.seaHeight += 0.1,
    //         child: const Icon(Icons.add),
    //       ),
    //       const SizedBox(height: 8),
    //       FloatingActionButton(
    //         heroTag: Object(),
    //         onPressed: () => waterGame.seaHeight -= 0.1,
    //         child: const Icon(Icons.remove),
    //       ),
    //     ],
    //   ),
    // );
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
                  //   height: 300,
                  //   child: ShaderBuilder((context, shader, child) {
                  //     final size = MediaQuery.sizeOf(context);
                  //     shader.setFloat(0, size.width);
                  //     shader.setFloat(1, size.height);
                  //     shader.setFloat(2, delta);
                  //     // shader.setFloat(3, 0.5);
                  //     return CustomPaint(
                  //       size: MediaQuery.of(context).size,
                  //       painter: ShaderPainter(shader: shader, time: delta),
                  //     );
                  //   },
                  //       assetKey: 'shaders/wave.frag',
                  //       child: const Center(
                  //         child: CircularProgressIndicator(),
                  //       )),
                  // ),
                  SizedBox(
                    height: 700,
                    child: ShaderBuilder((context, shader, child) {
                      final size = MediaQuery.sizeOf(context);
                      shader.setFloat(0, size.width);
                      shader.setFloat(1, size.height);
                      shader.setFloat(2, delta);
                      // shader.setImageSampler(0, image!);
                      // shader.setFloat(3, 0.5);
                      return CustomPaint(
                        size: MediaQuery.of(context).size,
                        painter: ShaderPainter(shader: shader, time: delta),
                      );
                    },
                        assetKey: 'shaders/ball.frag',
                        child: const Center(
                          child: CircularProgressIndicator(),
                        )),
                  ),
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
                  // SizedBox(height: 1000, child: GameWidget(game: waterGame)),
                  // ShaderBuilder((context, shader, child) {
                  //   final size = MediaQuery.sizeOf(context);
                  //   shader.setFloat(0, size.width);
                  //   shader.setFloat(1, size.height);
                  //   shader.setFloat(2, delta);
                  //   shader.setFloat(3, 0.5);
                  //   return CustomPaint(
                  //     size: const Size(double.infinity, 600),
                  //     painter: ShaderPainter(shader: shader, time: delta),
                  //   );
                  // },
                  //     assetKey: 'shaders/water.glsl',
                  //     child: const Center(
                  //       child: CircularProgressIndicator(),
                  //     )),

                  // SizedBox(
                  //   height: 1000,
                  //   child: ShaderBuilder(
                  //       (context, shader, child) => CustomPaint(
                  //             size: MediaQuery.of(context).size,
                  //             painter:
                  //                 ShaderPainter(shader: shader, time: delta),
                  //           ),
                  //       assetKey: 'shaders/sun.frag',
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
                  //       assetKey: 'shaders/star.frag',
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
                  //       assetKey: 'shaders/wave.frag',
                  //       child: const Center(
                  //         child: CircularProgressIndicator(),
                  //       )),
                  // ),

                  // Expanded(
                  //     child: GameWidget<RainEffect>(
                  //         game: game,
                  //         overlayBuilderMap: {
                  //       'userArea': (ctx, game) {
                  //         return const Padding(
                  //             padding: EdgeInsets.symmetric(horizontal: 80),
                  //             child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   TextField(
                  //                       decoration: InputDecoration(
                  //                           filled: true,
                  //                           fillColor: Colors.white,
                  //                           hintText: 'Username')),
                  //                   TextField(
                  //                       decoration: InputDecoration(
                  //                           filled: true,
                  //                           fillColor: Colors.white,
                  //                           hintText: 'Password'))
                  //                 ]));
                  //       },
                  //       'container1': (ctx, game) {
                  //         return ActionButtonWidget(Colors.blueAccent,
                  //             "Sign in", Alignment.bottomCenter, () {
                  //           print(
                  //               "=== This is Flutter widget inside Flutter Flame ===");
                  //         });
                  //       },
                  //     },
                  //         initialActiveOverlays: const [
                  //       'userArea',
                  //       'container1'
                  //     ])),
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Container(
                  //       decoration: BoxDecoration(
                  //         border: Border.all(color: Colors.blueAccent.shade400),
                  //         color: Colors.white,
                  //       ),
                  //       height: 200,
                  //     ),
                  //     ActionButtonWidget(
                  //         Colors.redAccent, "Sign out", Alignment.bottomCenter,
                  //         () {
                  //       print("=== This is normal Flutter widget ===");
                  //     })
                  //   ],
                  // ),
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
