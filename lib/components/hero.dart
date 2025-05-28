import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/circle_rouge_game.dart';
import 'enemies/projectile.dart';

class Hero extends CircleComponent with HasGameRef<CircleRougeGame>, KeyboardHandler {
  // Base movement properties - will be scaled based on arena size
  static const double baseMoveSpeed = 200.0;
  
  // Base dash properties
  static const double baseDashDistance = 120.0;
  static const double baseDashSpeed = 500.0;
  static const double dashCooldown = 2.0;
  
  // Base shooting properties
  static const double baseShootRange = 250.0;
  static const double fireRate = 2.0; // Shots per second
  double lastShotTime = 0.0;
  
  // Get scaled values based on arena size
  double get moveSpeed => baseMoveSpeed * CircleRougeGame.scaleFactor;
  double get dashDistance => baseDashDistance * CircleRougeGame.scaleFactor;
  double get dashSpeed => baseDashSpeed * CircleRougeGame.scaleFactor;
  double get shootRange => baseShootRange * CircleRougeGame.scaleFactor;
  
  // Attack speed modifier (can be upgraded)
  double attackSpeedMultiplier = 1.0;
  
  // Movement speed modifier (can be upgraded)
  double speedMultiplier = 1.0;
  
  // Dash cooldown modifier (can be upgraded to reduce cooldown)
  double dashCooldownMultiplier = 1.0;
  
  bool isDashing = false;
  double lastDashTime = -double.infinity;
  Vector2? dashTarget;
  
  // Hero stats
  double health = 100.0;
  double maxHealth = 100.0;
  double energy = 100.0;
  double maxEnergy = 100.0;
  int coins = 0;
  
  // Invincibility after wave completion
  bool isInvincible = false;
  double invincibilityTimer = 0.0;
  static const double invincibilityDuration = 3.0; // 3 seconds of invincibility
  
  // Input tracking
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};
  
  Hero({required Vector2 position}) : super(
    radius: 15.0 * CircleRougeGame.scaleFactor,
    paint: Paint()..color = const Color(0xFF4CAF50),
    position: position,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update invincibility timer
    if (isInvincible) {
      invincibilityTimer -= dt;
      if (invincibilityTimer <= 0) {
        isInvincible = false;
        invincibilityTimer = 0.0;
      }
    }
    
    if (isDashing) {
      _updateDash(dt);
    } else {
      _updateMovement(dt);
    }
    
    // Auto-shoot at enemies
    _tryAutoShoot();
    
    // Regenerate energy
    if (energy < maxEnergy) {
      energy = (energy + 50 * dt).clamp(0, maxEnergy);
    }
    
    // Keep hero within arena bounds
    _constrainToArena();
    
    // Update dash cooldown in HUD
    _updateDashCooldownDisplay();
  }
  
  void _tryAutoShoot() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    if (currentTime - lastShotTime < (1.0 / (fireRate * attackSpeedMultiplier))) {
      return; // Still on cooldown
    }
    
    // Find nearest enemy
    Component? nearestEnemy;
    double nearestDistance = double.infinity;
    
    for (final enemy in gameRef.currentEnemies) {
      if (enemy is PositionComponent) {
        final distance = position.distanceTo(enemy.position);
        if (distance < nearestDistance && distance <= shootRange) {
          nearestDistance = distance;
          nearestEnemy = enemy;
        }
      }
    }
    
    // Shoot at nearest enemy if found
    if (nearestEnemy != null && nearestEnemy is PositionComponent) {
      final direction = (nearestEnemy.position - position).normalized();
      _fireProjectile(direction);
      lastShotTime = currentTime;
    }
  }
  
  void _fireProjectile(Vector2 direction) {
    final projectile = Projectile(
      startPosition: position.clone(),
      direction: direction,
      speed: 400.0 * CircleRougeGame.scaleFactor,
      damage: 25.0,
      isEnemyProjectile: false,
    );
    
    gameRef.add(projectile);
  }
  
  void _updateMovement(double dt) {
    Vector2 inputDirection = Vector2.zero();
    
    // Handle WASD movement
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      inputDirection.y -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      inputDirection.y += 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      inputDirection.x -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      inputDirection.x += 1;
    }
    
    // Normalize and apply movement
    if (inputDirection.length > 0) {
      inputDirection.normalize();
      position += inputDirection * moveSpeed * speedMultiplier * dt;
    }
  }
  
  void _updateDash(double dt) {
    if (dashTarget == null) {
      isDashing = false;
      return;
    }
    
    final direction = (dashTarget! - position).normalized();
    final movement = direction * dashSpeed * dt;
    
    if (position.distanceTo(dashTarget!) <= movement.length) {
      position = dashTarget!;
      isDashing = false;
      dashTarget = null;
    } else {
      position += movement;
    }
  }
  
  void _constrainToArena() {
    position.x = position.x.clamp(radius, CircleRougeGame.arenaWidth - radius);
    position.y = position.y.clamp(radius, CircleRougeGame.arenaHeight - radius);
  }
  
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _pressedKeys.clear();
    _pressedKeys.addAll(keysPressed);
    
    // Handle pause functionality with Esc key
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (gameRef.gameState == GameState.playing) {
        gameRef.pauseGame();
        return true;
      } else if (gameRef.gameState == GameState.paused) {
        gameRef.resumeGame();
        return true;
      }
    }
    
    // Handle dash ability
    if (event is KeyDownEvent && 
        (event.logicalKey == LogicalKeyboardKey.space || 
         event.logicalKey == LogicalKeyboardKey.keyK ||
         event.logicalKey == LogicalKeyboardKey.keyE)) {
      _tryDash();
      return true;
    }
    
    return false;
  }
  
  void _tryDash() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final effectiveDashCooldown = dashCooldown * dashCooldownMultiplier;
    
    if (currentTime - lastDashTime < effectiveDashCooldown || energy < 25) {
      return; // Dash on cooldown or not enough energy
    }
    
    // Get current input direction
    Vector2 dashDirection = Vector2.zero();
    
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      dashDirection.y -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      dashDirection.y += 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      dashDirection.x -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) || 
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      dashDirection.x += 1;
    }
    
    // If no input, dash forward (up)
    if (dashDirection.length == 0) {
      dashDirection = Vector2(0, -1);
    }
    
    dashDirection.normalize();
    dashTarget = position + dashDirection * dashDistance;
    
    // Constrain dash target to arena
    dashTarget!.x = dashTarget!.x.clamp(radius, CircleRougeGame.arenaWidth - radius);
    dashTarget!.y = dashTarget!.y.clamp(radius, CircleRougeGame.arenaHeight - radius);
    
    isDashing = true;
    lastDashTime = currentTime;
    energy -= 25; // Dash costs energy
  }
  
  void takeDamage(double damage) {
    if (isInvincible || isDashing) {
      return; // No damage while invincible or dashing
    }
    
    health = (health - damage).clamp(0, maxHealth);
    
    if (health <= 0) {
      gameRef.onHeroDeath();
    }
  }
  
  void heal(double amount) {
    health = (health + amount).clamp(0, maxHealth);
  }
  
  void addCoins(int amount) {
    coins += amount;
  }
  
  void spendCoins(int amount) {
    coins = max(0, coins - amount);
  }
  
  void _updateDashCooldownDisplay() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final timeSinceLastDash = currentTime - lastDashTime;
    final effectiveDashCooldown = dashCooldown * dashCooldownMultiplier;
    final cooldownPercent = (timeSinceLastDash / effectiveDashCooldown).clamp(0.0, 1.0);
    
    if (gameRef.hud.isMounted) {
      gameRef.hud.updateDashCooldown(cooldownPercent);
    }
  }
  
  void activateInvincibility() {
    isInvincible = true;
    invincibilityTimer = invincibilityDuration;
  }
} 