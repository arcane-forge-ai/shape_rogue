## Playtest Plan: One Full Run (5 Waves)

### 1. Objectives
- **Core Loop Validation:** Movement, dash, enemy AI, shop flow  
- **Difficulty Curve:** Ensure each wave ramps appropriately  
- **Shop Integration:** Confirm shop appears, purchases work, and roll logic  
- **Stability & Performance:** No crashes or major slow‐downs

---

### 2. Test Setup
- **Scene:** 10×10 grid using `arena_tile_placeholder.png`  
- **Hero:** Top-down prefab with WSAD/mouse + “Ability1” dash  
- **Enemies:**  
  - `Enemy_Chaser` (speed 4.0)  
  - `Enemy_Shooter` (speed 2.5, attackRange 6.0, fireRate 1.5)  
- **Shop Panel:** Visible automatically between waves with 3 placeholder slots  

---

### 3. Wave Definitions

| Wave | Enemies                              |
|------|--------------------------------------|
| 1    | 3 × Chaser                           |
| 2    | 2 × Shooter                          |
| 3    | 2 × Chaser, 2 × Shooter              |
| 4    | 5 × Chaser                           |
| 5    | 3 × Chaser, 3 × Shooter              |

---

### 4. Playtest Steps
1. **Start Wave N**  
   - Spawn enemies per table; start timer.  
2. **Combat**  
   - Player uses movement & dash to defeat all enemies.  
3. **Wave Clear**  
   - All enemies down → stop timer → show shop panel.  
4. **Shop Phase**  
   - Allow buys and/or roll → record coins before/after.  
   - Close panel and proceed.  
5. **Repeat** for Waves 1 → 5.  
6. **End Run**  
   - After wave 5 clear → present summary.

---

### 5. Metrics & Feedback
- **Quantitative Logs** (console/file):
  ```json
  {
    "wave": 1,
    "clearTime": 12.3,
    "endHealth": 85,
    "coinsBefore": 0,
    "coinsAfter": 50,
    "dashUses": 3
  }
  ```

