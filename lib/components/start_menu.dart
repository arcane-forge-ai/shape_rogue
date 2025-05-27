import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';

class StartMenu extends RectangleComponent with HasGameRef<CircleRougeGame>, TapCallbacks {
  late TextComponent titleText;
  late TextComponent subtitleText;
  late RectangleComponent playButton;
  late TextComponent playButtonText;
  late TextComponent instructionsText;
  
  StartMenu() : super(
    size: Vector2(CircleRougeGame.arenaWidth, CircleRougeGame.arenaHeight),
    paint: Paint()..color = const Color(0xEE000000), // Semi-transparent black
    position: Vector2.zero(),
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Title
    titleText = TextComponent(
      text: 'CIRCLE ROUGE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 100),
    );
    add(titleText);
    
    // Subtitle
    subtitleText = TextComponent(
      text: 'Survive 5 Waves of Geometric Enemies',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 50),
    );
    add(subtitleText);
    
    // Play button
    playButton = RectangleComponent(
      size: Vector2(200, 60),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2((size.x - 200) / 2, size.y / 2),
    );
    add(playButton);
    
    playButtonText = TextComponent(
      text: 'START GAME',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(100, 30),
    );
    playButton.add(playButtonText);
    
    // Instructions
    instructionsText = TextComponent(
      text: 'Controls: WASD/Arrows to move, Space/E to dash',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 + 100),
    );
    add(instructionsText);
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    final localPoint = event.localPosition;
    
    // Check if play button was tapped
    final playButtonRect = Rect.fromLTWH(
      playButton.position.x,
      playButton.position.y,
      playButton.size.x,
      playButton.size.y,
    );
    
    if (playButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      gameRef.startGame();
      return true;
    }
    
    return false;
  }
} 