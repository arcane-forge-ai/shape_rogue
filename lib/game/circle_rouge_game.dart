import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Hero;
import 'package:flutter/services.dart';

import '../components/hero.dart';
import '../components/enemies/enemy_chaser.dart';
import '../components/enemies/enemy_shooter.dart';
import '../components/hud.dart';
import '../components/shop_panel.dart';
import '../components/start_menu.dart';
import '../components/end_menu.dart';

enum GameState { startMenu, playing, shopping, gameOver, victory }

class CircleRougeGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Hero hero;
  late HudComponent hud;
  late ShopPanel shopPanel;
  late StartMenu startMenu;
  EndMenu? endMenu;
  
  GameState gameState = GameState.startMenu;
  int currentWave = 1;
  int maxWaves = 5;
  List<Component> currentEnemies = [];
  
  // Time-based wave system
  double waveTimer = 0.0;
  double waveDuration = 30.0; // 30 seconds per wave
  double enemySpawnTimer = 0.0;
  double enemySpawnInterval = 1.0; // Start with 1 second spawn interval (increased frequency)
  
  // Arena bounds (10x10 grid as specified) - doubled in size
  static const double arenaWidth = 1600.0;
  static const double arenaHeight = 1200.0;
  static const double safeAreaMargin = 100.0; // Keep enemies within this margin
  
  @override
  Future<void> onLoad() async {
    // Set up camera
    camera.viewfinder.visibleGameSize = Vector2(arenaWidth, arenaHeight);
    
    // Create arena background
    final arena = RectangleComponent(
      size: Vector2(arenaWidth, arenaHeight),
      paint: Paint()..color = const Color(0xFF2D2D2D),
      position: Vector2.zero(),
    );
    add(arena);
    
    // Create and show start menu
    startMenu = StartMenu();
    add(startMenu);
    
    // Create hero at center (will be added when game starts)
    hero = Hero(position: Vector2(arenaWidth / 2, arenaHeight / 2));
    
    // Create HUD (will be added when game starts)
    hud = HudComponent();
    
    // Create shop panel (will be added when needed)
    shopPanel = ShopPanel();
  }
  
  void startGame() {
    gameState = GameState.playing;
    currentWave = 1;
    
    // Remove start menu
    startMenu.removeFromParent();
    
    // Add game components
    if (!hero.isMounted) {
      add(hero);
    }
    if (!hud.isMounted) {
      add(hud);
    }
    
    // Reset hero stats
    hero.health = hero.maxHealth;
    hero.energy = hero.maxEnergy;
    hero.coins = 0;
    hero.position = Vector2(arenaWidth / 2, arenaHeight / 2);
    
    // Start first wave
    startWave(currentWave);
  }
  
  void restartGame() {
    // Remove end menu if it exists
    if (endMenu != null && endMenu!.isMounted) {
      endMenu!.removeFromParent();
      endMenu = null;
    }
    
    // Clear enemies
    for (final enemy in currentEnemies) {
      enemy.removeFromParent();
    }
    currentEnemies.clear();
    
    // Remove shop if visible
    if (shopPanel.isMounted) {
      shopPanel.removeFromParent();
    }
    
    // Reset game state
    gameState = GameState.startMenu;
    
    // Start new game
    startGame();
  }
  
  void showStartMenu() {
    gameState = GameState.startMenu;
    
    // Remove end menu if it exists
    if (endMenu != null && endMenu!.isMounted) {
      endMenu!.removeFromParent();
      endMenu = null;
    }
    
    // Remove game components
    if (hero.isMounted) {
      hero.removeFromParent();
    }
    if (hud.isMounted) {
      hud.removeFromParent();
    }
    if (shopPanel.isMounted) {
      shopPanel.removeFromParent();
    }
    
    // Add start menu back
    if (!startMenu.isMounted) {
      add(startMenu);
    }
    
    // Clear enemies
    for (final enemy in currentEnemies) {
      enemy.removeFromParent();
    }
    currentEnemies.clear();
  }
  
  void startWave(int waveNumber) {
    gameState = GameState.playing;
    currentWave = waveNumber;
    
    // Reset wave timer
    waveTimer = 0.0;
    enemySpawnTimer = 0.0;
    
    // Make sure shop is removed during gameplay
    if (shopPanel.isMounted) {
      shopPanel.removeFromParent();
    }
    
    // Clear existing enemies
    for (final enemy in currentEnemies) {
      enemy.removeFromParent();
    }
    currentEnemies.clear();
    
    // Update HUD
    hud.updateWave(waveNumber);
  }
  
  void _spawnEnemyAtRandomEdge(Component Function() enemyFactory, Random random) {
    Vector2 spawnPosition;
    
    // Spawn at random edge of arena
    final edge = random.nextInt(4);
    switch (edge) {
      case 0: // Top
        spawnPosition = Vector2(random.nextDouble() * arenaWidth, -50);
        break;
      case 1: // Right
        spawnPosition = Vector2(arenaWidth + 50, random.nextDouble() * arenaHeight);
        break;
      case 2: // Bottom
        spawnPosition = Vector2(random.nextDouble() * arenaWidth, arenaHeight + 50);
        break;
      case 3: // Left
        spawnPosition = Vector2(-50, random.nextDouble() * arenaHeight);
        break;
      default:
        spawnPosition = Vector2.zero();
    }
    
    final enemy = enemyFactory();
    if (enemy is PositionComponent) {
      enemy.position = spawnPosition;
    }
    
    add(enemy);
    currentEnemies.add(enemy);
  }
  
  void onEnemyDestroyed(Component enemy) {
    currentEnemies.remove(enemy);
    
    // Award coins
    hero.addCoins(10);
    hud.updateCoins(hero.coins);
    
    // No longer check for wave completion here - waves are time-based now
  }
  
  void onWaveComplete() {
    // Clear all remaining enemies at wave end
    for (final enemy in currentEnemies) {
      enemy.removeFromParent();
    }
    currentEnemies.clear();
    
    if (currentWave >= maxWaves) {
      // Game complete - show victory screen
      gameState = GameState.victory;
      endMenu = EndMenu(isVictory: true);
      add(endMenu!);
    } else {
      // Show shop
      gameState = GameState.shopping;
      if (!shopPanel.isMounted) {
        add(shopPanel);
      }
      shopPanel.show();
      // Auto refresh shop items
      shopPanel.rollShopItems();
    }
  }
  
  void onShopClosed() {
    gameState = GameState.playing;
    if (shopPanel.isMounted) {
      shopPanel.removeFromParent();
    }
    startWave(currentWave + 1);
  }
  
  void onHeroDeath() {
    gameState = GameState.gameOver;
    endMenu = EndMenu(isVictory: false);
    add(endMenu!);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Only update HUD during gameplay
    if (gameState == GameState.playing || gameState == GameState.shopping) {
      hud.updateHealth(hero.health);
      hud.updateEnergy(hero.energy);
      hud.updateCoins(hero.coins);
      hud.updateStatus();
    }
    
    // Handle wave timing during gameplay
    if (gameState == GameState.playing) {
      waveTimer += dt;
      enemySpawnTimer += dt;
      
      // Update wave timer display
      final remainingTime = (waveDuration - waveTimer).clamp(0.0, waveDuration);
      hud.updateWaveTimer(remainingTime);
      
      // Spawn enemies periodically
      if (enemySpawnTimer >= enemySpawnInterval) {
        _spawnRandomEnemy();
        enemySpawnTimer = 0.0;
        
        // Increase spawn rate as wave progresses and with difficulty
        final baseInterval = 1.0 - (currentWave - 1) * 0.15; // Each wave reduces base interval by 0.15s
        final waveProgress = waveTimer / waveDuration;
        enemySpawnInterval = (baseInterval - waveProgress * 0.5).clamp(0.2, 1.0);
      }
      
      // Check if wave is complete
      if (waveTimer >= waveDuration) {
        onWaveComplete();
      }
    }
  }
  
  void _spawnRandomEnemy() {
    final random = Random();
    
    // Choose enemy type based on current wave
    Component Function() enemyFactory;
    
    switch (currentWave) {
      case 1:
        enemyFactory = EnemyChaser.new; // Only chasers
        break;
      case 2:
        enemyFactory = EnemyShooter.new; // Only shooters
        break;
      default:
        // Mix of both types
        enemyFactory = random.nextBool() ? EnemyChaser.new : EnemyShooter.new;
        break;
    }
    
    _spawnEnemyAtRandomEdge(enemyFactory, random);
  }
} 