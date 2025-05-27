# Circle Rouge

A fast-paced top-down arena brawler built with Flutter and Flame engine. Survive waves of geometric enemies while collecting coins to purchase upgrades!

## Game Features

### Core Gameplay
- **Hero Movement**: WASD or arrow keys for smooth 8-directional movement
- **Dash Ability**: Space or E key for quick evasive maneuvers (costs energy)
- **Auto-Shooting**: Hero automatically shoots at the nearest enemy within range
- **Time-Based Waves**: Survive for 30 seconds per wave with increasing enemy spawn rates
- **Progressive Difficulty**: 5 waves with different enemy types and spawn patterns

### Enemy Types
- **Chasers** (Red): Fast-moving enemies that pursue the player directly
- **Shooters** (Purple): Ranged enemies that maintain distance and fire projectiles

### Upgrade Shop
Between waves, spend coins on powerful upgrades:
- **Health Potion** (30 coins): Restore 50 HP instantly
- **Energy Boost** (25 coins): Restore full energy
- **Max Health Up** (50 coins): Permanently increase maximum health by 25
- **Attack Speed Up** (60 coins): Increase firing rate by 25%
- **Speed Boost** (40 coins): Temporary movement speed increase

### Enhanced UI
- **Health Bar**: Visual bar with numerical display (100/100)
- **Energy Bar**: Visual bar with numerical display for dash ability
- **Dash Cooldown**: Visual indicator showing when dash is ready
- **Wave Timer**: Countdown showing remaining time in current wave
- **Coin Counter**: Track your earnings for shop purchases
- **Safe Area System**: Enemies are constrained to stay within the visible arena

## Controls

- **Movement**: WASD or Arrow Keys
- **Dash**: Space or E (costs 25 energy, 2-second cooldown)
- **Shooting**: Automatic (targets nearest enemy within range)
- **Menu Navigation**: Click buttons to start game, purchase items, etc.

## Game Progression

### Wave System
Each wave lasts 30 seconds with enemies spawning every 2 seconds initially, increasing to every 0.5 seconds by wave end:

1. **Wave 1**: Chasers only - Learn basic movement and combat
2. **Wave 2**: Shooters only - Practice dodging projectiles  
3. **Wave 3+**: Mixed enemy types - Full challenge mode

### Strategy Tips
- Use dash to escape when surrounded by enemies
- Prioritize shooters as they can attack from range
- Manage energy carefully - you need it for dashing
- Invest in attack speed upgrades for faster enemy clearing
- Health upgrades provide both immediate healing and permanent benefits

## Technical Details

- **Engine**: Flutter 3.24.3 + Flame 1.18.0
- **Platform**: Windows (with potential for cross-platform deployment)
- **Resolution**: 1600x1200 game area (doubled from original for better visibility)
- **Performance**: 60 FPS target with optimized collision detection

## Installation & Running

1. Ensure Flutter SDK is installed and configured
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Launch with `flutter run` for development or `flutter build windows` for release

## Development Notes

This game was built as an 8-hour MVP following a structured design document approach. The codebase emphasizes:
- Clean component architecture using Flame's ECS system
- Responsive UI scaling for different screen sizes
- Modular enemy AI systems for easy expansion
- Comprehensive game state management
- Performance-optimized collision detection and rendering

The doubled scale system ensures all game elements are clearly visible while maintaining the original gameplay balance and feel.
