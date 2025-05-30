import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../game/circle_rouge_game.dart';
import 'enemy_chaser.dart';
import 'enemy_shooter.dart';

class ShapeProjectile extends PositionComponent with HasGameRef<CircleRougeGame> {
  final Vector2 direction;
  final double speed;
  final double damage;
  final bool isEnemyProjectile;
  final Color projectileColor;
  final String shape; // 'circle', 'triangle', 'square', 'pentagon', 'hexagon'
  final double projectileRadius;
  
  double lifeTime = 0.0;
  static const double maxLifeTime = 3.0; // Seconds before auto-destroy
  
  // Slow effect system
  bool isSlowed = false;
  double slowTimer = 0.0;
  double slowDuration = 3.0; // Slow lasts 3 seconds
  double speedMultiplier = 1.0;
  
  late Paint shapePaint;
  
  ShapeProjectile({
    required Vector2 startPosition,
    required this.direction,
    required this.speed,
    required this.damage,
    this.isEnemyProjectile = false,
    required this.projectileColor,
    required this.shape,
  }) : projectileRadius = 8.0 * CircleRougeGame.scaleFactor,
       super(
         position: startPosition,
         size: Vector2.all(16.0 * CircleRougeGame.scaleFactor),
         anchor: Anchor.center,
       ) {
    shapePaint = Paint()..color = projectileColor;
  }
  
  @override
  void onMount() {
    super.onMount();
    // Register projectile with game
    gameRef.addProjectile(this);
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = Offset(size.x / 2, size.y / 2);
    
    // Add glow effect
    final glowPaint = Paint()
      ..color = projectileColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    switch (shape) {
      case 'circle':
        // Draw glow
        canvas.drawCircle(center, projectileRadius + 2, glowPaint);
        // Draw shape
        canvas.drawCircle(center, projectileRadius, shapePaint);
        break;
      case 'triangle':
        _drawTriangle(canvas, center, glowPaint);
        _drawTriangle(canvas, center, shapePaint);
        break;
      case 'square':
        _drawSquare(canvas, center, glowPaint);
        _drawSquare(canvas, center, shapePaint);
        break;
      case 'pentagon':
        _drawPentagon(canvas, center, glowPaint);
        _drawPentagon(canvas, center, shapePaint);
        break;
      case 'hexagon':
        _drawHexagon(canvas, center, glowPaint);
        _drawHexagon(canvas, center, shapePaint);
        break;
      default:
        // Default to circle
        canvas.drawCircle(center, projectileRadius + 2, glowPaint);
        canvas.drawCircle(center, projectileRadius, shapePaint);
    }
  }
  
  void _drawTriangle(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    final radius = paint == shapePaint ? projectileRadius : projectileRadius + 2;
    
    path.moveTo(center.dx, center.dy - radius); // Top point
    path.lineTo(center.dx - radius * cos(pi / 6), center.dy + radius / 2); // Bottom left
    path.lineTo(center.dx + radius * cos(pi / 6), center.dy + radius / 2); // Bottom right
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  void _drawSquare(Canvas canvas, Offset center, Paint paint) {
    final radius = paint == shapePaint ? projectileRadius : projectileRadius + 2;
    final size = radius * 1.4; // Make square a bit larger than circle
    
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: size,
        height: size,
      ),
      paint,
    );
  }
  
  void _drawPentagon(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    final radius = paint == shapePaint ? projectileRadius : projectileRadius + 2;
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
    
    canvas.drawPath(path, paint);
  }
  
  void _drawHexagon(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    final radius = paint == shapePaint ? projectileRadius : projectileRadius + 2;
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
    
    canvas.drawPath(path, paint);
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
        shapePaint.color = projectileColor;
      } else {
        // Blink transparency between 70% and 100% while slowed
        final blinkTime = (slowTimer * 3) % 1.0; // 3 blinks per second
        final alpha = (0.7 + 0.3 * sin(blinkTime * 2 * pi)).clamp(0.7, 1.0);
        shapePaint.color = Color.fromRGBO(
          projectileColor.red, 
          projectileColor.green, 
          projectileColor.blue, 
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
      if (distanceToHero < projectileRadius + gameRef.hero.collisionRadius) {
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
          if (distanceToEnemy < projectileRadius + enemyRadius) {
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