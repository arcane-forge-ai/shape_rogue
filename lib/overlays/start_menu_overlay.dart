import 'package:flutter/material.dart';
import '../game/circle_rouge_game.dart';

class StartMenuOverlay extends StatelessWidget {
  final CircleRougeGame game;

  const StartMenuOverlay({super.key, required this.game});

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
              const Text(
                'CIRCLE ROUGE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Top-down arena shooter with waves, enemies, and upgrades',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('StartMenu');
                    game.overlays.add('HeroSelection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'START GAME',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Controls: WASD/Arrow Keys to move, K/Space/E for abilities',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 