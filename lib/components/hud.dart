import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';

class HudComponent extends Component with HasGameRef<CircleRougeGame> {
  late RectangleComponent healthBarBg;
  late RectangleComponent healthBarFill;
  late RectangleComponent energyBarBg;
  late RectangleComponent energyBarFill;
  late TextComponent coinCounter;
  late TextComponent waveIndicator;
  late TextComponent healthText;
  late TextComponent energyText;
  late RectangleComponent dashCooldownBg;
  late RectangleComponent dashCooldownFill;
  late TextComponent dashCooldownText;
  late TextComponent waveTimerText;
  late RectangleComponent statusPanel;
  late TextComponent statusText;
  
  static double get barWidth => 250.0 * CircleRougeGame.scaleFactor;
  static double get healthBarHeight => 20.0 * CircleRougeGame.scaleFactor;
  static double get energyBarHeight => 15.0 * CircleRougeGame.scaleFactor;
  static double get margin => 8.0 * CircleRougeGame.scaleFactor;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Health bar background
    healthBarBg = RectangleComponent(
      size: Vector2(barWidth, healthBarHeight),
      paint: Paint()..color = const Color(0xFF424242),
      position: Vector2(margin, margin),
    );
    add(healthBarBg);
    
    // Health bar fill
    healthBarFill = RectangleComponent(
      size: Vector2(barWidth, healthBarHeight),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2(margin, margin),
    );
    add(healthBarFill);
    
    // Health text
    healthText = TextComponent(
      text: '100/100',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(margin + barWidth / 2, margin + healthBarHeight / 2),
    );
    add(healthText);
    
    // Energy bar background
    energyBarBg = RectangleComponent(
      size: Vector2(barWidth, energyBarHeight),
      paint: Paint()..color = const Color(0xFF424242),
      position: Vector2(margin, margin + healthBarHeight + 5 * CircleRougeGame.scaleFactor),
    );
    add(energyBarBg);
    
    // Energy bar fill
    energyBarFill = RectangleComponent(
      size: Vector2(barWidth, energyBarHeight),
      paint: Paint()..color = const Color(0xFF2196F3),
      position: Vector2(margin, margin + healthBarHeight + 5 * CircleRougeGame.scaleFactor),
    );
    add(energyBarFill);
    
    // Energy text
    energyText = TextComponent(
      text: '100/100',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(margin + barWidth / 2, margin + healthBarHeight + 5 * CircleRougeGame.scaleFactor + energyBarHeight / 2),
    );
    add(energyText);
    
    // Dash cooldown background
    final dashCooldownWidth = 120.0 * CircleRougeGame.scaleFactor;
    final dashCooldownHeight = 12.0 * CircleRougeGame.scaleFactor;
    dashCooldownBg = RectangleComponent(
      size: Vector2(dashCooldownWidth, dashCooldownHeight),
      paint: Paint()..color = const Color(0xFF424242),
      position: Vector2(margin, margin + healthBarHeight + energyBarHeight + 15 * CircleRougeGame.scaleFactor),
    );
    add(dashCooldownBg);
    
    // Dash cooldown fill
    dashCooldownFill = RectangleComponent(
      size: Vector2(dashCooldownWidth, dashCooldownHeight),
      paint: Paint()..color = const Color(0xFFFFEB3B),
      position: Vector2(margin, margin + healthBarHeight + energyBarHeight + 15 * CircleRougeGame.scaleFactor),
    );
    add(dashCooldownFill);
    
    // Dash cooldown text
    dashCooldownText = TextComponent(
      text: 'Dash Ready',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(margin + dashCooldownWidth + 5 * CircleRougeGame.scaleFactor, 
                       margin + healthBarHeight + energyBarHeight + 15 * CircleRougeGame.scaleFactor + dashCooldownHeight / 2),
    );
    add(dashCooldownText);
    
    // Coin counter
    coinCounter = TextComponent(
      text: 'Coins: 0',
      textRenderer: TextPaint(
        style: TextStyle(
          color: const Color(0xFFFFEB3B),
          fontSize: 20.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(CircleRougeGame.arenaWidth - margin, margin),
    );
    add(coinCounter);
    
    // Wave indicator
    waveIndicator = TextComponent(
      text: 'Wave 1',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(CircleRougeGame.arenaWidth / 2, margin),
    );
    add(waveIndicator);
    
    // Wave timer
    waveTimerText = TextComponent(
      text: 'Time: 30s',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(CircleRougeGame.arenaWidth / 2, margin + 30 * CircleRougeGame.scaleFactor),
    );
    add(waveTimerText);
    
    // Status panel
    final statusPanelWidth = 120.0 * CircleRougeGame.scaleFactor;
    final statusPanelHeight = 80.0 * CircleRougeGame.scaleFactor;
    statusPanel = RectangleComponent(
      size: Vector2(statusPanelWidth, statusPanelHeight),
      paint: Paint()..color = const Color(0xFF424242),
      position: Vector2(CircleRougeGame.arenaWidth - margin - statusPanelWidth, margin + 25 * CircleRougeGame.scaleFactor), // Below coin counter
    );
    add(statusPanel);
    
    // Status text
    statusText = TextComponent(
      text: 'Status: Ready',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(CircleRougeGame.arenaWidth - margin - statusPanelWidth + 3 * CircleRougeGame.scaleFactor, 
                       margin + 28 * CircleRougeGame.scaleFactor), // Below coin counter
    );
    add(statusText);
  }
  
  void updateHealth(double health) {
    final maxHealth = gameRef.hero.maxHealth;
    final healthPercent = health / maxHealth;
    healthBarFill.size.x = barWidth * healthPercent;
    healthText.text = '${health.round()}/${maxHealth.round()}';
    
    // Change color based on health
    if (healthPercent > 0.6) {
      healthBarFill.paint.color = const Color(0xFF4CAF50); // Green
    } else if (healthPercent > 0.3) {
      healthBarFill.paint.color = const Color(0xFFFF9800); // Orange
    } else {
      healthBarFill.paint.color = const Color(0xFFF44336); // Red
    }
  }
  
  void updateEnergy(double energy) {
    final maxEnergy = gameRef.hero.maxEnergy;
    final energyPercent = energy / maxEnergy;
    energyBarFill.size.x = barWidth * energyPercent;
    energyText.text = '${energy.round()}/${maxEnergy.round()}';
  }
  
  void updateDashCooldown(double cooldownPercent) {
    final dashCooldownWidth = 120.0 * CircleRougeGame.scaleFactor;
    dashCooldownFill.size.x = dashCooldownWidth * cooldownPercent;
    if (cooldownPercent >= 1.0) {
      dashCooldownText.text = 'Ability Ready';
      dashCooldownFill.paint.color = const Color(0xFF4CAF50);
    } else {
      dashCooldownFill.paint.color = const Color(0xFFFF9800);
    }
  }
  
  // New method to update cooldown with seconds remaining
  void updateAbilityCooldown(double cooldownPercent, double remainingSeconds) {
    final dashCooldownWidth = 120.0 * CircleRougeGame.scaleFactor;
    dashCooldownFill.size.x = dashCooldownWidth * cooldownPercent;
    if (cooldownPercent >= 1.0) {
      dashCooldownText.text = 'Ability Ready';
      dashCooldownFill.paint.color = const Color(0xFF4CAF50);
    } else {
      final seconds = remainingSeconds.ceil();
      dashCooldownText.text = 'Cooldown: ${seconds}s';
      dashCooldownFill.paint.color = const Color(0xFFFF9800);
    }
  }
  
  void updateWaveTimer(double remainingTime) {
    final seconds = remainingTime.ceil();
    waveTimerText.text = 'Time: ${seconds}s';
    
    // Change color based on remaining time
    if (remainingTime > 10) {
      waveTimerText.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (remainingTime > 5) {
      waveTimerText.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.orange,
          fontSize: 16.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      waveTimerText.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.red,
          fontSize: 16.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
  
  void updateCoins(int coins) {
    coinCounter.text = 'Coins: $coins';
  }
  
  void updateWave(int wave) {
    waveIndicator.text = 'Wave $wave';
  }
  
  void updateStatus() {
    final hero = gameRef.hero;
    final statusInfo = '''Max HP: ${hero.maxHealth.round()}
Max Energy: ${hero.maxEnergy.round()}
Attack Speed: ${(hero.attackSpeedMultiplier * 100).round()}%
Speed: ${(hero.speedMultiplier * 100).round()}%
Coins: ${hero.coins}''';
    
    statusText.text = statusInfo;
  }
} 