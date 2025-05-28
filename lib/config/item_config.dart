import 'dart:convert';
import 'package:flutter/services.dart';

class ItemEffect {
  final String type;
  final double value;
  
  ItemEffect({required this.type, required this.value});
  
  factory ItemEffect.fromJson(Map<String, dynamic> json) {
    return ItemEffect(
      type: json['type'],
      value: json['value'].toDouble(),
    );
  }
}

class ItemData {
  final String id;
  final String name;
  final int cost;
  final String description;
  final String type;
  final ItemEffect effect;
  
  ItemData({
    required this.id,
    required this.name,
    required this.cost,
    required this.description,
    required this.type,
    required this.effect,
  });
  
  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      id: json['id'],
      name: json['name'],
      cost: json['cost'],
      description: json['description'],
      type: json['type'],
      effect: ItemEffect.fromJson(json['effect']),
    );
  }
}

class ItemConfig {
  static ItemConfig? _instance;
  static ItemConfig get instance => _instance ??= ItemConfig._();
  
  ItemConfig._();
  
  List<ItemData> _items = [];
  bool _loaded = false;
  
  List<ItemData> get items => _items;
  
  Future<void> loadConfig() async {
    if (_loaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/config/items.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _items = (jsonData['items'] as List)
          .map((item) => ItemData.fromJson(item))
          .toList();
      
      _loaded = true;
    } catch (e) {
      print('Error loading item config: $e');
      // Fallback to empty list if loading fails
      _items = [];
      _loaded = true;
    }
  }
  
  ItemData? getItemById(String id) {
    return _items.where((item) => item.id == id).firstOrNull;
  }
  
  List<ItemData> getItemsByType(String type) {
    return _items.where((item) => item.type == type).toList();
  }
} 