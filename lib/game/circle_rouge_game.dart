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
import '../config/item_config.dart';
import '../config/wave_config.dart';
import '../config/hero_config.dart';

enum GameState { startMenu, heroSelection, playing, shopping, gameOver, victory, paused }

class CircleRougeGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Hero hero;
  late HudComponent hud;
  late ShopPanel shopPanel;
  
  GameState gameState = GameState.startMenu;
  int currentWave = 1;
  int get maxWaves => WaveConfig.instance.settings?.maxWaves ?? 5;
  List<Component> currentEnemies = [];
  List<Component> currentProjectiles = [];
  
  // Time-based wave system - values from config
  double waveTimer = 0.0;
  double get waveDuration => WaveConfig.instance.settings?.waveDuration ?? 30.0;
  double enemySpawnTimer = 0.0;
  double enemySpawnInterval = 2.0; // Will be calculated dynamically
  
  // Arena bounds - responsive to screen size
  static double arenaWidth = 800.0;
  static double arenaHeight = 600.0;
  static double safeAreaMargin = 50.0;
  
  // Scaling factor based on arena size (relative to base 800x600)
  static double get scaleFactor => (arenaWidth + arenaHeight) / (800.0 + 600.0);
  
  String selectedHeroId = 'circle'; // Default hero selection
  
  @override
  Future<void> onLoad() async {
    // Load configurations first
    await ItemConfig.instance.loadConfig();
    await WaveConfig.instance.loadConfig();
    await HeroConfig.instance.loadConfig();
    
    // Calculate responsive arena size based on a reasonable base size
    // This will be overridden by the main app when it knows screen size
    _updateArenaDimensions(800.0, 600.0);
    
    // Set up camera
    camera.viewfinder.visibleGameSize = Vector2(arenaWidth, arenaHeight);
    
    // Create arena background
    final arena = RectangleComponent(
      size: Vector2(arenaWidth, arenaHeight),
      paint: Paint()..color = const Color(0xFF2D2D2D),
      position: Vector2.zero(),
    );
    add(arena);
    
    // Create hero at center (will be added when game starts)
    hero = Hero(position: Vector2(arenaWidth / 2, arenaHeight / 2), heroId: selectedHeroId);
    
    // Create HUD (will be added when game starts)
    hud = HudComponent();
    
    // Create shop panel (will be added when needed)
    shopPanel = ShopPanel();
    
    // Show start menu overlay
    overlays.add('StartMenu');
  }
  
  void startGame() {
    gameState = GameState.heroSelection;
    overlays.remove('StartMenu');
    overlays.add('HeroSelection');
  }
  
  void startGameWithHero(String heroId) {
    selectedHeroId = heroId;
    gameState = GameState.playing;
    currentWave = 1;
    
    // Remove all overlays
    overlays.remove('HeroSelection');
    overlays.remove('GameOver');
    overlays.remove('Victory');
    overlays.remove('PauseMenu');
    
    // Remove existing hero if mounted
    if (hero.isMounted) {
      hero.removeFromParent();
    }
    
    // Create hero with selected type
    hero = Hero(position: Vector2(arenaWidth / 2, arenaHeight / 2), heroId: selectedHeroId);
    
    // Reset all upgrade multipliers
    hero.attackSpeedMultiplier = 1.0;
    hero.speedMultiplier = 1.0;
    hero.abilityCooldownMultiplier = 1.0;
    
    // Add game components
    add(hero);
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
    // Remove all overlays
    overlays.remove('GameOver');
    overlays.remove('Victory');
    overlays.remove('PauseMenu');
    
    // Clear enemies
    final enemiesCopy = List<Component>.from(currentEnemies);
    for (final enemy in enemiesCopy) {
      if (enemy.isMounted) {
        enemy.removeFromParent();
      }
    }
    currentEnemies.clear();
    
    // Clear projectiles
    final projectilesCopy = List<Component>.from(currentProjectiles);
    for (final projectile in projectilesCopy) {
      if (projectile.isMounted) {
        projectile.removeFromParent();
      }
    }
    currentProjectiles.clear();
    
    // Remove existing hero if mounted
    if (hero.isMounted) {
      hero.removeFromParent();
    }
    
    // Recreate hero with selected type and reset stats
    hero = Hero(position: Vector2(arenaWidth / 2, arenaHeight / 2), heroId: selectedHeroId);
    
    // Reset all upgrade multipliers
    hero.attackSpeedMultiplier = 1.0;
    hero.speedMultiplier = 1.0;
    hero.abilityCooldownMultiplier = 1.0;
    
    add(hero);
    
    // Reset game state
    gameState = GameState.playing;
    currentWave = 1;
    waveTimer = 0.0;
    enemySpawnTimer = 0.0;
    
    // Ensure HUD is added and properly updated
    if (!hud.isMounted) {
      add(hud);
    }
    hud.updateHealth(hero.health);
    hud.updateEnergy(hero.energy);
    hud.updateCoins(hero.coins);
    
    // Start first wave
    startWave(currentWave);
  }
  
  void showStartMenu() {
    gameState = GameState.startMenu;
    
    // Remove all overlays and show start menu
    overlays.remove('GameOver');
    overlays.remove('Victory');
    overlays.remove('PauseMenu');
    overlays.remove('HeroSelection');
    overlays.add('StartMenu');
    
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
    
    // Clear enemies
    final enemiesCopy = List<Component>.from(currentEnemies);
    for (final enemy in enemiesCopy) {
      if (enemy.isMounted) {
        enemy.removeFromParent();
      }
    }
    currentEnemies.clear();
    
    // Clear projectiles
    final projectilesCopy = List<Component>.from(currentProjectiles);
    for (final projectile in projectilesCopy) {
      if (projectile.isMounted) {
        projectile.removeFromParent();
      }
    }
    currentProjectiles.clear();
    
    // Reset timers
    waveTimer = 0.0;
    enemySpawnTimer = 0.0;
    currentWave = 1;
  }
  
  void startWave(int waveNumber) {
    gameState = GameState.playing;
    currentWave = waveNumber;
    
    // Reset wave timer
    waveTimer = 0.0;
    enemySpawnTimer = 0.0;
    
    // Set spawn interval from wave config
    enemySpawnInterval = WaveConfig.instance.getSpawnInterval(currentWave);
    
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
    
    // Award coins based on enemy type from config
    String enemyType = 'chaser'; // Default
    if (enemy is EnemyChaser) {
      enemyType = 'chaser';
    } else if (enemy is EnemyShooter) {
      enemyType = 'shooter';
    }
    
    final reward = WaveConfig.instance.getEnemyReward(enemyType);
    final coins = reward?.coins ?? 10; // Fallback to 10 if config not found
    
    hero.addCoins(coins);
    hud.updateCoins(hero.coins);
    
    // No longer check for wave completion here - waves are time-based now
  }
  
  void addProjectile(Component projectile) {
    currentProjectiles.add(projectile);
  }
  
  void onProjectileDestroyed(Component projectile) {
    currentProjectiles.remove(projectile);
  }
  
  void onWaveComplete() {
    // Clear all remaining enemies at wave end
    final enemiesCopy = List<Component>.from(currentEnemies);
    for (final enemy in enemiesCopy) {
      enemy.removeFromParent();
    }
    currentEnemies.clear();
    
    // Clear all remaining projectiles at wave end
    final projectilesCopy = List<Component>.from(currentProjectiles);
    for (final projectile in projectilesCopy) {
      projectile.removeFromParent();
    }
    currentProjectiles.clear();
    
    // Activate hero invincibility
    hero.activateInvincibility();
    
    if (currentWave >= maxWaves) {
      // Game complete - show victory screen
      gameState = GameState.victory;
      overlays.add('Victory');
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
    overlays.add('GameOver');
  }
  
  void pauseGame() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
      overlays.add('PauseMenu');
    }
  }
  
  void resumeGame() {
    if (gameState == GameState.paused) {
      gameState = GameState.playing;
      overlays.remove('PauseMenu');
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Skip game logic when paused
    if (gameState == GameState.paused) {
      return;
    }
    
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
      
      // Spawn enemies periodically using new system
      if (enemySpawnTimer >= enemySpawnInterval) {
        _spawnEnemyGroup();
        enemySpawnTimer = 0.0;
      }
      
      // Check if wave is complete
      if (waveTimer >= waveDuration) {
        onWaveComplete();
      }
    }
  }
  
  void _spawnEnemyGroup() {
    final spawnCount = WaveConfig.instance.getSpawnCount(currentWave);
    
    // Spawn multiple enemies based on spawn_count
    for (int i = 0; i < spawnCount; i++) {
      _spawnRandomEnemy();
    }
  }
  
  void _spawnRandomEnemy() {
    final random = Random();
    final waveData = WaveConfig.instance.getWaveData(currentWave);
    
    Component Function() enemyFactory;
    
    if (waveData != null && waveData.enemyTypes.isNotEmpty) {
      // Use wave configuration to determine enemy type
      final totalWeight = waveData.spawnWeights.values.fold(0.0, (sum, weight) => sum + weight);
      final randomValue = random.nextDouble() * totalWeight;
      
      double currentWeight = 0.0;
      String selectedEnemyType = waveData.enemyTypes.first;
      
      for (final enemyType in waveData.enemyTypes) {
        currentWeight += waveData.spawnWeights[enemyType] ?? 0.0;
        if (randomValue <= currentWeight) {
          selectedEnemyType = enemyType;
          break;
        }
      }
      
      // Create enemy based on selected type
      switch (selectedEnemyType) {
        case 'chaser':
          enemyFactory = EnemyChaser.new;
          break;
        case 'shooter':
          enemyFactory = EnemyShooter.new;
          break;
        default:
          enemyFactory = EnemyChaser.new; // Fallback
      }
    } else {
      // Fallback to old logic if config not available
      switch (currentWave) {
        case 1:
          enemyFactory = EnemyChaser.new;
          break;
        case 2:
          enemyFactory = EnemyShooter.new;
          break;
        default:
          enemyFactory = random.nextBool() ? EnemyChaser.new : EnemyShooter.new;
          break;
      }
    }
    
    _spawnEnemyAtRandomEdge(enemyFactory, random);
  }
  
  void _updateArenaDimensions(double screenWidth, double screenHeight) {
    // Use a reasonable portion of screen size for arena
    arenaWidth = screenWidth * 0.9; // 90% of screen width
    arenaHeight = screenHeight * 0.9; // 90% of screen height
    
    // Ensure minimum and maximum sizes
    arenaWidth = arenaWidth.clamp(400.0, 1200.0);
    arenaHeight = arenaHeight.clamp(300.0, 900.0);
    
    // Update safe area margin based on arena size
    safeAreaMargin = (arenaWidth + arenaHeight) / 40; // Dynamic margin
    
    // Update camera if needed
    if (isMounted) {
      camera.viewfinder.visibleGameSize = Vector2(arenaWidth, arenaHeight);
    }
  }
  
  // Method to be called from main app when screen size is known
  void updateScreenDimensions(double screenWidth, double screenHeight) {
    _updateArenaDimensions(screenWidth, screenHeight);
  }
} 