import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../game/circle_rouge_game.dart';
import 'enemy_chaser.dart';
import 'enemy_shooter.dart';

class Projectile extends CircleComponent with HasGameRef<CircleRougeGame> {
  final Vector2 direction;
  final double speed;
  final double damage;
  final bool isEnemyProjectile;
  final Color? heroColor; // Optional hero color for hero projectiles
  
  double lifeTime = 0.0;
  static const double maxLifeTime = 3.0; // Seconds before auto-destroy
  
  // Slow effect system
  bool isSlowed = false;
  double slowTimer = 0.0;
  double slowDuration = 3.0; // Slow lasts 3 seconds
  double speedMultiplier = 1.0;
  
  Projectile({
    required Vector2 startPosition,
    required this.direction,
    required this.speed,
    required this.damage,
    this.isEnemyProjectile = false,
    this.heroColor,
  }) : super(
    radius: 6.0 * CircleRougeGame.scaleFactor, // 50% smaller and scaled
    paint: Paint()..color = getProjectileColor(isEnemyProjectile, heroColor),
    position: startPosition,
  );
  
  static Color getProjectileColor(bool isEnemyProjectile, Color? heroColor) {
    if (isEnemyProjectile) {
      return const Color(0xFFFF1744); // Red for enemy projectiles
    } else if (heroColor != null) {
      return heroColor; // Use hero's color
    } else {
      return const Color(0xFF00BCD4); // Default cyan for hero projectiles
    }
  }
  
  @override
  void onMount() {
    super.onMount();
    // Register projectile with game
    gameRef.addProjectile(this);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update slow timer
    if (isSlowed) {
      slowTimer += dt;
      if (slowTimer >= slowDuration) {
        isSlowed = false;
        slowTimer = 0.0;
        speedMultiplier = 1.0;
        // Reset color
        paint.color = getProjectileColor(isEnemyProjectile, heroColor);
      } else {
        // Blink transparency between 70% and 100% while slowed
        final blinkTime = (slowTimer * 3) % 1.0; // 3 blinks per second
        final alpha = (0.7 + 0.3 * sin(blinkTime * 2 * pi)).clamp(0.7, 1.0);
        final originalColor = getProjectileColor(isEnemyProjectile, heroColor);
        paint.color = Color.fromRGBO(
          originalColor.red, 
          originalColor.green, 
          originalColor.blue, 
          alpha
        );
      }
    }
    
    // Move projectile with speed multiplier
    position += direction * speed * speedMultiplier * dt;
    
    // Update lifetime
    lifeTime += dt;
    
    // Check collision with hero (if enemy projectile)
    if (isEnemyProjectile) {
      final distanceToHero = position.distanceTo(gameRef.hero.position);
      if (distanceToHero < radius + gameRef.hero.collisionRadius) {
        gameRef.hero.takeDamage(damage);
        _destroyProjectile();
        return;
      }
    } else {
      // Hero projectile - check collision with enemies
      for (final enemy in gameRef.currentEnemies) {
        if (enemy is PositionComponent && enemy is CircleComponent) {
          final distanceToEnemy = position.distanceTo(enemy.position);
          final enemyRadius = (enemy as CircleComponent).radius;
          if (distanceToEnemy < radius + enemyRadius) {
            // Hit enemy
            if (enemy is EnemyChaser) {
              enemy.takeDamage(damage);
            } else if (enemy is EnemyShooter) {
              enemy.takeDamage(damage);
            }
            _destroyProjectile();
            return;
          }
        }
      }
    }
    
    // Remove if out of bounds or too old
    if (lifeTime > maxLifeTime ||
        position.x < -100 || position.x > CircleRougeGame.arenaWidth + 100 ||
        position.y < -100 || position.y > CircleRougeGame.arenaHeight + 100) {
      _destroyProjectile();
    }
  }
  
  void applySlowEffect(double multiplier) {
    isSlowed = true;
    speedMultiplier = multiplier;
    slowTimer = 0.0;
  }
  
  void _destroyProjectile() {
    gameRef.onProjectileDestroyed(this);
    removeFromParent();
  }
  
  @override
  void removeFromParent() {
    gameRef.onProjectileDestroyed(this);
    super.removeFromParent();
  }
} 