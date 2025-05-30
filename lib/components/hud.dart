import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';

class HudComponent extends Component with HasGameRef<CircleRougeGame> {
  late RectangleComponent healthBarBg;
  late RectangleComponent healthBarFill;
  late TextComponent waveIndicator;
  late TextComponent healthText;
  late RectangleComponent abilityCooldownBg;
  late RectangleComponent abilityCooldownFill;
  late TextComponent abilityCooldownText;
  late TextComponent waveTimerText;
  late RectangleComponent hudBackground;
  late RectangleComponent centerPanel;
  
  static double get barWidth => 280.0 * CircleRougeGame.scaleFactor;
  static double get healthBarHeight => 24.0 * CircleRougeGame.scaleFactor;
  static double get margin => 12.0 * CircleRougeGame.scaleFactor;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // HUD background panel with enhanced gradient
    hudBackground = RectangleComponent(
      size: Vector2(barWidth + 30, 90 * CircleRougeGame.scaleFactor),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D2D4A),
            Color(0xFF1E1E3A),
            Color(0xFF151528),
          ],
        ).createShader(Rect.fromLTWH(0, 0, barWidth + 30, 90 * CircleRougeGame.scaleFactor)),
      position: Vector2(margin - 15, margin - 10),
    );
    add(hudBackground);
    
    // Enhanced border with glow effect
    final hudBorder = RectangleComponent(
      size: Vector2(barWidth + 30, 90 * CircleRougeGame.scaleFactor),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF4A9EFF).withOpacity(0.6),
      position: Vector2(margin - 15, margin - 10),
    );
    add(hudBorder);
    
    // Outer glow effect for HUD
    final hudOuterGlow = RectangleComponent(
      size: Vector2(barWidth + 40, 100 * CircleRougeGame.scaleFactor),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xFF4A9EFF).withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      position: Vector2(margin - 20, margin - 15),
    );
    add(hudOuterGlow);
    
    // Health bar background with enhanced styling
    healthBarBg = RectangleComponent(
      size: Vector2(barWidth, healthBarHeight),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ).createShader(Rect.fromLTWH(0, 0, barWidth, healthBarHeight)),
      position: Vector2(margin, margin),
    );
    add(healthBarBg);
    
    // Health bar border
    final healthBarBorder = RectangleComponent(
      size: Vector2(barWidth, healthBarHeight),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4A9EFF).withOpacity(0.4),
      position: Vector2(margin, margin),
    );
    add(healthBarBorder);
    
    // Health bar fill with enhanced gradient effect
    healthBarFill = RectangleComponent(
      size: Vector2(barWidth, healthBarHeight),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF66BB6A),
          ],
        ).createShader(Rect.fromLTWH(0, 0, barWidth, healthBarHeight)),
      position: Vector2(margin, margin),
    );
    add(healthBarFill);
    
    // Health text with enhanced styling
    healthText = TextComponent(
      text: '❤️ 100/100 HP',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
            Shadow(
              color: Color(0xFF4CAF50),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(margin + barWidth / 2, margin + healthBarHeight / 2),
    );
    add(healthText);
    
    // Ability cooldown background with enhanced styling
    final abilityCooldownWidth = 140.0 * CircleRougeGame.scaleFactor;
    final abilityCooldownHeight = 18.0 * CircleRougeGame.scaleFactor;
    abilityCooldownBg = RectangleComponent(
      size: Vector2(abilityCooldownWidth, abilityCooldownHeight),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ).createShader(Rect.fromLTWH(0, 0, abilityCooldownWidth, abilityCooldownHeight)),
      position: Vector2(margin, margin + healthBarHeight + 15 * CircleRougeGame.scaleFactor),
    );
    add(abilityCooldownBg);
    
    // Ability cooldown border
    final abilityCooldownBorder = RectangleComponent(
      size: Vector2(abilityCooldownWidth, abilityCooldownHeight),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4A9EFF).withOpacity(0.3),
      position: Vector2(margin, margin + healthBarHeight + 15 * CircleRougeGame.scaleFactor),
    );
    add(abilityCooldownBorder);
    
    // Ability cooldown fill with enhanced gradient
    abilityCooldownFill = RectangleComponent(
      size: Vector2(abilityCooldownWidth, abilityCooldownHeight),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF66BB6A),
          ],
        ).createShader(Rect.fromLTWH(0, 0, abilityCooldownWidth, abilityCooldownHeight)),
      position: Vector2(margin, margin + healthBarHeight + 15 * CircleRougeGame.scaleFactor),
    );
    add(abilityCooldownFill);
    
    // Ability cooldown text with enhanced styling
    abilityCooldownText = TextComponent(
      text: '🔥 Ability Ready',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 3,
            ),
          ],
        ),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(margin + abilityCooldownWidth + 10 * CircleRougeGame.scaleFactor, 
                       margin + healthBarHeight + 15 * CircleRougeGame.scaleFactor + abilityCooldownHeight / 2),
    );
    add(abilityCooldownText);
    
    // Center panel for wave info with enhanced gradient
    centerPanel = RectangleComponent(
      size: Vector2(220 * CircleRougeGame.scaleFactor, 80 * CircleRougeGame.scaleFactor),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D2D4A),
            Color(0xFF1E1E3A),
            Color(0xFF151528),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 220 * CircleRougeGame.scaleFactor, 80 * CircleRougeGame.scaleFactor)),
      position: Vector2(
        (CircleRougeGame.arenaWidth - 220 * CircleRougeGame.scaleFactor) / 2,
        margin - 10,
      ),
    );
    add(centerPanel);
    
    // Center panel enhanced border with glow
    final centerBorder = RectangleComponent(
      size: Vector2(220 * CircleRougeGame.scaleFactor, 80 * CircleRougeGame.scaleFactor),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF4A9EFF).withOpacity(0.6),
      position: Vector2(
        (CircleRougeGame.arenaWidth - 220 * CircleRougeGame.scaleFactor) / 2,
        margin - 10,
      ),
    );
    add(centerBorder);
    
    // Center panel outer glow
    final centerOuterGlow = RectangleComponent(
      size: Vector2(230 * CircleRougeGame.scaleFactor, 90 * CircleRougeGame.scaleFactor),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xFF4A9EFF).withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      position: Vector2(
        (CircleRougeGame.arenaWidth - 230 * CircleRougeGame.scaleFactor) / 2,
        margin - 15,
      ),
    );
    add(centerOuterGlow);
    
    // Wave indicator with enhanced styling
    waveIndicator = TextComponent(
      text: '🌊 WAVE 1',
      textRenderer: TextPaint(
        style: TextStyle(
          color: const Color(0xFF4A9EFF),
          fontSize: 22.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          shadows: const [
            Shadow(
              color: Color(0xFF4A9EFF),
              blurRadius: 10,
            ),
            Shadow(
              color: Color(0xFF9C27B0),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(CircleRougeGame.arenaWidth / 2, margin + 8),
    );
    add(waveIndicator);
    
    // Wave timer with enhanced styling
    waveTimerText = TextComponent(
      text: '⏱️ TIME: 30s',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
            Shadow(
              color: Color(0xFF4A9EFF),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(CircleRougeGame.arenaWidth / 2, margin + 40 * CircleRougeGame.scaleFactor),
    );
    add(waveTimerText);
  }
  
  void updateHealth(double health) {
    final maxHealth = gameRef.hero.maxHealth;
    final healthPercent = health / maxHealth;
    healthBarFill.size.x = barWidth * healthPercent;
    healthText.text = '❤️ ${health.round()}/${maxHealth.round()} HP';
    
    // Change color based on health
    if (healthPercent > 0.6) {
      healthBarFill.paint.color = const Color(0xFF4CAF50); // Green
    } else if (healthPercent > 0.3) {
      healthBarFill.paint.color = const Color(0xFFFF9800); // Orange
    } else {
      healthBarFill.paint.color = const Color(0xFFF44336); // Red
    }
  }
  
  void updateDashCooldown(double cooldownPercent) {
    final abilityCooldownWidth = 140.0 * CircleRougeGame.scaleFactor;
    abilityCooldownFill.size.x = abilityCooldownWidth * cooldownPercent;
    if (cooldownPercent >= 1.0) {
      abilityCooldownText.text = '🔥 Ability Ready';
      abilityCooldownFill.paint.color = const Color(0xFF4CAF50);
    } else {
      abilityCooldownFill.paint.color = const Color(0xFFFF9800);
    }
  }
  
  // Enhanced method to update cooldown with seconds remaining
  void updateAbilityCooldown(double cooldownPercent, double remainingSeconds) {
    final abilityCooldownWidth = 140.0 * CircleRougeGame.scaleFactor;
    abilityCooldownFill.size.x = abilityCooldownWidth * cooldownPercent;
    if (cooldownPercent >= 1.0) {
      abilityCooldownText.text = '🔥 Ability Ready';
      abilityCooldownFill.paint.color = const Color(0xFF4CAF50);
    } else {
      final seconds = remainingSeconds.ceil();
      abilityCooldownText.text = '⏳ Cooldown: ${seconds}s';
      abilityCooldownFill.paint.color = const Color(0xFFFF9800);
    }
  }
  
  void updateWaveTimer(double remainingTime) {
    final seconds = remainingTime.ceil();
    waveTimerText.text = '⏱️ TIME: ${seconds}s';
    
    // Change color based on remaining time
    if (remainingTime > 10) {
      waveTimerText.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
            ),
          ],
        ),
      );
    } else if (remainingTime > 5) {
      waveTimerText.textRenderer = TextPaint(
        style: TextStyle(
          color: const Color(0xFFFF9800),
          fontSize: 14.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Color(0xFFFF9800),
              blurRadius: 4,
            ),
          ],
        ),
      );
    } else {
      waveTimerText.textRenderer = TextPaint(
        style: TextStyle(
          color: const Color(0xFFF44336),
          fontSize: 14.0 * CircleRougeGame.scaleFactor,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Color(0xFFF44336),
              blurRadius: 6,
            ),
          ],
        ),
      );
    }
  }
  
  void updateWave(int wave) {
    waveIndicator.text = '🌊 WAVE $wave';
  }
} 