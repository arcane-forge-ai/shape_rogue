import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../game/circle_rouge_game.dart';

class EnemyChaser extends CircleComponent with HasGameRef<CircleRougeGame> {
  static const double baseSpeed = 150.0;
  static const double damage = 10.0;
  
  double get speed => baseSpeed * CircleRougeGame.scaleFactor;
  
  double health = 30.0;
  
  // Stun system
  bool isStunned = false;
  double stunTimer = 0.0;
  double stunDuration = 0.0;
  
  // Slow effect system
  bool isSlowed = false;
  double slowTimer = 0.0;
  double slowDuration = 3.0; // Slow lasts 3 seconds
  double speedMultiplier = 1.0;
  
  EnemyChaser() : super(
    radius: 12.0 * CircleRougeGame.scaleFactor,
    paint: Paint()..color = const Color(0xFFFF5722),
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
        paint.color = const Color(0xFFFF5722); // Reset to normal color
      } else {
        // Flash between red and yellow while stunned
        final flashTime = (stunTimer * 4) % 1.0;
        paint.color = flashTime < 0.5 ? const Color(0xFFFFFF00) : const Color(0xFFFF0000);
        return; // Don't move while stunned
      }
    }
    
    // Update slow timer
    if (isSlowed) {
      slowTimer += dt;
      if (slowTimer >= slowDuration) {
        isSlowed = false;
        slowTimer = 0.0;
        speedMultiplier = 1.0;
        paint.color = const Color(0xFFFF5722); // Reset to normal color
      } else {
        // Blink transparency between 70% and 100% while slowed
        final blinkTime = (slowTimer * 3) % 1.0; // 3 blinks per second
        final alpha = (0.7 + 0.3 * sin(blinkTime * 2 * pi)).clamp(0.7, 1.0);
        paint.color = Color.fromRGBO(255, 87, 34, alpha); // Orange with varying alpha
      }
    }
    
    // Always move toward the player (chasers should chase!)
    final playerPosition = gameRef.hero.position;
    final direction = (playerPosition - position).normalized();
    
    // Apply speed multiplier for slow effect
    position += direction * speed * speedMultiplier * dt;
    
    // Keep within safe area
    _constrainToSafeArea();
    
    // Check collision with hero
    if (position.distanceTo(playerPosition) < radius + gameRef.hero.collisionRadius) {
      _hitHero();
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