import 'dart:convert';
import 'package:flutter/services.dart';

class WaveSettings {
  final int maxWaves;
  final double waveDuration;
  final double baseSpawnInterval;
  final double spawnIntervalReductionPerWave;
  final double withinWaveProgressionMultiplier;
  final double minimumSpawnInterval;
  
  WaveSettings({
    required this.maxWaves,
    required this.waveDuration,
    required this.baseSpawnInterval,
    required this.spawnIntervalReductionPerWave,
    required this.withinWaveProgressionMultiplier,
    required this.minimumSpawnInterval,
  });
  
  factory WaveSettings.fromJson(Map<String, dynamic> json) {
    return WaveSettings(
      maxWaves: json['max_waves'],
      waveDuration: json['wave_duration'].toDouble(),
      baseSpawnInterval: json['base_spawn_interval'].toDouble(),
      spawnIntervalReductionPerWave: json['spawn_interval_reduction_per_wave'].toDouble(),
      withinWaveProgressionMultiplier: json['within_wave_progression_multiplier'].toDouble(),
      minimumSpawnInterval: json['minimum_spawn_interval'].toDouble(),
    );
  }
}

class WaveData {
  final int wave;
  final String name;
  final String description;
  final List<String> enemyTypes;
  final Map<String, double> spawnWeights;
  
  WaveData({
    required this.wave,
    required this.name,
    required this.description,
    required this.enemyTypes,
    required this.spawnWeights,
  });
  
  factory WaveData.fromJson(Map<String, dynamic> json) {
    return WaveData(
      wave: json['wave'],
      name: json['name'],
      description: json['description'],
      enemyTypes: List<String>.from(json['enemy_types']),
      spawnWeights: Map<String, double>.from(
        json['spawn_weights'].map((key, value) => MapEntry(key, value.toDouble()))
      ),
    );
  }
}

class EnemyReward {
  final int coins;
  
  EnemyReward({required this.coins});
  
  factory EnemyReward.fromJson(Map<String, dynamic> json) {
    return EnemyReward(
      coins: json['coins'],
    );
  }
}

class WaveConfig {
  static WaveConfig? _instance;
  static WaveConfig get instance => _instance ??= WaveConfig._();
  
  WaveConfig._();
  
  WaveSettings? _settings;
  List<WaveData> _waves = [];
  Map<String, EnemyReward> _enemyRewards = {};
  bool _loaded = false;
  
  WaveSettings? get settings => _settings;
  List<WaveData> get waves => _waves;
  Map<String, EnemyReward> get enemyRewards => _enemyRewards;
  
  Future<void> loadConfig() async {
    if (_loaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/config/waves.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _settings = WaveSettings.fromJson(jsonData['wave_config']);
      
      _waves = (jsonData['waves'] as List)
          .map((wave) => WaveData.fromJson(wave))
          .toList();
      
      _enemyRewards = (jsonData['enemy_rewards'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, EnemyReward.fromJson(value)));
      
      _loaded = true;
    } catch (e) {
      print('Error loading wave config: $e');
      // Fallback to default values if loading fails
      _settings = WaveSettings(
        maxWaves: 5,
        waveDuration: 30.0,
        baseSpawnInterval: 2.0,
        spawnIntervalReductionPerWave: 0.2,
        withinWaveProgressionMultiplier: 0.5,
        minimumSpawnInterval: 0.2,
      );
      _waves = [];
      _enemyRewards = {};
      _loaded = true;
    }
  }
  
  WaveData? getWaveData(int waveNumber) {
    return _waves.where((wave) => wave.wave == waveNumber).firstOrNull;
  }
  
  EnemyReward? getEnemyReward(String enemyType) {
    return _enemyRewards[enemyType];
  }
  
  double calculateSpawnInterval(int currentWave, double waveProgress) {
    if (_settings == null) return 2.0;
    
    final baseInterval = _settings!.baseSpawnInterval - 
        (currentWave - 1) * _settings!.spawnIntervalReductionPerWave;
    final progressReduction = waveProgress * _settings!.withinWaveProgressionMultiplier;
    
    return (baseInterval - progressReduction).clamp(_settings!.minimumSpawnInterval, _settings!.baseSpawnInterval);
  }
} 