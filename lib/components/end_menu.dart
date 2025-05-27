import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';

class EndMenu extends RectangleComponent with HasGameRef<CircleRougeGame>, TapCallbacks {
  late TextComponent titleText;
  late TextComponent messageText;
  late RectangleComponent playAgainButton;
  late TextComponent playAgainButtonText;
  late RectangleComponent mainMenuButton;
  late TextComponent mainMenuButtonText;
  
  final bool isVictory;
  
  EndMenu({required this.isVictory}) : super(
    size: Vector2(CircleRougeGame.arenaWidth, CircleRougeGame.arenaHeight),
    paint: Paint()..color = const Color(0xEE000000), // Semi-transparent black
    position: Vector2.zero(),
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Title
    titleText = TextComponent(
      text: isVictory ? 'VICTORY!' : 'GAME OVER',
      textRenderer: TextPaint(
        style: TextStyle(
          color: isVictory ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 100),
    );
    add(titleText);
    
    // Message
    messageText = TextComponent(
      text: isVictory 
          ? 'You survived all 5 waves! Well done!'
          : 'Better luck next time!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 50),
    );
    add(messageText);
    
    // Play Again button
    playAgainButton = RectangleComponent(
      size: Vector2(200, 50),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2((size.x - 200) / 2, size.y / 2 + 20),
    );
    add(playAgainButton);
    
    playAgainButtonText = TextComponent(
      text: 'PLAY AGAIN',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(100, 25),
    );
    playAgainButton.add(playAgainButtonText);
    
    // Main Menu button
    mainMenuButton = RectangleComponent(
      size: Vector2(200, 50),
      paint: Paint()..color = const Color(0xFF757575),
      position: Vector2((size.x - 200) / 2, size.y / 2 + 90),
    );
    add(mainMenuButton);
    
    mainMenuButtonText = TextComponent(
      text: 'MAIN MENU',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(100, 25),
    );
    mainMenuButton.add(mainMenuButtonText);
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    final localPoint = event.localPosition;
    
    // Check if play again button was tapped
    final playAgainButtonRect = Rect.fromLTWH(
      playAgainButton.position.x,
      playAgainButton.position.y,
      playAgainButton.size.x,
      playAgainButton.size.y,
    );
    
    if (playAgainButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      gameRef.restartGame();
      return true;
    }
    
    // Check if main menu button was tapped
    final mainMenuButtonRect = Rect.fromLTWH(
      mainMenuButton.position.x,
      mainMenuButton.position.y,
      mainMenuButton.size.x,
      mainMenuButton.size.y,
    );
    
    if (mainMenuButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      gameRef.showStartMenu();
      return true;
    }
    
    return false;
  }
} 