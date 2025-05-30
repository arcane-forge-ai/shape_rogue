import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/circle_rouge_game.dart';
import 'enemy_chaser.dart';
import 'enemy_shooter.dart';

class TriangleProjectile extends PositionComponent with HasGameRef<CircleRougeGame> {
  final Vector2 direction;
  final double speed;
  final double damage;
  final double range;
  final Color? heroColor;
  final double projectileSize;
  
  double lifeTime = 0.0;
  double travelDistance = 0.0;
  final Set<Component> hitEnemies = {}; // Track hit enemies to avoid multiple hits
  
  TriangleProjectile({
    required Vector2 startPosition,
    required this.direction,
    required this.speed,
    required this.damage,
    required this.range,
    required this.projectileSize,
    this.heroColor,
  }) : super(
    position: startPosition,
    size: Vector2.all(projectileSize * CircleRougeGame.scaleFactor),
    anchor: Anchor.center,
  );
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    
    // Draw glow effect
    final glowPaint = Paint()
      ..color = (heroColor ?? const Color(0xFFFF9800)).withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    final trianglePath = _createTrianglePath(center, radius + 8);
    canvas.drawPath(trianglePath, glowPaint);
    
    // Draw main triangle
    final mainPaint = Paint()
      ..color = heroColor ?? const Color(0xFFFF9800);
    
    final mainTrianglePath = _createTrianglePath(center, radius);
    canvas.drawPath(mainTrianglePath, mainPaint);
  }
  
  Path _createTrianglePath(Offset center, double radius) {
    final path = Path();
    
    // Create triangle points
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * cos(pi / 6), center.dy + radius / 2);
    path.lineTo(center.dx + radius * cos(pi / 6), center.dy + radius / 2);
    path.close();
    
    return path;
  }
  
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
      if (enemy is PositionComponent && !hitEnemies.contains(enemy)) {
        // Check if enemy is within triangle bounds
        if (_isEnemyInTriangle(enemy)) {
          // Hit enemy - eliminate immediately
          hitEnemies.add(enemy);
          if (enemy is EnemyChaser) {
            enemy.takeDamage(damage); // High damage to eliminate instantly
          } else if (enemy is EnemyShooter) {
            enemy.takeDamage(damage); // High damage to eliminate instantly
          }
          // Don't remove projectile - it continues through
        }
      }
    }
    
    // Remove if traveled too far or out of bounds
    if (travelDistance > range ||
        position.x < -200 || position.x > CircleRougeGame.arenaWidth + 200 ||
        position.y < -200 || position.y > CircleRougeGame.arenaHeight + 200) {
      removeFromParent();
    }
  }
  
  bool _isEnemyInTriangle(PositionComponent enemy) {
    // Simple circular collision detection for now
    // Could be enhanced with proper triangle collision later
    final distance = position.distanceTo(enemy.position);
    final collisionRadius = size.x / 2.5; // Slightly smaller than visual for better feel
    return distance < collisionRadius;
  }
} 