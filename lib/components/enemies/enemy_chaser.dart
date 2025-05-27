import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/circle_rouge_game.dart';

class EnemyChaser extends CircleComponent with HasGameRef<CircleRougeGame> {
  static const double speed = 8.0;
  static const double damage = 10.0;
  
  double health = 30.0;
  
  EnemyChaser() : super(
    radius: 24.0,
    paint: Paint()..color = const Color(0xFFFF5722),
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Always move toward the player
    final playerPosition = gameRef.hero.position;
    final direction = (playerPosition - position).normalized();
    
    position += direction * speed * dt * 60;
    
    // Keep within safe area
    _constrainToSafeArea();
    
    // Check collision with hero
    if (position.distanceTo(playerPosition) < radius + gameRef.hero.radius) {
      _hitHero();
    }
    
    // Remove if too far from arena center (cleanup)
    final arenaCenter = Vector2(CircleRougeGame.arenaWidth / 2, CircleRougeGame.arenaHeight / 2);
    if (position.distanceTo(arenaCenter) > 1000) {
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
} 