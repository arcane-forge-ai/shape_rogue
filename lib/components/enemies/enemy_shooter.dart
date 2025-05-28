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
  
  double health = 20.0;
  double lastShotTime = 0.0;
  static const double shotInterval = 2.0;
  
  // Stun system
  bool isStunned = false;
  double stunTimer = 0.0;
  double stunDuration = 0.0;
  
  // Slow effect system
  bool isSlowed = false;
  double slowTimer = 0.0;
  double slowDuration = 3.0; // Slow lasts 3 seconds
  double speedMultiplier = 1.0;
  
  EnemyShooter() : super(
    radius: 12.0 * CircleRougeGame.scaleFactor,
    paint: Paint()..color = const Color(0xFF9C27B0),
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update stun timer
    if (isStunned) {
      stunTimer += dt;
      if (stunTimer >= stunDuration) {
        isStunned = false;
        stunTimer = 0.0;
        paint.color = const Color(0xFF9C27B0); // Reset to normal color
      } else {
        // Flash between purple and yellow while stunned
        final flashTime = (stunTimer * 4) % 1.0;
        paint.color = flashTime < 0.5 ? const Color(0xFFFFFF00) : const Color(0xFF9C27B0);
        return; // Don't move or shoot while stunned
      }
    }
    
    // Update slow timer
    if (isSlowed) {
      slowTimer += dt;
      if (slowTimer >= slowDuration) {
        isSlowed = false;
        slowTimer = 0.0;
        speedMultiplier = 1.0;
        paint.color = const Color(0xFF9C27B0); // Reset to normal color
      } else {
        // Blink transparency between 70% and 100% while slowed
        final blinkTime = (slowTimer * 3) % 1.0; // 3 blinks per second
        final alpha = (0.7 + 0.3 * sin(blinkTime * 2 * pi)).clamp(0.7, 1.0);
        paint.color = Color.fromRGBO(156, 39, 176, alpha); // Purple with varying alpha
      }
    }
    
    final playerPosition = gameRef.hero.position;
    final distanceToPlayer = position.distanceTo(playerPosition);
    
    // Maintain distance - don't chase, but retreat if too close
    if (distanceToPlayer < attackRange * 0.7) {
      // Too close - retreat (apply speed multiplier for slow effect)
      final direction = (position - playerPosition).normalized();
      position += direction * speed * speedMultiplier * dt;
    }
    // Don't move closer - shooters stay at range
    
    // Keep within safe area
    _constrainToSafeArea();
    
    // Shoot at player regardless of distance
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (currentTime - lastShotTime >= shotInterval) {
      _shootAtPlayer();
      lastShotTime = currentTime;
    }
    
    // Remove if too far from arena center (cleanup)
    final arenaCenter = Vector2(CircleRougeGame.arenaWidth / 2, CircleRougeGame.arenaHeight / 2);
    final maxDistance = (CircleRougeGame.arenaWidth + CircleRougeGame.arenaHeight) / 3;
    if (position.distanceTo(arenaCenter) > maxDistance) {
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
  
  void _shootAtPlayer() {
    final playerPosition = gameRef.hero.position;
    final direction = (playerPosition - position).normalized();
    _fireProjectile(direction);
  }
  
  void stun(double duration) {
    isStunned = true;
    stunDuration = duration;
    stunTimer = 0.0;
  }
  
  void applySlowEffect(double multiplier) {
    isSlowed = true;
    speedMultiplier = multiplier;
    slowTimer = 0.0;
  }
} 