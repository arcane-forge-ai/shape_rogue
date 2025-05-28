import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/circle_rouge_game.dart';
import 'enemy_chaser.dart';
import 'enemy_shooter.dart';

class Projectile extends CircleComponent with HasGameRef<CircleRougeGame> {
  final Vector2 direction;
  final double speed;
  final double damage;
  final bool isEnemyProjectile;
  
  double lifeTime = 0.0;
  static const double maxLifeTime = 3.0; // Seconds before auto-destroy
  
  Projectile({
    required Vector2 startPosition,
    required this.direction,
    required this.speed,
    required this.damage,
    this.isEnemyProjectile = false,
  }) : super(
    radius: 6.0 * CircleRougeGame.scaleFactor, // 50% smaller and scaled
    paint: Paint()..color = isEnemyProjectile ? const Color(0xFFFF1744) : const Color(0xFF00BCD4),
    position: startPosition,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Move projectile
    position += direction * speed * dt;
    
    // Update lifetime
    lifeTime += dt;
    
    // Check collision with hero (if enemy projectile)
    if (isEnemyProjectile) {
      final distanceToHero = position.distanceTo(gameRef.hero.position);
      if (distanceToHero < radius + gameRef.hero.radius) {
        gameRef.hero.takeDamage(damage);
        removeFromParent();
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
            removeFromParent();
            return;
          }
        }
      }
    }
    
    // Remove if out of bounds or too old
    if (lifeTime > maxLifeTime ||
        position.x < -100 || position.x > CircleRougeGame.arenaWidth + 100 ||
        position.y < -100 || position.y > CircleRougeGame.arenaHeight + 100) {
      removeFromParent();
    }
  }
} 