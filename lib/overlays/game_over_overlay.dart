import 'package:flutter/material.dart';
import '../game/circle_rouge_game.dart';

class GameOverOverlay extends StatelessWidget {
  final CircleRougeGame game;
  final bool isVictory;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.isVictory,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xEE000000), // Semi-transparent black
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isVictory ? 'VICTORY!' : 'GAME OVER',
                style: TextStyle(
                  color: isVictory ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isVictory
                    ? 'You survived all 5 waves! Well done!'
                    : 'Better luck next time!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('GameOver');
                    game.restartGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('GameOver');
                    game.showStartMenu();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF757575),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'MAIN MENU',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 