import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';

class PauseMenu extends RectangleComponent with HasGameRef<CircleRougeGame>, TapCallbacks {
  late TextComponent titleText;
  late TextComponent instructionText;
  late RectangleComponent resumeButton;
  late TextComponent resumeButtonText;
  late RectangleComponent mainMenuButton;
  late TextComponent mainMenuButtonText;
  
  PauseMenu() : super(
    size: Vector2(CircleRougeGame.arenaWidth, CircleRougeGame.arenaHeight),
    paint: Paint()..color = const Color(0xCC000000), // Semi-transparent black
    position: Vector2.zero(),
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Title
    titleText = TextComponent(
      text: 'PAUSED',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 48.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 80 * CircleRougeGame.scaleFactor),
    );
    add(titleText);
    
    // Instructions
    instructionText = TextComponent(
      text: 'Press ESC to resume or click buttons below',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16.0 * CircleRougeGame.scaleFactor,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 40 * CircleRougeGame.scaleFactor),
    );
    add(instructionText);
    
    // Resume button
    final buttonWidth = 150.0 * CircleRougeGame.scaleFactor;
    final buttonHeight = 40.0 * CircleRougeGame.scaleFactor;
    
    resumeButton = RectangleComponent(
      size: Vector2(buttonWidth, buttonHeight),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2((size.x - buttonWidth) / 2, size.y / 2 + 10 * CircleRougeGame.scaleFactor),
    );
    add(resumeButton);
    
    resumeButtonText = TextComponent(
      text: 'RESUME',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(buttonWidth / 2, buttonHeight / 2),
    );
    resumeButton.add(resumeButtonText);
    
    // Main Menu button
    mainMenuButton = RectangleComponent(
      size: Vector2(buttonWidth, buttonHeight),
      paint: Paint()..color = const Color(0xFF757575),
      position: Vector2((size.x - buttonWidth) / 2, size.y / 2 + 60 * CircleRougeGame.scaleFactor),
    );
    add(mainMenuButton);
    
    mainMenuButtonText = TextComponent(
      text: 'MAIN MENU',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(buttonWidth / 2, buttonHeight / 2),
    );
    mainMenuButton.add(mainMenuButtonText);
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    final localPoint = event.localPosition;
    
    // Check if resume button was tapped
    final resumeButtonRect = Rect.fromLTWH(
      resumeButton.position.x,
      resumeButton.position.y,
      resumeButton.size.x,
      resumeButton.size.y,
    );
    
    if (resumeButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      gameRef.resumeGame();
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