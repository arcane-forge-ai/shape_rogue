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
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate scaling factor to fit screen while maintaining aspect ratio
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            
            // TODO: add a debug text to show the screen size and the game size
            print('Screen size: $screenWidth x $screenHeight');
            
            double scaledWidth, scaledHeight;
            
            // Use a base aspect ratio for initial calculation
            final baseGameAspectRatio = 4.0 / 3.0; // 4:3 ratio
            final screenAspectRatio = screenWidth / screenHeight;
            
            if (screenAspectRatio > baseGameAspectRatio) {
              // Screen is wider than game - fit to height
              scaledHeight = screenHeight;
              scaledWidth = screenHeight * baseGameAspectRatio;
            } else {
              // Screen is taller than game - fit to width
              scaledWidth = screenWidth;
              scaledHeight = screenWidth / baseGameAspectRatio;
            }
            print('Scaled size: $scaledWidth x $scaledHeight');
            
            return Center(
              child: SizedBox(
                width: scaledWidth,
                height: scaledHeight,
                child: GameWidget<CircleRougeGame>.controlled(
                  gameFactory: () {
                    final game = CircleRougeGame();
                    game.updateScreenDimensions(scaledWidth, scaledHeight);
                    return game;
                  },
                ),
              ),
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
