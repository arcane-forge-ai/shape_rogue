import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Sound effect mappings for hero abilities
  static const Map<String, String> heroAbilitySounds = {
    'circle': 'dash_trim.mp3',
    'triangle': 'spike_shot_trim.mp3', 
    'square': 'shield_bash_trim.mp3',
    'pentagon': 'star_flare_trim.mp3',
    'hexagon': 'hex_field.mp3',
  };

  // Additional game sound effects
  static const String battleBGM = 'Geometric Pulse.mp3';
  static const String clearSound = 'clear.mp3';
  static const String failSound = 'fail.mp3';
  static const String victorySound = 'victory.mp3';
  static const String purchaseSound = 'purchase.mp3';

  // Volume control
  double _volume = 0.7;
  double _musicVolume = 0.5; // Separate volume for background music
  
  double get volume => _volume;
  set volume(double value) {
    _volume = value.clamp(0.0, 1.0);
  }

  double get musicVolume => _musicVolume;
  set musicVolume(double value) {
    _musicVolume = value.clamp(0.0, 1.0);
  }

  // Preload all sound effects
  Future<void> preloadSounds() async {
    try {
      // Preload hero ability sounds
      for (final soundFile in heroAbilitySounds.values) {
        await FlameAudio.audioCache.load(soundFile);
      }
      
      // Preload game sound effects
      await FlameAudio.audioCache.load(battleBGM);
      await FlameAudio.audioCache.load(clearSound);
      await FlameAudio.audioCache.load(failSound);
      await FlameAudio.audioCache.load(victorySound);
      await FlameAudio.audioCache.load(purchaseSound);
    } catch (e) {
      print('Error preloading sounds: $e');
    }
  }

  // Play hero ability sound
  Future<void> playHeroAbilitySound(String heroShape) async {
    try {
      final soundFile = heroAbilitySounds[heroShape];
      if (soundFile != null) {
        await FlameAudio.play(soundFile, volume: _volume);
      }
    } catch (e) {
      print('Error playing hero ability sound for $heroShape: $e');
    }
  }

  // Play battle background music (looping)
  Future<void> playBattleBGM() async {
    try {
      await FlameAudio.bgm.play(battleBGM, volume: _musicVolume);
    } catch (e) {
      print('Error playing battle BGM: $e');
    }
  }

  // Stop background music
  Future<void> stopBGM() async {
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      print('Error stopping BGM: $e');
    }
  }

  // Play wave clear sound
  Future<void> playClearSound() async {
    try {
      await FlameAudio.play(clearSound, volume: _volume);
    } catch (e) {
      print('Error playing clear sound: $e');
    }
  }

  // Play game over/fail sound
  Future<void> playFailSound() async {
    try {
      await FlameAudio.play(failSound, volume: _volume);
    } catch (e) {
      print('Error playing fail sound: $e');
    }
  }

  // Play victory sound (all waves completed)
  Future<void> playVictorySound() async {
    try {
      await FlameAudio.play(victorySound, volume: _volume);
    } catch (e) {
      print('Error playing victory sound: $e');
    }
  }

  // Play purchase sound (shop interaction)
  Future<void> playPurchaseSound() async {
    try {
      await FlameAudio.play(purchaseSound, volume: _volume);
    } catch (e) {
      print('Error playing purchase sound: $e');
    }
  }

  // Helper method to stop all sounds (if needed)
  Future<void> stopAllSounds() async {
    try {
      FlameAudio.audioCache.clearAll();
      FlameAudio.bgm.stop();
    } catch (e) {
      print('Error stopping sounds: $e');
    }
  }
} 