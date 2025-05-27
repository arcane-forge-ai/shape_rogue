import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/circle_rouge_game.dart';
import 'projectile.dart';

class EnemyShooter extends CircleComponent with HasGameRef<CircleRougeGame> {
  static const double speed = 5.0; // Doubled speed
  static const double attackRange = 12.0 * 60; // Doubled range
  static const double fireRate = 1.5; // Shots per second
  static const double damage = 5.0;
  
  double health = 40.0;
  double lastShotTime = 0.0;
  
  EnemyShooter() : super(
    radius: 20.0, // Doubled size
    paint: Paint()..color = const Color(0xFF9C27B0),
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final playerPosition = gameRef.hero.position;
    final distanceToPlayer = position.distanceTo(playerPosition);
    final arenaCenter = Vector2(CircleRougeGame.arenaWidth / 2, CircleRougeGame.arenaHeight / 2);
    final distanceToCenter = position.distanceTo(arenaCenter);
    
    // Face the player
    final direction = (playerPosition - position).normalized();
    
    // If too far from arena center, move back towards center
    if (distanceToCenter > 600) { // Doubled threshold
      final centerDirection = (arenaCenter - position).normalized();
      position += centerDirection * speed * dt * 60;
    } else if (distanceToPlayer <= attackRange && _canFire()) {
      // In range - fire at player
      _fireProjectile(direction);
    } else if (distanceToPlayer > 200) { // Too far from player - move closer
      position += direction * speed * dt * 60;
    } else {
      // Too close to player - move away
      final retreatDirection = -direction;
      position += retreatDirection * speed * dt * 60;
    }
    
    // Keep within safe area
    _constrainToSafeArea();
    
    // Check collision with hero
    if (distanceToPlayer < radius + gameRef.hero.radius) {
      _hitHero();
    }
    
    // Remove if too far from arena (cleanup) - doubled threshold
    if (position.distanceTo(arenaCenter) > 800) {
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
      speed: 400.0, // Doubled speed
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