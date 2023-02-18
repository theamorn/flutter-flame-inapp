import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flame_app/rain_particle.dart';
import 'package:flutter/material.dart';
import 'sprite_sheet.dart';

void main() {
  runApp(const MyApp());
}

// TODO
// create rain effect - done
// create rain drop from random
// add collosion of raindrop to UI
// add splash of raindrop
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
                      child: GameWidget(
                    game: RainEffect(),
                    overlayBuilderMap: {
                      'container1': (ctx, game) {
                        return Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                width: 300,
                                height: 200,
                              ),
                              Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                      width: 100,
                                      child: TextButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors
                                                          .blueAccent.shade200),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white)),
                                          onPressed: () {
                                            print("==== pressed =====");
                                          },
                                          child: const Text('Sign in'))))
                            ]));
                      },
                      'button1': (ctx, game) {
                        return Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                                width: 100,
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.redAccent.shade200),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white)),
                                    onPressed: () {
                                      print("==== pressed =====");
                                    },
                                    child: const Text('Sign out'))));
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
