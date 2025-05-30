import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../game/circle_rouge_game.dart';
import '../config/item_config.dart';
import 'sound_manager.dart';

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
  late RectangleComponent backgroundGradient;
  late RectangleComponent headerPanel;
  late RectangleComponent footerPanel;
  
  bool isVisible = false;
  
  static const double panelWidth = 650.0;
  static const double panelHeight = 500.0;
  static const double slotWidth = 160.0;
  static const double slotHeight = 250.0;
  static const double slotSpacing = 45.0;
  
  ShopPanel() : super(
    size: Vector2(panelWidth, panelHeight),
    paint: Paint()..color = Colors.transparent,
    position: Vector2(
      (CircleRougeGame.arenaWidth - panelWidth) / 2,
      (CircleRougeGame.arenaHeight - panelHeight) / 2,
    ),
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Background with enhanced gradient effect
    backgroundGradient = RectangleComponent(
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D2D4A),
            Color(0xFF1E1E3A),
            Color(0xFF151528),
          ],
        ).createShader(Rect.fromLTWH(0, 0, panelWidth, panelHeight)),
      position: Vector2.zero(),
    );
    add(backgroundGradient);
    
    // Main border with enhanced glow effect
    final border = RectangleComponent(
      size: Vector2(panelWidth, panelHeight),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF4A9EFF).withOpacity(0.6),
      position: Vector2.zero(),
    );
    add(border);
    
    // Outer glow effect
    final outerGlow = RectangleComponent(
      size: Vector2(panelWidth + 10, panelHeight + 10),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xFF4A9EFF).withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      position: Vector2(-5, -5),
    );
    add(outerGlow);
    
    // Header panel with gradient
    headerPanel = RectangleComponent(
      size: Vector2(panelWidth - 20, 90),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF4A9EFF),
            Color(0xFF9C27B0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, panelWidth - 20, 90))
        ..color = const Color(0xFF4A9EFF).withOpacity(0.15),
      position: Vector2(10, 10),
    );
    add(headerPanel);
    
    // Header border with glow
    final headerBorder = RectangleComponent(
      size: Vector2(panelWidth - 20, 90),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4A9EFF).withOpacity(0.6),
      position: Vector2(10, 10),
    );
    add(headerBorder);
    
    // Title with enhanced styling and shader mask effect
    titleText = TextComponent(
      text: '🛍️ MYSTICAL SHOP',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white, // This will be overridden by the gradient
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
          shadows: [
            Shadow(
              color: Color(0xFF4A9EFF),
              blurRadius: 12,
            ),
            Shadow(
              color: Color(0xFF9C27B0),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(panelWidth / 2, 30),
    );
    add(titleText);
    
    // Instructions with enhanced styling
    instructionText = TextComponent(
      text: '✨ Enhance your hero with powerful upgrades ✨',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(panelWidth / 2, 70),
    );
    add(instructionText);
    
    // Create item slots with better positioning
    itemSlots = [];
    final slotsStartX = (panelWidth - (3 * slotWidth + 2 * slotSpacing)) / 2;
    for (int i = 0; i < 3; i++) {
      final slot = ShopSlot(
        position: Vector2(
          slotsStartX + i * (slotWidth + slotSpacing),
          110,
        ),
      );
      itemSlots.add(slot);
      add(slot);
    }
    
    // Footer panel with gradient background
    footerPanel = RectangleComponent(
      size: Vector2(panelWidth - 20, 70),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF2D2D4A),
            Color(0xFF1E1E3A),
          ],
        ).createShader(Rect.fromLTWH(0, 0, panelWidth - 20, 70))
        ..color = const Color(0xFF2D2D4A).withOpacity(0.6),
      position: Vector2(10, panelHeight - 80),
    );
    add(footerPanel);
    
    // Footer border
    final footerBorder = RectangleComponent(
      size: Vector2(panelWidth - 20, 70),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4A9EFF).withOpacity(0.3),
      position: Vector2(10, panelHeight - 80),
    );
    add(footerBorder);
    
    // Roll button with enhanced gradient styling
    rollButton = RectangleComponent(
      size: Vector2(140, 45),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 140, 45)),
      position: Vector2((panelWidth - 140) / 2 - 90, panelHeight - 65),
    );
    add(rollButton);
    
    // Roll button glow effect
    final rollButtonGlow = RectangleComponent(
      size: Vector2(140, 45),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF2196F3).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      position: Vector2((panelWidth - 140) / 2 - 90, panelHeight - 65),
    );
    add(rollButtonGlow);
    
    rollButtonText = TextComponent(
      text: 'ROLL (10)',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(70, 22.5),
    );
    rollButton.add(rollButtonText);
    
    // Continue button with enhanced gradient styling
    final continueButton = RectangleComponent(
      size: Vector2(140, 45),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF388E3C),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 140, 45)),
      position: Vector2((panelWidth - 140) / 2 + 90, panelHeight - 65),
    );
    add(continueButton);
    
    // Continue button glow effect
    final continueButtonGlow = RectangleComponent(
      size: Vector2(140, 45),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF4CAF50).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      position: Vector2((panelWidth - 140) / 2 + 90, panelHeight - 65),
    );
    add(continueButtonGlow);
    
    final continueButtonText = TextComponent(
      text: 'CONTINUE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(70, 22.5),
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
      140,
      45,
    );
    
    if (rollButtonRect.contains(Offset(localPoint.x, localPoint.y))) {
      rollShopItems();
      return true;
    }
    
    // Check if continue button was tapped
    final continueButtonPosition = Vector2((panelWidth - 140) / 2 + 90, panelHeight - 65);
    final continueButtonRect = Rect.fromLTWH(
      continueButtonPosition.x,
      continueButtonPosition.y,
      140,
      45,
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
    rollButtonText.text = 'ROLL (10)';
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
    // Update roll button text based on remaining items
    final allItemsSold = itemSlots.every((slot) => slot.currentItem == null);
    final rollCost = allItemsSold ? 0 : 10;
    rollButtonText.text = rollCost == 0 ? 'ROLL (FREE)' : 'ROLL ($rollCost)';
  }
  
  void closeShop() {
    hide();
    gameRef.onShopClosed();
  }
}

class ShopSlot extends RectangleComponent with TapCallbacks, HasGameRef<CircleRougeGame> {
  late TextBoxComponent nameText;
  late TextComponent costText;
  late TextComponent descriptionText;
  late RectangleComponent buyButton;
  late TextComponent buyButtonText;
  late SpriteComponent itemIcon;
  late RectangleComponent border;
  late RectangleComponent outerGlow;
  late RectangleComponent buyButtonGlow;
  
  ShopItem? currentItem;
  
  ShopSlot({required Vector2 position}) : super(
    size: Vector2(ShopPanel.slotWidth, ShopPanel.slotHeight),
    paint: Paint()..color = Colors.transparent,
    position: position,
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Background with enhanced gradient
    final background = RectangleComponent(
      size: Vector2(size.x, size.y),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3A3A3A),
            Color(0xFF2A2A2A),
            Color(0xFF1A1A1A),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
      position: Vector2.zero(),
    );
    add(background);
    
    // Border with enhanced glow
    border = RectangleComponent(
      size: Vector2(size.x, size.y),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4A9EFF).withOpacity(0.5),
      position: Vector2.zero(),
    );
    add(border);
    
    // Outer glow effect for slots
    outerGlow = RectangleComponent(
      size: Vector2(size.x + 4, size.y + 4),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(0xFF4A9EFF).withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      position: Vector2(-2, -2),
    );
    add(outerGlow);
    
    // Item icon background with enhanced styling
    final iconBackground = RectangleComponent(
      size: Vector2(50, 50),
      paint: Paint()
        ..color = Colors.black.withOpacity(0.3),
      position: Vector2((size.x - 50) / 2, 15),
    );
    add(iconBackground);
    
    // Item icon border
    final iconBorder = RectangleComponent(
      size: Vector2(50, 50),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4A9EFF).withOpacity(0.3),
      position: Vector2((size.x - 50) / 2, 15),
    );
    add(iconBorder);
    
    // Item icon - start with empty sprite
    itemIcon = SpriteComponent(
      size: Vector2(40, 40),
      position: Vector2((size.x - 40) / 2, 20),
    );
    add(itemIcon);
    
    // Item name with enhanced styling and line wrapping
    nameText = TextBoxComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF4A9EFF),
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: Color(0xFF4A9EFF),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      align: Anchor.center,
      boxConfig: TextBoxConfig(
        maxWidth: size.x - 10, // Leave some padding on sides
        timePerChar: 0.0, // Instant display, no typewriter effect
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 75),
    );
    add(nameText);
    
    // Item description with better styling
    descriptionText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 120),
    );
    add(descriptionText);
    
    // Cost with enhanced styling
    costText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFEB3B),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: Color(0xFFFFEB3B),
              blurRadius: 8,
            ),
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 155),
    );
    add(costText);
    
    // Buy button with enhanced gradient styling
    buyButton = RectangleComponent(
      size: Vector2(130, 40),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF388E3C),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 130, 40)),
      position: Vector2((size.x - 130) / 2, size.y - 55),
    );
    add(buyButton);
    
    // Buy button glow effect
    buyButtonGlow = RectangleComponent(
      size: Vector2(130, 40),
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF4CAF50).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      position: Vector2((size.x - 130) / 2, size.y - 55),
    );
    add(buyButtonGlow);
    
    buyButtonText = TextComponent(
      text: 'PURCHASE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(65, 20),
    );
    buyButton.add(buyButtonText);
  }
  
  // Get category colors based on item type
  Map<String, Color> _getCategoryColors(String itemId) {
    switch (itemId) {
      case 'health_potion':
      case 'max_health_up':
        // Green for health items
        return {
          'primary': const Color(0xFF4CAF50),
          'secondary': const Color(0xFF66BB6A),
          'glow': const Color(0xFF4CAF50),
        };
      case 'attack_speed_up':
        // Red for attack items
        return {
          'primary': const Color(0xFFF44336),
          'secondary': const Color(0xFFE57373),
          'glow': const Color(0xFFF44336),
        };
      case 'speed_boost':
        // Blue for speed items
        return {
          'primary': const Color(0xFF2196F3),
          'secondary': const Color(0xFF64B5F6),
          'glow': const Color(0xFF2196F3),
        };
      case 'dash_mastery':
        // Hero color for ability items
        final heroColor = gameRef.hero.heroData.color;
        return {
          'primary': heroColor,
          'secondary': heroColor.withOpacity(0.8),
          'glow': heroColor,
        };
      default:
        // Default blue theme
        return {
          'primary': const Color(0xFF4A9EFF),
          'secondary': const Color(0xFF64B5F6),
          'glow': const Color(0xFF4A9EFF),
        };
    }
  }

  void setItem(ShopItem item) {
    currentItem = item;
    final colors = _getCategoryColors(item.id);
    
    nameText.text = item.name.toUpperCase();
    descriptionText.text = item.description;
    costText.text = '💰 ${item.cost} COINS';
    
    // Update name text color to match category
    nameText.textRenderer = TextPaint(
      style: TextStyle(
        color: colors['primary']!,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        shadows: [
          Shadow(
            color: colors['glow']!,
            blurRadius: 6,
          ),
        ],
      ),
    );
    
    // Update border and glow colors to match category
    border.paint.color = colors['primary']!.withOpacity(0.6);
    outerGlow.paint.color = colors['glow']!.withOpacity(0.15);
    
    // Update buy button styling based on affordability and category
    if (gameRef.hero.coins >= item.cost) {
      // Update buy button gradient with category colors
      buyButton.paint.shader = LinearGradient(
        colors: [
          colors['primary']!,
          colors['secondary']!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, 130, 40));
      
      buyButtonGlow.paint.color = colors['glow']!.withOpacity(0.5);
      buyButtonText.text = 'PURCHASE';
    } else {
      // Grey for unaffordable items
      buyButton.paint.shader = const LinearGradient(
        colors: [
          Color(0xFF757575),
          Color(0xFF616161),
        ],
      ).createShader(Rect.fromLTWH(0, 0, 130, 40));
      
      buyButtonGlow.paint.color = const Color(0xFF757575).withOpacity(0.3);
      buyButtonText.text = 'TOO EXPENSIVE';
      border.paint.color = const Color(0xFFF44336).withOpacity(0.4);
    }
    
    // Load appropriate image based on item ID
    _loadItemIcon(item.id);
  }
  
  Future<void> _loadItemIcon(String itemId) async {
    String imagePath;
    
    // Map item IDs to their corresponding transparent images
    switch (itemId) {
      case 'health_potion':
        imagePath = 'health_potion_transparent.png';
        break;
      case 'speed_boost':
        imagePath = 'speed_boost_transparent.png';
        break;
      case 'attack_speed_up':
        imagePath = 'attack_speed_transparent.png';
        break;
      case 'max_health_up':
        imagePath = 'max_health_up_transparent.png';
        break;
      case 'dash_mastery':
        imagePath = 'ability_mastery_transparent.png';
        break;
      default:
        imagePath = 'ability_mastery_transparent.png'; // fallback
        break;
    }
    
    try {
      final sprite = await Sprite.load(imagePath);
      itemIcon.sprite = sprite;
    } catch (e) {
      print('Failed to load item icon: $imagePath');
      // Keep the sprite empty if loading fails
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
      
      // Play purchase sound effect
      SoundManager().playPurchaseSound();
      
      // Clear this slot with enhanced sold styling
      currentItem = null;
      nameText.text = '✅ SOLD';
      nameText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: Color(0xFF4CAF50),
              blurRadius: 6,
            ),
          ],
        ),
      );
      descriptionText.text = 'Item purchased successfully!';
      descriptionText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      );
      costText.text = '';
      
      // Update buy button to sold out styling
      buyButton.paint.shader = const LinearGradient(
        colors: [
          Color(0xFF757575),
          Color(0xFF616161),
        ],
      ).createShader(Rect.fromLTWH(0, 0, 130, 40));
      
      buyButtonGlow.paint.color = const Color(0xFF757575).withOpacity(0.3);
      buyButtonText.text = 'SOLD OUT';
      
      // Update border and glow to success green
      border.paint.color = const Color(0xFF4CAF50).withOpacity(0.8);
      outerGlow.paint.color = const Color(0xFF4CAF50).withOpacity(0.2);
      
      itemIcon.sprite = null; // Clear the sprite for sold items
      
      // Update parent shop immediately
      if (parent is ShopPanel) {
        (parent as ShopPanel).onItemPurchased();
      }
    }
  }
} 