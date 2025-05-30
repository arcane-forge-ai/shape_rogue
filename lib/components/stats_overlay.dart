import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';

class StatsOverlay extends PositionComponent with HasGameRef<CircleRougeGame> {
  late TextComponent coinCounter;
  late RectangleComponent statusPanel;
  late RectangleComponent statusBorder;
  late TextComponent statusText;
  
  bool isVisible = false;
  
  static const double margin = 20.0;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Set high priority to ensure this overlay renders on top
    priority = 1000;
    
    // Coin counter with enhanced styling
    coinCounter = TextComponent(
      text: '💰 0 COINS',
      textRenderer: TextPaint(
        style: TextStyle(
          color: const Color(0xFFFFEB3B),
          fontSize: 18.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: const [
            Shadow(
              color: Color(0xFFFFEB3B),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(CircleRougeGame.arenaWidth - margin, margin),
    );
    add(coinCounter);
    
    // Status panel with modern styling
    final statusPanelWidth = 140.0 * CircleRougeGame.scaleFactor;
    final statusPanelHeight = 100.0 * CircleRougeGame.scaleFactor;
    statusPanel = RectangleComponent(
      size: Vector2(statusPanelWidth, statusPanelHeight),
      paint: Paint()..color = const Color(0xE8151528),
      position: Vector2(CircleRougeGame.arenaWidth - margin - statusPanelWidth, margin + 30 * CircleRougeGame.scaleFactor),
    );
    add(statusPanel);
    
    // Status panel border
    statusBorder = RectangleComponent(
      size: Vector2(statusPanelWidth, statusPanelHeight),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4A9EFF).withOpacity(0.3),
      position: Vector2(CircleRougeGame.arenaWidth - margin - statusPanelWidth, margin + 30 * CircleRougeGame.scaleFactor),
    );
    add(statusBorder);
    
    // Status text with better formatting
    statusText = TextComponent(
      text: '📊 HERO STATS\nReady for battle!',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(CircleRougeGame.arenaWidth - margin - statusPanelWidth + 6 * CircleRougeGame.scaleFactor, 
                       margin + 36 * CircleRougeGame.scaleFactor),
    );
    add(statusText);
    
    // Initially hidden
    hide();
  }
  
  void show() {
    isVisible = true;
    // Make all child components visible
    for (final child in children) {
      if (child is PositionComponent) {
        child.scale = Vector2.all(1.0);
      }
    }
    updateStats();
  }
  
  void hide() {
    isVisible = false;
    // Hide all child components by scaling them to 0
    for (final child in children) {
      if (child is PositionComponent) {
        child.scale = Vector2.all(0.0);
      }
    }
  }
  
  void updateCoins(int coins) {
    coinCounter.text = '💰 $coins COINS';
  }
  
  void updateStats() {
    if (!isVisible) return;
    
    final hero = gameRef.hero;
    
    // Update coins
    updateCoins(hero.coins);
    
    // Update hero stats with formatted display
    final healthText = '❤️ ${hero.health.round()}/${hero.maxHealth.round()}';
    final attackText = '⚔️ ${(hero.attackSpeedMultiplier * 100).round()}%';
    final speedText = '🏃 ${(hero.speedMultiplier * 100).round()}%';
    
    statusText.text = '''📊 HERO STATS
$healthText HP
$attackText ATK
$speedText SPD''';
  }
} 