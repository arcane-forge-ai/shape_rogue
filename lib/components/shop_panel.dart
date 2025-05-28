import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';
import '../config/item_config.dart';

class ShopItem {
  final String id;
  final String name;
  final int cost;
  final String description;
  final void Function() onPurchase;
  
  ShopItem({
    required this.id,
    required this.name,
    required this.cost,
    required this.description,
    required this.onPurchase,
  });
  
  factory ShopItem.fromItemData(ItemData itemData, void Function() onPurchase) {
    return ShopItem(
      id: itemData.id,
      name: itemData.name,
      cost: itemData.cost,
      description: itemData.description,
      onPurchase: onPurchase,
    );
  }
}

class ShopPanel extends RectangleComponent with HasGameRef<CircleRougeGame>, TapCallbacks {
  late List<ShopSlot> itemSlots;
  late RectangleComponent rollButton;
  late TextComponent rollButtonText;
  late TextComponent titleText;
  late TextComponent instructionText;
  
  bool isVisible = false;
  
  static const double panelWidth = 600.0;
  static const double panelHeight = 450.0;
  static const double slotWidth = 150.0;
  static const double slotHeight = 200.0;
  static const double slotSpacing = 40.0;
  
  ShopPanel() : super(
    size: Vector2(panelWidth, panelHeight),
    paint: Paint()..color = const Color(0xDD000000), // More opaque black
    position: Vector2(
      (CircleRougeGame.arenaWidth - panelWidth) / 2,
      (CircleRougeGame.arenaHeight - panelHeight) / 2,
    ),
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Add border
    final border = RectangleComponent(
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white,
      position: Vector2.zero(),
    );
    add(border);
    
    // Title
    titleText = TextComponent(
      text: 'Shop - Choose Your Upgrades',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(panelWidth / 2, 20),
    );
    add(titleText);
    
    // Instructions
    final instructionText = TextComponent(
      text: 'Click Roll to get new items, Click Continue to proceed to next wave',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(panelWidth / 2, 50),
    );
    add(instructionText);
    
    // Create item slots
    itemSlots = [];
    for (int i = 0; i < 3; i++) {
      final slot = ShopSlot(
        position: Vector2(
          (panelWidth - (3 * slotWidth + 2 * slotSpacing)) / 2 + i * (slotWidth + slotSpacing),
          80,
        ),
      );
      itemSlots.add(slot);
      add(slot);
    }
    
    // Roll button
    rollButton = RectangleComponent(
      size: Vector2(100, 35),
      paint: Paint()..color = const Color(0xFF2196F3),
      position: Vector2((panelWidth - 100) / 2 - 60, panelHeight - 60),
    );
    add(rollButton);
    
    rollButtonText = TextComponent(
      text: 'Roll (10)',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(50, 17.5),
    );
    rollButton.add(rollButtonText);
    
    // Continue button
    final continueButton = RectangleComponent(
      size: Vector2(100, 35),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2((panelWidth - 100) / 2 + 60, panelHeight - 60),
    );
    add(continueButton);
    
    final continueButtonText = TextComponent(
      text: 'Continue',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(50, 17.5),
    );
    continueButton.add(continueButtonText);
    
    // Store continue button reference for tap detection
    continueButton.add(Component());
    continueButton.children.register<Component>();
    
    // Initially hidden
    hide();
    
    // Populate with initial items
    rollShopItems();
  }
  
  void show() {
    isVisible = true;
    opacity = 1.0;
  }
  
  void hide() {
    isVisible = false;
    opacity = 0.0;
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!isVisible) return false;
    
    final localPoint = event.localPosition;
    
    // Check if roll button was tapped
    final rollButtonRect = Rect.fromLTWH(
      rollButton.position.x,
      rollButton.position.y,
      rollButton.size.x,
      rollButton.size.y,
    );
    
    if (rollButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      rollShopItems();
      return true;
    }
    
    // Check if continue button was tapped
    final continueButtonPosition = Vector2((panelWidth - 100) / 2 + 60, panelHeight - 60);
    final continueButtonRect = Rect.fromLTWH(
      continueButtonPosition.x,
      continueButtonPosition.y,
      100,
      35,
    );
    
    if (continueButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      closeShop();
      return true;
    }
    
    return false;
  }
  
  void rollShopItems() {
    // Check if all items are sold (free roll)
    final allItemsSold = itemSlots.every((slot) => slot.currentItem == null);
    final rollCost = allItemsSold ? 0 : 10;
    
    // Check if player has enough coins to roll
    if (gameRef.hero.coins < rollCost) {
      return; // Not enough coins to roll
    }
    
    // Spend coins for rolling (if not free)
    if (rollCost > 0) {
      gameRef.hero.spendCoins(rollCost);
      gameRef.hud.updateCoins(gameRef.hero.coins);
    }
    
    final availableItems = _getAvailableItems();
    final random = Random();
    
    for (int i = 0; i < 3; i++) {
      if (availableItems.isNotEmpty) {
        final randomItem = availableItems[random.nextInt(availableItems.length)];
        itemSlots[i].setItem(randomItem);
      }
    }
    
    // Update roll button text after rolling (now items are available, so cost is 10)
    rollButtonText.text = 'Roll (10)';
  }
  
  List<ShopItem> _getAvailableItems() {
    final itemConfig = ItemConfig.instance;
    return itemConfig.items.map((itemData) {
      // Create dynamic name for ability cooldown reduction based on hero's ability
      if (itemData.id == 'dash_mastery') {
        final heroAbilityName = gameRef.hero.heroData.ability.name;
        return ShopItem(
          id: itemData.id,
          name: '$heroAbilityName Mastery',
          cost: itemData.cost,
          description: '-25% ${heroAbilityName} Cooldown',
          onPurchase: () => _applyItemEffect(itemData),
        );
      }
      return ShopItem.fromItemData(itemData, () => _applyItemEffect(itemData));
    }).toList();
  }
  
  void _applyItemEffect(ItemData itemData) {
    switch (itemData.effect.type) {
      case 'heal':
        final healAmount = (gameRef.hero.maxHealth - gameRef.hero.health).clamp(0.0, itemData.effect.value);
        gameRef.hero.heal(healAmount);
        break;
      case 'dash_cooldown_multiplier':
        // Apply ability cooldown reduction
        gameRef.hero.abilityCooldownMultiplier *= itemData.effect.value;
        break;
      case 'max_health_increase':
        gameRef.hero.maxHealth += itemData.effect.value;
        gameRef.hero.health += itemData.effect.value;
        break;
      case 'attack_speed_multiplier':
        gameRef.hero.attackSpeedMultiplier += itemData.effect.value;
        break;
      case 'speed_multiplier':
        gameRef.hero.speedMultiplier += itemData.effect.value;
        break;
      default:
        print('Unknown item effect type: ${itemData.effect.type}');
    }
  }
  
  void onItemPurchased() {
    // Update HUD after purchase
    gameRef.hud.updateCoins(gameRef.hero.coins);
    
    // Update roll button text based on remaining items
    final allItemsSold = itemSlots.every((slot) => slot.currentItem == null);
    final rollCost = allItemsSold ? 0 : 10;
    rollButtonText.text = rollCost == 0 ? 'Roll (Free)' : 'Roll ($rollCost)';
  }
  
  void closeShop() {
    hide();
    gameRef.onShopClosed();
  }
}

class ShopSlot extends RectangleComponent with TapCallbacks, HasGameRef<CircleRougeGame> {
  late TextComponent nameText;
  late TextComponent costText;
  late TextComponent descriptionText;
  late RectangleComponent buyButton;
  late TextComponent buyButtonText;
  
  ShopItem? currentItem;
  
  ShopSlot({required Vector2 position}) : super(
    size: Vector2(ShopPanel.slotWidth, ShopPanel.slotHeight),
    paint: Paint()..color = const Color(0xFF424242),
    position: position,
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Item name
    nameText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 15),
    );
    add(nameText);
    
    // Item description
    descriptionText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 45),
    );
    add(descriptionText);
    
    // Cost
    costText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFEB3B),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 90),
    );
    add(costText);
    
    // Buy button
    buyButton = RectangleComponent(
      size: Vector2(100, 25),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2((size.x - 100) / 2, size.y - 40),
    );
    add(buyButton);
    
    buyButtonText = TextComponent(
      text: 'Buy',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(50, 12.5),
    );
    buyButton.add(buyButtonText);
  }
  
  void setItem(ShopItem item) {
    currentItem = item;
    nameText.text = item.name;
    descriptionText.text = item.description;
    costText.text = '${item.cost} coins';
    
    // Update buy button color based on affordability
    if (gameRef.hero.coins >= item.cost) {
      buyButton.paint.color = const Color(0xFF4CAF50); // Green
    } else {
      buyButton.paint.color = const Color(0xFF757575); // Grey
    }
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (currentItem == null) return false;
    
    // Check if buy button was tapped
    final localPoint = event.localPosition;
    if (buyButton.containsLocalPoint(localPoint - buyButton.position)) {
      attemptPurchase();
      return true;
    }
    
    return false;
  }
  
  void attemptPurchase() {
    if (currentItem == null) return;
    
    if (gameRef.hero.coins >= currentItem!.cost) {
      gameRef.hero.spendCoins(currentItem!.cost);
      currentItem!.onPurchase();
      
      // Clear this slot
      currentItem = null;
      nameText.text = 'SOLD';
      descriptionText.text = '';
      costText.text = '';
      buyButton.paint.color = const Color(0xFF757575);
      
      // Update parent shop immediately
      if (parent is ShopPanel) {
        (parent as ShopPanel).onItemPurchased();
      }
    }
  }
} 