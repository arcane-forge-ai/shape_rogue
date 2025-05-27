**Lightweight Concept Pitch (8-Hour MVP)**

---

## 1. Elevator Pitch  
A fast-paced, top-down arena brawler where two local players—each embodied as a simple geometric shape—survive escalating waves of minimalistic “geo-themed” enemies. One-button abilities, procedurally timed waves, and drop-in co-op make every 5–10-minute run a pure test of reflexes and teamwork.

---

## 2. Core Loop  
1. **Enter Arena** as any shape hero (circle, triangle, square, etc.)  
2. **Survive 5 Waves** of randomized enemies  
3. **Return to Shop Node** to heal and choose upgrades  
4. **Repeat** until defeat → Track best wave reached

---

## 3. Pillar Features  

### Shape Heroes & Abilities  
- **Any Shape**: Player picks from a roster of simple polygons  
- **One-Button Skill**:  
  - Circle → Dash (knock-back)  
  - Triangle → Cone-shot (pierce)  
  - Square → Area-bash (stun)  

### Geo-Themed Enemies  
1. **Spiky Star**  
   - Form: 8-pointed star  
   - Behavior: Slow drift, contact damage  
2. **Splitter Blob**  
   - Form: Pulsing circle  
   - Behavior: Splits into two smaller blobs on death  
3. **Line Shooter**  
   - Form: Straight line segment  
   - Behavior: Fires piercing laser periodically  
4. **Arc Drone**  
   - Form: Semi-circle hoverer  
   - Behavior: Circles edge, drops timed mines  

*Prototype 2–3 types for the 5-wave loop.*

---

## 4. AI-First 8-Hour Pipeline  

| Task      | Toolchain                                | Output                         |
|-----------|------------------------------------------|--------------------------------|
| **Code**  | Cursor + Claude 3.7 / ChatGPT o4-mini    | Movement, wave spawner, HUD    |
| **Art**   | SDXL                                     | Arena tiles only               |
| **Music** | Suno                                     | 1 looped background track      |
| **SFX**   | Audiocraft                              | Dash and hit sound effects     |

---

## 5. Tech & Platform  
- **Target**: PC/Web (HTML5 build via Unity or Phaser)  
- **Controls**: Keyboard & optional gamepad  
- **Networking**: Local drop-in co-op only  

---

### Next Steps  
- [ ] Wireframe HUD & shop node  
- [ ] Prototype hero movement + one skill  
- [ ] Prototype 2–3 enemy behaviors  
- [ ] Generate & import arena tile(s)  
- [ ] Playtest one full run (5 waves) and iterate  
