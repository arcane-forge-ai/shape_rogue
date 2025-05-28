import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/circle_rouge_game.dart';
import 'enemy_chaser.dart';
import 'enemy_shooter.dart';

class PiercingProjectile extends CircleComponent with HasGameRef<CircleRougeGame> {
  final Vector2 direction;
  final double speed;
  final double damage;
  final double range;
  final Color? heroColor; // Optional hero color
  
  double lifeTime = 0.0;
  double travelDistance = 0.0;
  final Set<Component> hitEnemies = {}; // Track hit enemies to avoid multiple hits
  
  PiercingProjectile({
    required Vector2 startPosition,
    required this.direction,
    required this.speed,
    required this.damage,
    required this.range,
    this.heroColor,
  }) : super(
    radius: 8.0 * CircleRougeGame.scaleFactor,
    paint: Paint()..color = heroColor ?? const Color(0xFFFFEB3B), // Use hero color or default yellow
    position: startPosition,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Move projectile
    final movement = direction * speed * dt;
    position += movement;
    travelDistance += movement.length;
    
    // Update lifetime
    lifeTime += dt;
    
    // Check collision with enemies
    final enemiesCopy = List<Component>.from(gameRef.currentEnemies);
    for (final enemy in enemiesCopy) {
      if (enemy is PositionComponent && enemy is CircleComponent && !hitEnemies.contains(enemy)) {
        final distanceToEnemy = position.distanceTo(enemy.position);
        final enemyRadius = (enemy as CircleComponent).radius;
        if (distanceToEnemy < radius + enemyRadius) {
          // Hit enemy
          hitEnemies.add(enemy);
          if (enemy is EnemyChaser) {
            enemy.takeDamage(damage);
          } else if (enemy is EnemyShooter) {
            enemy.takeDamage(damage);
          }
          // Don't remove projectile - it pierces through
        }
      }
    }
    
    // Remove if traveled too far or out of bounds
    if (travelDistance > range ||
        position.x < -100 || position.x > CircleRougeGame.arenaWidth + 100 ||
        position.y < -100 || position.y > CircleRougeGame.arenaHeight + 100) {
      removeFromParent();
    }
  }
} 