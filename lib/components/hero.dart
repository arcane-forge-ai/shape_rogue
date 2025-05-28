import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/circle_rouge_game.dart';
import '../config/hero_config.dart';
import 'abilities/hex_field.dart';
import 'enemies/enemy_chaser.dart';
import 'enemies/enemy_shooter.dart';
import 'enemies/piercing_projectile.dart';
import 'enemies/projectile.dart';
import 'shapes/custom_shapes.dart';

class Hero extends PositionComponent with HasGameRef<CircleRougeGame>, KeyboardHandler {
  // Hero configuration
  late HeroData heroData;
  
  // Hero visual properties
  late double heroRadius;
  late Paint heroPaint;
  
  // Base movement properties - will be scaled based on arena size
  static const double baseMoveSpeed = 200.0;
  
  // Base dash properties (for heroes that don't have special abilities)
  static const double baseDashDistance = 120.0;
  static const double baseDashSpeed = 500.0;
  
  // Base shooting properties
  static const double baseShootRange = 250.0;
  static const double fireRate = 2.0; // Shots per second
  double lastShotTime = 0.0;
  
  // Get scaled values based on arena size
  double get moveSpeed => (heroData.moveSpeed / 320.0 * baseMoveSpeed) * CircleRougeGame.scaleFactor;
  double get dashDistance => baseDashDistance * CircleRougeGame.scaleFactor;
  double get dashSpeed => baseDashSpeed * CircleRougeGame.scaleFactor;
  double get shootRange => baseShootRange * CircleRougeGame.scaleFactor;
  
  // Attack speed modifier (can be upgraded)
  double attackSpeedMultiplier = 1.0;
  
  // Movement speed modifier (can be upgraded)
  double speedMultiplier = 1.0;
  
  // Ability cooldown modifier (can be upgraded)
  double abilityCooldownMultiplier = 1.0;
  
  // Ability system
  double lastAbilityTime = -double.infinity;
  bool isUsingAbility = false;
  Vector2? abilityTarget;
  
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
  
  Hero({required Vector2 position, String heroId = 'circle'}) : super(
    position: position,
    size: Vector2.all(30.0 * CircleRougeGame.scaleFactor),
    anchor: Anchor.center,
  ) {
    heroRadius = 15.0 * CircleRougeGame.scaleFactor;
    heroPaint = Paint()..color = const Color(0xFF4CAF50);
    _initializeHero(heroId);
  }
  
  void _initializeHero(String heroId) {
    final heroConfig = HeroConfig.instance.getHeroById(heroId);
    if (heroConfig != null) {
      heroData = heroConfig;
      health = heroData.health;
      maxHealth = heroData.health;
      heroPaint.color = heroData.color;
    } else {
      // Fallback to default circle hero
      heroData = HeroConfig.instance.defaultHero;
      health = heroData.health;
      maxHealth = heroData.health;
      heroPaint.color = heroData.color;
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final shapeSize = size.x;
    
    switch (heroData.shape) {
      case 'circle':
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          heroRadius,
          heroPaint,
        );
        break;
      case 'triangle':
        _drawTriangle(canvas, shapeSize);
        break;
      case 'square':
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(size.x / 2, size.y / 2),
            width: shapeSize * 0.8,
            height: shapeSize * 0.8,
          ),
          heroPaint,
        );
        break;
      case 'pentagon':
        _drawPentagon(canvas, shapeSize);
        break;
      case 'hexagon':
        _drawHexagon(canvas, shapeSize);
        break;
      default:
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          heroRadius,
          heroPaint,
        );
    }
  }
  
  void _drawTriangle(Canvas canvas, double shapeSize) {
    final path = Path();
    final center = Offset(size.x / 2, size.y / 2);
    final halfSize = heroRadius;
    
    path.moveTo(center.dx, center.dy - halfSize); // Top point
    path.lineTo(center.dx - halfSize * cos(pi / 6), center.dy + halfSize / 2); // Bottom left
    path.lineTo(center.dx + halfSize * cos(pi / 6), center.dy + halfSize / 2); // Bottom right
    path.close();
    
    canvas.drawPath(path, heroPaint);
  }
  
  void _drawPentagon(Canvas canvas, double shapeSize) {
    final path = Path();
    final center = Offset(size.x / 2, size.y / 2);
    final radius = heroRadius;
    final angleStep = 2 * pi / 5;
    
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * angleStep;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, heroPaint);
  }
  
  void _drawHexagon(Canvas canvas, double shapeSize) {
    final path = Path();
    final center = Offset(size.x / 2, size.y / 2);
    final radius = heroRadius;
    final angleStep = 2 * pi / 6;
    
    for (int i = 0; i < 6; i++) {
      final angle = -pi / 2 + i * angleStep;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, heroPaint);
  }
  
  // Collision detection method for other components to use
  bool containsPoint(Vector2 point) {
    final distance = position.distanceTo(point);
    return distance <= heroRadius;
  }
  
  // Get collision radius for enemy collision detection
  double get collisionRadius => heroRadius;
  
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
    
    if (isUsingAbility) {
      _updateAbility(dt);
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
    
    // Update ability cooldown in HUD
    _updateAbilityCooldownDisplay();
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
      heroColor: heroData.color,
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
  
  void _updateAbility(double dt) {
    // Handle different ability types based on hero configuration
    switch (heroData.ability.type) {
      case 'dash_damage':
        _updateDashDamage(dt);
        break;
      case 'piercing_shot':
        // Piercing shot is instant, no update needed
        isUsingAbility = false;
        break;
      case 'area_stun':
        // Area stun is instant, no update needed
        isUsingAbility = false;
        break;
      case 'radial_burst':
        // Radial burst is instant, no update needed
        isUsingAbility = false;
        break;
      case 'area_field':
        // Area field is instant placement, no update needed
        isUsingAbility = false;
        break;
      default:
        isUsingAbility = false;
    }
  }
  
  void _updateDashDamage(double dt) {
    if (abilityTarget == null) {
      isUsingAbility = false;
      return;
    }
    
    final direction = (abilityTarget! - position).normalized();
    final movement = direction * dashSpeed * dt;
    
    // Check for enemy collisions during dash
    for (final enemy in gameRef.currentEnemies) {
      if (enemy is PositionComponent && enemy is CircleComponent) {
        final distanceToEnemy = position.distanceTo(enemy.position);
        final enemyRadius = (enemy as CircleComponent).radius;
        if (distanceToEnemy < heroRadius + enemyRadius) {
          // Damage enemy during rolling surge
          if (enemy.parent != null) {
            gameRef.onEnemyDestroyed(enemy);
          }
        }
      }
    }
    
    if (position.distanceTo(abilityTarget!) <= movement.length) {
      position = abilityTarget!;
      isUsingAbility = false;
      abilityTarget = null;
    } else {
      position += movement;
    }
  }
  
  void _tryAbility() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final effectiveCooldown = heroData.ability.cooldown * abilityCooldownMultiplier;
    
    if (currentTime - lastAbilityTime < effectiveCooldown || energy < 25) {
      return; // Ability on cooldown or not enough energy
    }
    
    switch (heroData.ability.type) {
      case 'dash_damage':
        _executeDashDamage();
        break;
      case 'piercing_shot':
        _executePiercingShot();
        break;
      case 'area_stun':
        _executeAreaStun();
        break;
      case 'radial_burst':
        _executeRadialBurst();
        break;
      case 'area_field':
        _executeAreaField();
        break;
    }
    
    lastAbilityTime = currentTime;
    energy -= 25; // Ability costs energy
  }
  
  void _executeDashDamage() {
    // Get current input direction for rolling surge
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
    final scaledRange = heroData.ability.range * CircleRougeGame.scaleFactor;
    abilityTarget = position + dashDirection * scaledRange;
    
    // Constrain ability target to arena
    abilityTarget!.x = abilityTarget!.x.clamp(heroRadius, CircleRougeGame.arenaWidth - heroRadius);
    abilityTarget!.y = abilityTarget!.y.clamp(heroRadius, CircleRougeGame.arenaHeight - heroRadius);
    
    isUsingAbility = true;
  }
  
  void _executePiercingShot() {
    // Find direction to nearest enemy or shoot forward
    Vector2 direction = Vector2(0, -1); // Default forward
    
    Component? nearestEnemy;
    double nearestDistance = double.infinity;
    
    for (final enemy in gameRef.currentEnemies) {
      if (enemy is PositionComponent) {
        final distance = position.distanceTo(enemy.position);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestEnemy = enemy;
        }
      }
    }
    
    if (nearestEnemy != null && nearestEnemy is PositionComponent) {
      direction = (nearestEnemy.position - position).normalized();
    }
    
    // Create piercing projectile
    final projectile = PiercingProjectile(
      startPosition: position.clone(),
      direction: direction,
      speed: 500.0 * CircleRougeGame.scaleFactor,
      damage: heroData.ability.damage,
      range: heroData.ability.range * CircleRougeGame.scaleFactor,
      heroColor: heroData.color,
    );
    
    gameRef.add(projectile);
  }
  
  void _executeAreaStun() {
    // Stun all enemies within range
    final scaledRange = heroData.ability.range * CircleRougeGame.scaleFactor;
    final stunDuration = heroData.ability.duration ?? 3.0;
    
    for (final enemy in gameRef.currentEnemies) {
      if (enemy is PositionComponent) {
        final distance = position.distanceTo(enemy.position);
        if (distance <= scaledRange) {
          // Apply stun effect to different enemy types
          if (enemy is EnemyChaser) {
            enemy.stun(stunDuration);
          } else if (enemy is EnemyShooter) {
            enemy.stun(stunDuration);
          }
        }
      }
    }
    
    // Visual feedback - create a brief shockwave effect
    // This could be enhanced with a proper visual component
    print('Shield Bash! Stunned enemies for ${stunDuration}s');
  }
  
  void _executeRadialBurst() {
    // Fire projectiles in all directions
    final projectileCount = heroData.ability.projectileCount ?? 5;
    final angleStep = (2 * pi) / projectileCount;
    
    for (int i = 0; i < projectileCount; i++) {
      final angle = i * angleStep;
      final direction = Vector2(cos(angle), sin(angle));
      
      final projectile = Projectile(
        startPosition: position.clone(),
        direction: direction,
        speed: 400.0 * CircleRougeGame.scaleFactor,
        damage: heroData.ability.damage,
        isEnemyProjectile: false,
        heroColor: heroData.color,
      );
      
      gameRef.add(projectile);
    }
  }
  
  void _executeAreaField() {
    // Create visual hex field effect
    final scaledRange = heroData.ability.range * CircleRougeGame.scaleFactor;
    final duration = heroData.ability.duration ?? 4.0;
    
    final hexField = HexField(
      position: position.clone(),
      radius: scaledRange,
      duration: duration,
      damage: heroData.ability.damage,
      slowPercent: heroData.ability.slowPercent ?? 0.3,
    );
    
    gameRef.add(hexField);
  }
  
  void _updateAbilityCooldownDisplay() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final timeSinceLastAbility = currentTime - lastAbilityTime;
    final effectiveCooldown = heroData.ability.cooldown * abilityCooldownMultiplier;
    final cooldownPercent = (timeSinceLastAbility / effectiveCooldown).clamp(0.0, 1.0);
    final remainingSeconds = (effectiveCooldown - timeSinceLastAbility).clamp(0.0, effectiveCooldown);
    
    if (gameRef.hud.isMounted) {
      gameRef.hud.updateAbilityCooldown(cooldownPercent, remainingSeconds);
    }
  }
  
  void _constrainToArena() {
    position.x = position.x.clamp(heroRadius, CircleRougeGame.arenaWidth - heroRadius);
    position.y = position.y.clamp(heroRadius, CircleRougeGame.arenaHeight - heroRadius);
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
    
    // Handle ability
    if (event is KeyDownEvent && 
        (event.logicalKey == LogicalKeyboardKey.space || 
         event.logicalKey == LogicalKeyboardKey.keyK ||
         event.logicalKey == LogicalKeyboardKey.keyE)) {
      _tryAbility();
      return true;
    }
    
    return false;
  }
  
  void takeDamage(double damage) {
    if (isInvincible || isUsingAbility) {
      return; // No damage while invincible or using ability
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
  
  void activateInvincibility() {
    isInvincible = true;
    invincibilityTimer = invincibilityDuration;
  }
} 