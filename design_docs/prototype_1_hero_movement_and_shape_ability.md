## Prototype #1: Hero Movement & Shape Ability

### 1. Objective  
- **Hero Movement:** Top-down 2D movement on X/Y axes using WSAD/Arrow controls.  
- **Shape Ability:** “Circle Dash” — a quick dash in the input direction with cooldown.

---

### 2. Hero Movement Spec

| Property    | Type   | Default | Notes                                      |
|-------------|--------|---------|--------------------------------------------|
| `moveSpeed` | Float  | 6.0     | Units per second for 2D planar movement    |

#### 2.1. Controls & Flow  
```pseudo
// Called each frame:
inputX = getAxis("Horizontal")  // A/D or Left/Right: -1 to +1
inputY = getAxis("Vertical")    // W/S or Up/Down: -1 to +1
moveDirection = normalize(Vector2(inputX, inputY))
velocity = moveDirection * moveSpeed
characterController.Move(Vector3(velocity.x, 0, velocity.y) * deltaTime)
```

---

### 3. “Circle Dash” Shape Ability

| Property       | Type   | Default | Notes                                          |
|----------------|--------|---------|------------------------------------------------|
| `dashDistance` | Float  | 5.0     | Units moved during dash                         |
| `dashSpeed`    | Float  | 20.0    | Speed during dash                               |
| `dashCooldown` | Float  | 2.0     | Seconds between uses                            |
| `isDashing`    | Bool   | false   | Flag when dash is active                        |
| `lastDashTime` | Float  | –∞      | Timestamp of last dash                          |

#### 3.1. Input & Execution  
```pseudo
if keyPressed("Ability1") and (timeNow - lastDashTime >= dashCooldown)
    startDash()

procedure startDash():
    isDashing = true
    lastDashTime = timeNow
    dashInput = normalize(Vector2(inputX, inputY))
    dashTarget = hero.position + Vector3(dashInput.x, 0, dashInput.y) * dashDistance

// During Update:
if isDashing:
    hero.position = moveTowards(
        current = hero.position,
        target  = dashTarget,
        maxDelta= dashSpeed * deltaTime
    )
    if distance(hero.position, dashTarget) < 0.01:
        isDashing = false
```

---

### 4. Prototype Plan & Steps

1. **Create Hero Prefab**  
   - Add CharacterController or Rigidbody+Collider  
   - Attach `HeroMovement` script per section 2  
2. **Test Movement**  
   - Verify movement in all directions at `moveSpeed`  
3. **Implement Dash Ability**  
   - Add `CircleDash` component per section 3  
   - Wire up “Ability1” key (e.g., Space or E)  
4. **Playtest**  
   - Move & dash in sample scene; ensure cooldown enforced  
5. **Iterate**  
   - Tweak `moveSpeed`, `dashDistance`, `dashCooldown` for optimal feel  

---

### 5. AI-Friendly Component Spec (JSON)

```json
[
  {
    "id": "HeroMovement",
    "type": "Component",
    "properties": {
      "moveSpeed": 6.0
    },
    "methods": {
      "Update": "handleInputAndMove()"
    }
  },
  {
    "id": "CircleDash",
    "type": "Component",
    "properties": {
      "dashDistance": 5.0,
      "dashSpeed": 20.0,
      "dashCooldown": 2.0
    },
    "methods": {
      "Update": "handleDashState()",
      "startDash": "initializeDash()"
    }
  }
]
```

[TO-DO]  
- Decide on dash input key  
- Integrate dash SFX/VFX  
- Add animation state transitions (“Idle”, “Move”, “Dash”)
