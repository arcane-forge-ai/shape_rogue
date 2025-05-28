import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/circle_rouge_game.dart';
import '../enemies/enemy_chaser.dart';
import '../enemies/enemy_shooter.dart';
import '../enemies/projectile.dart';

class HexField extends PositionComponent with HasGameRef<CircleRougeGame> {
  final double radius;
  final double duration;
  final double damage;
  final double slowPercent;
  
  double lifeTime = 0.0;
  double damageTimer = 0.0;
  static const double damageInterval = 1.0; // Damage every second
  
  late Paint fieldPaint;
  late Paint borderPaint;
  
  // Track affected entities for cleanup
  Set<Component> affectedEnemies = {};
  Set<Component> affectedProjectiles = {};
  
  HexField({
    required Vector2 position,
    required this.radius,
    required this.duration,
    required this.damage,
    required this.slowPercent,
  }) : super(
    position: position,
    size: Vector2.all(radius * 2),
    anchor: Anchor.center,
  ) {
    // Semi-transparent purple field
    fieldPaint = Paint()
      ..color = const Color(0x40E91E63) // Semi-transparent pink/purple
      ..style = PaintingStyle.fill;
    
    // Bright border
    borderPaint = Paint()
      ..color = const Color(0xFFE91E63) // Bright pink/purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    lifeTime += dt;
    damageTimer += dt;
    
    // Apply slow effects continuously (every frame)
    _applySlowEffects();
    
    // Apply damage every second
    if (damageTimer >= damageInterval) {
      _applyDamageEffects();
      damageTimer = 0.0;
    }
    
    // Fade out effect as field expires
    final fadePercent = (lifeTime / duration).clamp(0.0, 1.0);
    final alpha = (255 * (1.0 - fadePercent * 0.5)).round(); // Fade to 50% opacity
    
    fieldPaint.color = Color.fromARGB(
      (alpha * 0.25).round(), // Keep it semi-transparent
      233, 30, 99
    );
    borderPaint.color = Color.fromARGB(
      alpha,
      233, 30, 99
    );
    
    // Remove field when duration expires
    if (lifeTime >= duration) {
      _cleanupAllEffects();
      removeFromParent();
    }
  }
  
  void _applySlowEffects() {
    // Apply slow effects to all enemies within the field immediately
    final enemiesCopy = List<Component>.from(gameRef.currentEnemies);
    Set<Component> currentlyAffectedEnemies = {};
    
    for (final enemy in enemiesCopy) {
      if (enemy is PositionComponent) {
        final distance = position.distanceTo(enemy.position);
        if (distance <= radius) {
          currentlyAffectedEnemies.add(enemy);
          // Apply 70% slow effect immediately
          if (enemy is EnemyChaser && !enemy.isSlowed) {
            enemy.applySlowEffect(0.3); // 30% of original speed = 70% slow
            affectedEnemies.add(enemy);
          } else if (enemy is EnemyShooter && !enemy.isSlowed) {
            enemy.applySlowEffect(0.3); // 30% of original speed = 70% slow
            affectedEnemies.add(enemy);
          }
        }
      }
    }
    
    // Apply slow effects to all projectiles within the field
    final projectilesCopy = List<Component>.from(gameRef.currentProjectiles);
    Set<Component> currentlyAffectedProjectiles = {};
    
    for (final projectile in projectilesCopy) {
      if (projectile is Projectile && projectile.isEnemyProjectile) { // Only affect enemy projectiles
        final distance = position.distanceTo(projectile.position);
        if (distance <= radius) {
          currentlyAffectedProjectiles.add(projectile);
          if (!projectile.isSlowed) {
            // Apply 70% slow effect to enemy projectiles only
            projectile.applySlowEffect(0.3); // 30% of original speed = 70% slow
            affectedProjectiles.add(projectile);
          }
        }
      }
    }
    
    // Restore speed for enemies that exited the field
    for (final enemy in affectedEnemies.toList()) {
      if (!currentlyAffectedEnemies.contains(enemy)) {
        if (enemy is EnemyChaser && enemy.isSlowed) {
          enemy.isSlowed = false;
          enemy.speedMultiplier = 1.0;
          enemy.paint.color = const Color(0xFFFF5722); // Reset color
        } else if (enemy is EnemyShooter && enemy.isSlowed) {
          enemy.isSlowed = false;
          enemy.speedMultiplier = 1.0;
          enemy.paint.color = const Color(0xFF9C27B0); // Reset color
        }
        affectedEnemies.remove(enemy);
      }
    }
    
    // Restore speed for projectiles that exited the field
    for (final projectile in affectedProjectiles.toList()) {
      if (!currentlyAffectedProjectiles.contains(projectile)) {
        if (projectile is Projectile && projectile.isSlowed) {
          projectile.isSlowed = false;
          projectile.speedMultiplier = 1.0;
          projectile.paint.color = Projectile.getProjectileColor(projectile.isEnemyProjectile, projectile.heroColor);
        }
        affectedProjectiles.remove(projectile);
      }
    }
  }
  
  void _applyDamageEffects() {
    // Apply damage to all enemies within the field
    final enemiesCopy = List<Component>.from(gameRef.currentEnemies);
    
    for (final enemy in enemiesCopy) {
      if (enemy is PositionComponent) {
        final distance = position.distanceTo(enemy.position);
        if (distance <= radius) {
          // Apply percentage-based damage (20% of max HP)
          if (enemy is EnemyChaser) {
            final maxHealth = 30.0; // EnemyChaser max health
            final damageAmount = maxHealth * 0.2; // 20% of max HP
            enemy.takeDamage(damageAmount);
            
            // Visual feedback - make enemy flash red briefly
            enemy.paint.color = const Color(0xFFFF0000);
            Future.delayed(const Duration(milliseconds: 200), () {
              if (enemy.isMounted) {
                enemy.paint.color = const Color(0xFFFF5722);
              }
            });
          } else if (enemy is EnemyShooter) {
            final maxHealth = 20.0; // EnemyShooter max health  
            final damageAmount = maxHealth * 0.2; // 20% of max HP
            enemy.takeDamage(damageAmount);
            
            // Visual feedback - make enemy flash red briefly
            enemy.paint.color = const Color(0xFFFF0000);
            Future.delayed(const Duration(milliseconds: 200), () {
              if (enemy.isMounted) {
                enemy.paint.color = const Color(0xFF9C27B0);
              }
            });
          }
        }
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw hexagonal field
    final path = _createHexagonPath();
    
    // Draw filled area
    canvas.drawPath(path, fieldPaint);
    
    // Draw border
    canvas.drawPath(path, borderPaint);
  }
  
  Path _createHexagonPath() {
    final path = Path();
    final center = Offset(size.x / 2, size.y / 2);
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
    
    return path;
  }
  
  void _cleanupAllEffects() {
    // Restore speed for all affected enemies
    for (final enemy in affectedEnemies) {
      if (enemy is EnemyChaser && enemy.isSlowed) {
        enemy.isSlowed = false;
        enemy.speedMultiplier = 1.0;
        enemy.paint.color = const Color(0xFFFF5722); // Reset color
      } else if (enemy is EnemyShooter && enemy.isSlowed) {
        enemy.isSlowed = false;
        enemy.speedMultiplier = 1.0;
        enemy.paint.color = const Color(0xFF9C27B0); // Reset color
      }
    }
    
    // Restore speed for all affected projectiles
    for (final projectile in affectedProjectiles) {
      if (projectile is Projectile && projectile.isSlowed) {
        projectile.isSlowed = false;
        projectile.speedMultiplier = 1.0;
        projectile.paint.color = Projectile.getProjectileColor(projectile.isEnemyProjectile, projectile.heroColor);
      }
    }
    
    // Clear tracking sets
    affectedEnemies.clear();
    affectedProjectiles.clear();
  }
  
  @override
  void removeFromParent() {
    _cleanupAllEffects();
    super.removeFromParent();
  }
} 