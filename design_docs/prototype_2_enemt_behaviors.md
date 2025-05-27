## Prototype #2: Enemy Behaviors

### 1. Objective  
Implement two enemy AI patterns with immediate aggro on spawn:  
1. **Chaser:** Pursues the player constantly.  
2. **Shooter:** Keeps distance, fires projectiles, and retreats if too close.

---

### 2. Behavior Specs

| ID               | Type    | Properties                                      | Behavior Summary                                  |
|------------------|---------|-------------------------------------------------|---------------------------------------------------|
| `Enemy_Chaser`   | Chaser  | `speed`: 4.0                                    | Always moves toward the player                     |
| `Enemy_Shooter`  | Shooter | `speed`: 2.5<br>`attackRange`: 6.0<br>`fireRate`: 1.5 | Faces player;<br>if in range, fires;<br>else retreats |

---

### 3. Pseudo-Logic

```pseudo
// Enemy_Chaser onUpdate:
moveTowards(player.position, speed)
```pseudo

```pseudo
// Enemy_Shooter onUpdate:
face(player.position)
if distanceTo(player) <= attackRange and canFire():
    fireProjectile(at=player.position)
else:
    moveAwayFrom(player.position, speed)
```

---

### 4. Prototype Plan & Steps

1. **Create Base Enemy Prefab**  
   - Add `EnemyAI` script with common fields (e.g., `speed`).  
2. **Implement Chaser**  
   - Script `Enemy_Chaser`: override `onUpdate()` with chaser logic.  
3. **Implement Shooter**  
   - Script `Enemy_Shooter`: include projectile prefab, `attackRange`, `fireRate`, and retreat logic.  
4. **Scene Setup & Testing**  
   - Place one of each in a sample map.  
   - Verify behaviors: Chaser pursues; Shooter fires and backs off.  
5. **Iterate & Tune**  
   - Adjust `speed`, `attackRange`, `fireRate` for gameplay balance.

---

### 5. AI-Friendly Component Spec (JSON)

```json
[
  {
    "id": "Enemy_Chaser",
    "type": "Component",
    "properties": {
      "speed": 4.0
    },
    "methods": {
      "onUpdate": "runChaseLogic()"
    }
  },
  {
    "id": "Enemy_Shooter",
    "type": "Component",
    "properties": {
      "speed": 2.5,
      "attackRange": 6.0,
      "fireRate": 1.5
    },
    "methods": {
      "onUpdate": "runShooterLogic()",
      "fireProjectile": "spawnProjectile()"
    }
  }
]
```

[TO-DO]  
- Create and assign projectile prefab  
- Hook up firing SFX/VFX  
- Fine-tune parameters for desired difficulty  
