import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';

class ShopItem {
  final String name;
  final int cost;
  final String description;
  final void Function() onPurchase;
  
  ShopItem({
    required this.name,
    required this.cost,
    required this.description,
    required this.onPurchase,
  });
}

class ShopPanel extends RectangleComponent with HasGameRef<CircleRougeGame>, TapCallbacks {
  late List<ShopSlot> itemSlots;
  late RectangleComponent rollButton;
  late TextComponent rollButtonText;
  late TextComponent titleText;
  late TextComponent instructionText;
  
  bool isVisible = false;
  
  static const double panelWidth = 800.0;
  static const double panelHeight = 600.0;
  static const double slotWidth = 200.0;
  static const double slotHeight = 250.0;
  static const double slotSpacing = 50.0;
  
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
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(panelWidth / 2, 30),
    );
    add(titleText);
    
    // Instructions
    final instructionText = TextComponent(
      text: 'Click Roll to get new items, Click Continue to proceed to next wave',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(panelWidth / 2, 70),
    );
    add(instructionText);
    
    // Create item slots
    itemSlots = [];
    for (int i = 0; i < 3; i++) {
      final slot = ShopSlot(
        position: Vector2(
          (panelWidth - (3 * slotWidth + 2 * slotSpacing)) / 2 + i * (slotWidth + slotSpacing),
          100,
        ),
      );
      itemSlots.add(slot);
      add(slot);
    }
    
    // Roll button
    rollButton = RectangleComponent(
      size: Vector2(120, 40),
      paint: Paint()..color = const Color(0xFF2196F3),
      position: Vector2((panelWidth - 120) / 2 - 70, panelHeight - 80),
    );
    add(rollButton);
    
    rollButtonText = TextComponent(
      text: 'Roll (10)',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(60, 20),
    );
    rollButton.add(rollButtonText);
    
    // Continue button
    final continueButton = RectangleComponent(
      size: Vector2(120, 40),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2((panelWidth - 120) / 2 + 70, panelHeight - 80),
    );
    add(continueButton);
    
    final continueButtonText = TextComponent(
      text: 'Continue',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(60, 20),
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
    final continueButtonPosition = Vector2((panelWidth - 120) / 2 + 70, panelHeight - 80);
    final continueButtonRect = Rect.fromLTWH(
      continueButtonPosition.x,
      continueButtonPosition.y,
      120,
      40,
    );
    
    if (continueButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      closeShop();
      return true;
    }
    
    return false;
  }
  
  void rollShopItems() {
    // Check if player has enough coins to roll
    if (gameRef.hero.coins < 10) {
      return; // Not enough coins to roll
    }
    
    // Spend coins for rolling
    gameRef.hero.spendCoins(10);
    gameRef.hud.updateCoins(gameRef.hero.coins);
    
    final availableItems = _getAvailableItems();
    final random = Random();
    
    for (int i = 0; i < 3; i++) {
      if (availableItems.isNotEmpty) {
        final randomItem = availableItems[random.nextInt(availableItems.length)];
        itemSlots[i].setItem(randomItem);
      }
    }
  }
  
  List<ShopItem> _getAvailableItems() {
    return [
      ShopItem(
        name: 'Health Potion',
        cost: 30,
        description: 'Restore 50 HP',
        onPurchase: () {
          final healAmount = (gameRef.hero.maxHealth - gameRef.hero.health).clamp(0.0, 50.0);
          gameRef.hero.heal(healAmount);
        },
      ),
      ShopItem(
        name: 'Energy Boost',
        cost: 25,
        description: 'Restore full energy',
        onPurchase: () => gameRef.hero.energy = gameRef.hero.maxEnergy,
      ),
      ShopItem(
        name: 'Max Health Up',
        cost: 50,
        description: '+25 Max Health',
        onPurchase: () {
          gameRef.hero.maxHealth += 25;
          gameRef.hero.health += 25;
        },
      ),
      ShopItem(
        name: 'Attack Speed Up',
        cost: 60,
        description: '+25% Attack Speed',
        onPurchase: () {
          gameRef.hero.attackSpeedMultiplier += 0.25;
        },
      ),
      ShopItem(
        name: 'Speed Boost',
        cost: 40,
        description: 'Temporary speed increase',
        onPurchase: () {
          // TODO: Implement temporary speed boost
        },
      ),
    ];
  }
  
  void onItemPurchased() {
    // Update HUD after purchase
    gameRef.hud.updateCoins(gameRef.hero.coins);
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
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 20),
    );
    add(nameText);
    
    // Item description
    descriptionText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 60),
    );
    add(descriptionText);
    
    // Cost
    costText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFEB3B),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 120),
    );
    add(costText);
    
    // Buy button
    buyButton = RectangleComponent(
      size: Vector2(120, 30),
      paint: Paint()..color = const Color(0xFF4CAF50),
      position: Vector2((size.x - 120) / 2, size.y - 50),
    );
    add(buyButton);
    
    buyButtonText = TextComponent(
      text: 'Buy',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(60, 15),
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
      
      // Update parent shop
      if (parent is ShopPanel) {
        (parent as ShopPanel).onItemPurchased();
      }
      
      // Clear this slot
      currentItem = null;
      nameText.text = 'SOLD';
      descriptionText.text = '';
      costText.text = '';
      buyButton.paint.color = const Color(0xFF757575);
    }
  }
} 