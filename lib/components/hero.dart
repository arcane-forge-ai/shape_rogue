import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/circle_rouge_game.dart';
import 'enemies/projectile.dart';

class Hero extends CircleComponent with HasGameRef<CircleRougeGame>, KeyboardHandler {
  // Movement properties - doubled for bigger scale
  static const double moveSpeed = 12.0;
  
  // Dash properties - doubled for bigger scale
  static const double dashDistance = 10.0;
  static const double dashSpeed = 40.0;
  static const double dashCooldown = 2.0;
  
  // Shooting properties - doubled range and adjusted for bigger scale
  static const double shootRange = 600.0;
  static const double fireRate = 2.0; // Shots per second
  double lastShotTime = 0.0;
  
  // Attack speed modifier (can be upgraded)
  double attackSpeedMultiplier = 1.0;
  
  bool isDashing = false;
  double lastDashTime = -double.infinity;
  Vector2? dashTarget;
  
  // Hero stats
  double health = 100.0;
  double maxHealth = 100.0;
  double energy = 100.0;
  double maxEnergy = 100.0;
  int coins = 0;
  
  // Input tracking
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};
  
  Hero({required Vector2 position}) : super(
    radius: 30.0,
    paint: Paint()..color = const Color(0xFF4CAF50),
    position: position,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
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
      speed: 800.0,
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
      position += inputDirection * moveSpeed * dt * 60; // 60 for frame rate independence
    }
  }
  
  void _updateDash(double dt) {
    if (dashTarget == null) {
      isDashing = false;
      return;
    }
    
    final direction = (dashTarget! - position).normalized();
    final movement = direction * dashSpeed * dt * 60;
    
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
    
    // Handle dash ability
    if (event is KeyDownEvent && 
        (event.logicalKey == LogicalKeyboardKey.space || 
         event.logicalKey == LogicalKeyboardKey.keyE)) {
      _tryDash();
      return true;
    }
    
    return false;
  }
  
  void _tryDash() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    if (currentTime - lastDashTime < dashCooldown || energy < 25) {
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
    dashTarget = position + dashDirection * dashDistance * 60;
    
    // Constrain dash target to arena
    dashTarget!.x = dashTarget!.x.clamp(radius, CircleRougeGame.arenaWidth - radius);
    dashTarget!.y = dashTarget!.y.clamp(radius, CircleRougeGame.arenaHeight - radius);
    
    isDashing = true;
    lastDashTime = currentTime;
    energy -= 25; // Dash costs energy
  }
  
  void takeDamage(double damage) {
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
    final cooldownPercent = (timeSinceLastDash / dashCooldown).clamp(0.0, 1.0);
    
    if (gameRef.hud.isMounted) {
      gameRef.hud.updateDashCooldown(cooldownPercent);
    }
  }
} 