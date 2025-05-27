## HUD & Shop Node Wireframe

### 1. Target Resolution & Layout Grid
- **Base resolution:** 1920 × 1080 (16:9)  
- **UI safe area:** 5% margin on all sides  
- **Grid:** 12 × 12 (for snapping and responsive scaling)  

---

### 2. HUD Elements

| ID                   | Type        | Anchor     | Offset (px) | Size (px) | Data Source        | Notes                          |
|----------------------|-------------|------------|-------------|-----------|--------------------|--------------------------------|
| `hud_health_bar`     | ProgressBar | top_left   | [10, 10]    | [300, 25] | `player.health`    | max=100                        |
| `hud_energy_bar`     | ProgressBar | top_left   | [10, 45]    | [300, 15] | `player.energy`    | max=100                        |
| `hud_coin_counter`   | Text        | top_right  | [-10, 10]   | auto      | `player.coins`     | fontSize=24, icon="coin.png"   |
| `hud_wave_indicator` | Text        | top_center | [0, 10]     | auto      | `"Wave " + waveNo` |                                |
| `hud_pause_button`   | Button      | top_right  | [-10, 60]   | [40, 40]  | —                  | icon="pause.png", onClick=PauseGame |

---

### 3. Shop Node

#### 3.1 Trigger
- **Between rounds**, automatically show the shop panel in the center of the map.  
- No “open” or “close” buttons.

#### 3.2 Shop Overlay Panel
- **ID:** `shop_panel`  
- **Type:** Panel/Window  
- **Anchor:** center  
- **Size:** [800, 600]  
- **Visible:** false (set to true between rounds)  
- **Background:** semi-transparent dark  

##### 3.2.1 Item Slots
- **Display:** 3 items per roll  
- **Layout:** horizontal list, equal spacing  
- **Slot IDs:** `shop_item_0`, `shop_item_1`, `shop_item_2`  
- **Each Slot Contains:**  
  - `icon` (Image)  
  - `name` (Text)  
  - `cost` (Text + coin icon)  
  - `buy_button` (Button; onClick=`attemptPurchase(itemId)`)

##### 3.2.2 Roll Button
- **ID:** `shop_roll_button`  
- **Type:** Button  
- **Parent:** `shop_panel`  
- **Anchor:** bottom_center  
- **Offset:** [0, –20]  
- **Size:** [120, 40]  
- **Text:** “Roll”  
- **onClick:** `rollShopItems()`

---

### 4. Interaction Flow
1. **Between Rounds**  
   - Game engine:  
     ```js
     shop_panel.visible = true;
     populateShopItems(3);
     ```
2. **Browse & Buy**  
   - Player clicks a slot’s `buy_button` →  
     - check `player.coins >= cost`  
     - if OK: deduct cost, grant item, update `hud_coin_counter`  
     - play purchase SFX; disable or gray out button if coins < cost  
3. **Roll**  
   - Player clicks `shop_roll_button` →  
     - (optional: deduct roll cost)  
     - `populateShopItems(3)`  
     - play roll animation/SFX  
4. **Start Next Round**  
   - After purchases or timeout:  
     ```js
     shop_panel.visible = false;
     startNextWave();
     ```

---

### 5. AI-Friendly UI Spec (JSON)
```json
[
  {
    "id": "shop_panel",
    "type": "Panel",
    "anchor": "center",
    "size": [800, 600],
    "visible": false
  },
  {
    "id": "shop_item_0",
    "type": "ShopSlot",
    "parent": "shop_panel",
    "gridIndex": 0,
    "components": {
      "icon":      { "type": "Image" },
      "name":      { "type": "Text"  },
      "cost":      { "type": "Text"  },
      "buy_button":{ "type": "Button", "onClick": "attemptPurchase" }
    }
  },
  {
    "id": "shop_item_1",
    "type": "ShopSlot",
    "parent": "shop_panel",
    "gridIndex": 1,
    "components": {
      "icon":      { "type": "Image" },
      "name":      { "type": "Text"  },
      "cost":      { "type": "Text"  },
      "buy_button":{ "type": "Button", "onClick": "attemptPurchase" }
    }
  },
  {
    "id": "shop_item_2",
    "type": "ShopSlot",
    "parent": "shop_panel",
    "gridIndex": 2,
    "components": {
      "icon":      { "type": "Image" },
      "name":      { "type": "Text"  },
      "cost":      { "type": "Text"  },
      "buy_button":{ "type": "Button", "onClick": "attemptPurchase" }
    }
  },
  {
    "id": "shop_roll_button",
    "type": "Button",
    "parent": "shop_panel",
    "anchor": "bottom_center",
    "offset": [0, -20],
    "size": [120, 40],
    "text": "Roll",
    "onClick": "rollShopItems"
  }
]
```