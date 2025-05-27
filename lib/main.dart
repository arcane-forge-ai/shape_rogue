import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/circle_rouge_game.dart';

void main() {
  runApp(const CircleRougeApp());
}

class CircleRougeApp extends StatelessWidget {
  const CircleRougeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circle Rouge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: CircleRougeGame.arenaWidth,
            height: CircleRougeGame.arenaHeight,
            child: GameWidget<CircleRougeGame>.controlled(
              gameFactory: CircleRougeGame.new,
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
