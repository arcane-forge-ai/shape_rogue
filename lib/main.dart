import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/circle_rouge_game.dart';
import 'overlays/start_menu_overlay.dart';
import 'overlays/hero_selection_overlay.dart';
import 'overlays/pause_menu_overlay.dart';
import 'overlays/game_over_overlay.dart';

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
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            width: 800,
            height: 600,
            child: GameWidget<CircleRougeGame>.controlled(
              gameFactory: () {
                final game = CircleRougeGame();
                game.updateScreenDimensions(800, 600);
                return game;
              },
              overlayBuilderMap: {
                'StartMenu': (context, game) => StartMenuOverlay(game: game),
                'HeroSelection': (context, game) => HeroSelectionOverlay(game: game),
                'PauseMenu': (context, game) => PauseMenuOverlay(game: game),
                'GameOver': (context, game) => GameOverOverlay(game: game, isVictory: false),
                'Victory': (context, game) => GameOverOverlay(game: game, isVictory: true),
              },
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
