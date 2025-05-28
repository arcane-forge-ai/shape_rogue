import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/circle_rouge_game.dart';
import 'projectile.dart';

class EnemyShooter extends CircleComponent with HasGameRef<CircleRougeGame> {
  static const double baseSpeed = 100.0;
  static const double baseAttackRange = 200.0;
  static const double fireRate = 1.5; // Shots per second
  static const double damage = 5.0;
  
  double get speed => baseSpeed * CircleRougeGame.scaleFactor;
  double get attackRange => baseAttackRange * CircleRougeGame.scaleFactor;
  
  double health = 40.0;
  double lastShotTime = 0.0;
  
  EnemyShooter() : super(
    radius: 12.0 * CircleRougeGame.scaleFactor,
    paint: Paint()..color = const Color(0xFF9C27B0),
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final playerPosition = gameRef.hero.position;
    final distanceToPlayer = position.distanceTo(playerPosition);
    final arenaCenter = Vector2(CircleRougeGame.arenaWidth / 2, CircleRougeGame.arenaHeight / 2);
    final distanceToCenter = position.distanceTo(arenaCenter);
    
    // Scaled distance thresholds
    final maxCenterDistance = (CircleRougeGame.arenaWidth + CircleRougeGame.arenaHeight) / 4;
    final optimalPlayerDistance = 80.0 * CircleRougeGame.scaleFactor;
    
    // Face the player
    final direction = (playerPosition - position).normalized();
    
    // If too far from arena center, move back towards center
    if (distanceToCenter > maxCenterDistance) {
      final centerDirection = (arenaCenter - position).normalized();
      position += centerDirection * speed * dt;
    } else if (distanceToPlayer <= attackRange && _canFire()) {
      // In range - fire at player
      _fireProjectile(direction);
    } else if (distanceToPlayer > optimalPlayerDistance * 1.5) { // Too far from player - move closer
      position += direction * speed * dt;
    } else {
      // Too close to player - move away
      final retreatDirection = -direction;
      position += retreatDirection * speed * dt;
    }
    
    // Keep within safe area
    _constrainToSafeArea();
    
    // Check collision with hero
    if (distanceToPlayer < radius + gameRef.hero.radius) {
      _hitHero();
    }
    
    // Remove if too far from arena (cleanup)
    final cleanupDistance = (CircleRougeGame.arenaWidth + CircleRougeGame.arenaHeight) / 3;
    if (position.distanceTo(arenaCenter) > cleanupDistance) {
      removeFromParent();
    }
  }
  
  void _constrainToSafeArea() {
    final margin = CircleRougeGame.safeAreaMargin;
    position.x = position.x.clamp(
      margin, 
      CircleRougeGame.arenaWidth - margin
    );
    position.y = position.y.clamp(
      margin, 
      CircleRougeGame.arenaHeight - margin
    );
  }
  
  bool _canFire() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    return currentTime - lastShotTime >= (1.0 / fireRate);
  }
  
  void _fireProjectile(Vector2 direction) {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    lastShotTime = currentTime;
    
    final projectile = Projectile(
      startPosition: position.clone(),
      direction: direction,
      speed: 300.0 * CircleRougeGame.scaleFactor,
      damage: 15.0,
      isEnemyProjectile: true,
    );
    
    gameRef.add(projectile);
  }
  
  void _hitHero() {
    gameRef.hero.takeDamage(damage);
    takeDamage(health); // Destroy self on contact
  }
  
  void takeDamage(double damageAmount) {
    health -= damageAmount;
    
    if (health <= 0) {
      gameRef.onEnemyDestroyed(this);
      removeFromParent();
    }
  }
} 