# Sky Drop - Developer Documentation

## Project Overview

Sky Drop is a vertical scrolling arcade game built in Godot 4.4.1 where players control a skydiver falling from 13,500 feet. The goal is to navigate through hazards while strategically deploying a parachute to control descent speed and reach the ground safely.

## Game Mechanics

### Core Gameplay
- **Vertical Falling**: Player falls at realistic physics speeds
- **Horizontal Movement**: Left/right control with arrow keys or WASD
- **Parachute System**: Space bar toggles parachute for speed control
- **Lives System**: 3 lives, lose one when hitting planes
- **Power-ups**: Collectible items for score/life bonuses
- **Realistic Physics**: 45-60 second freefall matching real skydiving

### Controls
- **Arrow Keys / WASD**: Move left and right
- **Space**: Deploy/retract parachute
- **R**: Reset game at any time
- **Down/S**: Fast dive mode (increased fall speed)
- **Up/W**: Normal speed when diving
- **`` ` `` (backtick) / F1**: Toggle developer console
- **Touch Controls**: Tap, swipe, and drag gestures for mobile support

## Technical Architecture

### Scene Structure
```
Main.tscn (Root Scene)
├── GameManager (Game state management)
├── ParallaxBackground (Multi-layer scrolling system)
│   ├── BackgroundLayer (Blue gradient - 0.2x speed)
│   ├── FarCloudsLayer (Sparse clouds - 0.4x speed)
│   └── NearCloudsLayer (Dramatic clouds - 0.6x speed)
├── GameCamera (Vertical-only following camera)
├── Player (CharacterBody2D with physics)
├── HazardSpawner (Dynamic obstacle generation)
├── GroundDetector (Win condition trigger)
├── Ground (Landing collision)
├── HUD (UI display and status indicators)
└── DevConsole (Developer testing and debugging tools)
```

### Physics System
- **Normal Fall Speed**: 600 px/s (~120 mph)
- **Fast Dive Speed**: 1000 px/s (~200 mph)
- **Parachute Fall Speed**: 150 px/s (~30 mph)
- **Speed Boost Mode**: 1400 px/s (~280 mph, temporary)
- **Gravity Normal**: 400 px/s²
- **Gravity Fast Dive**: 800 px/s²
- **Gravity Parachute**: 100 px/s²
- **Total Distance**: 27,000 pixels (45-second freefall)
- **Wind Effects**: Simulated atmospheric conditions when parachute deployed
- **Parachute Jerk**: 150 unit upward impulse on deployment

### File Organization

#### Scripts (`/scripts/`)
- `GameManager.gd` - Core game loop, score tracking, scene transitions
- `Player.gd` - Player physics, input handling, camera control, touch controls
- `HazardSpawner.gd` - Dynamic obstacle spawning system with multiple spawn types
- `ParallaxBackground.gd` - Background scrolling management
- `GameData.gd` - Singleton for persistent data between scenes
- `HUD.gd` - UI updates and display management with null-safe references
- `Ground.gd` - Landing detection and game completion
- `MainMenu.gd` - Menu navigation and game start
- `GameOver.gd` - End game display and restart options
- `DevConsole.gd` - Developer console with commands and sound menu
- `PowerUp.gd` - Power-up system with multiple types (parachute, speed boost)

#### Sprites (`/assets/sprites/`)
- `background_sky_gradient.webp` - Base blue gradient layer
- `clouds_sparse_middle_layer.webp` - Middle parallax cloud layer
- `clouds_dramatic_foreground.webp` - Foreground parallax clouds  
- `clouds_mixed_original.webp` - Menu background clouds
- `skydiver.webp` - Player character sprite
- `parachute.webp` - Parachute deployment sprite
- `play_button.webp` - Main menu play button
- `menu_button.webp` - General menu button style

#### Scenes (`/scenes/`)
- `Main.tscn` - Primary gameplay scene with integrated dev console
- `MainMenu.tscn` - Start screen with custom UI and sprite buttons
- `GameOver.tscn` - End screen with score display
- `DevConsole.tscn` - Developer console with sound menu interface
- `Plane.tscn` - Hazard obstacle prefab
- `Cloud.tscn` - Slow-down hazard prefab
- `PowerUp.tscn` - Collectible item prefab with multiple types

## Visual Design

### Multi-Layer Parallax System
The game uses a sophisticated 3-layer parallax system for depth perception:

1. **Background Layer (0.2x speed)**
   - Clean blue gradient base
   - Slowest movement for distant sky effect
   
2. **Far Clouds Layer (0.4x speed)**  
   - Sparse, light clouds on transparent background
   - Medium movement speed for middle depth
   
3. **Near Clouds Layer (0.6x speed)**
   - Large, dramatic clouds on transparent background
   - Fastest movement for foreground depth

### Camera System
- **Vertical Following**: Camera tracks player's Y position during fall
- **Horizontal Lock**: Camera stays centered at X=180 to prevent edge visibility
- **Smooth Tracking**: Seamless vertical movement without jarring
- **Edge Prevention**: No grey areas or texture boundaries visible

## Game Balance

### Hazard Spawning
- **Spawn Interval**: 0.3 - 1.2 seconds between obstacles (increased frequency)
- **Multiple Spawns**: 1-3 obstacles per spawn event for higher density
- **Spawn Range**: Throughout entire 27,000 pixel fall distance
- **Plane Frequency**: 70% chance for plane hazards
- **Power-up Types**: Parachute refills and speed boost power-ups
- **Player-Relative**: Hazards spawn 100-800 pixels ahead of player
- **Higher Starting Position**: Player starts at y=-200 for better visibility

### Difficulty Progression
- **Early Game**: Fewer obstacles, more time to react
- **Mid Game**: Increased density, strategic parachute timing crucial
- **End Game**: Higher obstacle frequency, precise control required

### Safety Mechanics
- **Parachute Landing**: Must deploy parachute to land safely
- **Screen Boundaries**: Player cannot move off-screen edges
- **Godmode Support**: Invincibility mode available via dev console

## Developer Tools

### Developer Console
The integrated dev console provides comprehensive testing and debugging capabilities:

#### Activation
- **Primary Key**: `` ` `` (backtick) - Opens/closes console
- **Alternative**: `F1` key for systems where backtick doesn't work
- **Sound Menu**: `Shift+Enter` when console is open

#### Core Commands
```bash
# Game State Management
godmode                    # Toggle invincibility
lives <number>            # Set player lives (e.g., lives 5)
score <number>            # Set current score
time <seconds>            # Set game time
reset                     # Reset game to start

# Player Control
teleport <x> <y>          # Move player to coordinates
speed <multiplier>        # Adjust movement speed (e.g., speed 2.0)
gravity <multiplier>      # Adjust gravity strength (e.g., gravity 0.5)
parachute <true/false>    # Force parachute state

# Environment Control
wind <x> <y>             # Set custom wind forces
wind clear               # Remove wind override

# Object Spawning
spawn plane              # Spawn plane hazard
spawn cloud              # Spawn cloud
spawn powerup            # Spawn power-up

# Debug Information
fps                      # Show performance statistics
help                     # Display all available commands
clear                    # Clear console output
```

#### Sound Menu
Integrated volume controls for audio system preparation:
- **Master Volume**: Overall game volume control
- **Music Volume**: Background music level
- **SFX Volume**: Sound effects level
- **Test Buttons**: Audio system testing capabilities

#### Console Features
- **Game Pause**: Automatically pauses game when console is open
- **Command History**: Navigate previous commands with arrow keys
- **Real-time Updates**: Changes apply immediately to running game
- **Null-safe**: Error handling prevents crashes from missing nodes

## Development Workflow

### Version Control
- **Repository**: GitHub at `alanops/downfall`
- **Branch**: `main` for all development
- **Commits**: Descriptive messages without Claude references
- **Auto-deployment**: GitHub Actions to itch.io on push

### Build Pipeline
```yaml
Workflow: publish-to-itch.yml
Trigger: Push to main branch
Steps:
1. Checkout repository
2. Setup Godot 4.4.1 (non-C# version)
3. Configure export templates
4. Export to HTML5
5. Upload to itch.io via Butler
6. Archive build artifacts
```

### Local Development
- **Primary**: WSL2 Ubuntu environment
- **Backup**: Windows copy at `C:\Users\alan\Desktop\sky_drop\`
- **Sync Rule**: Always copy to Windows after changes
- **Testing**: Local Godot 4.4.1 for development testing

## Performance Considerations

### Optimization Strategies
- **Parallax Efficiency**: 1024px mirroring prevents memory bloat
- **Dynamic Spawning**: Objects created/destroyed as needed
- **Texture Compression**: WebP format for optimal web delivery
- **Scene Management**: Single main scene reduces loading

### Browser Compatibility
- **Target Platform**: HTML5 web browsers
- **Resolution**: 360x640 portrait orientation
- **Performance**: Optimized for 60fps on modern browsers
- **Controls**: Keyboard input with mobile-friendly design

## Deployment

### itch.io Configuration
- **Page URL**: https://downfallgames.itch.io/downfall
- **Type**: HTML5 browser game
- **Embed Size**: 360x640 pixels
- **Auto-upload**: GitHub Actions with Butler tool

### Release Process
1. Develop and test locally
2. Commit changes to main branch
3. GitHub Action automatically builds and deploys
4. Copy updated project to Windows backup
5. Verify deployment on itch.io

## Troubleshooting

### Common Issues

**Camera Edge Visibility**
- Solution: Camera locked horizontally at X=180
- Prevention: Vertical-only following system

**Parallax Gaps**
- Solution: 1024px mirroring matches texture height  
- Prevention: Proper texture dimensions

**Physics Inconsistency**
- Solution: Fixed delta-time calculations
- Prevention: Consistent gravity and velocity limits

**Spawn System Failures**
- Solution: Player-relative positioning system
- Prevention: Bounds checking and validation

### Debug Information
- **Developer Console**: Use `fps` command for real-time performance data
- **Debug Prints**: Enable Godot debug prints for spawn system
- **Position Monitoring**: Use `teleport` command to test specific coordinates  
- **Spawn Testing**: Use `spawn` commands to verify obstacle generation
- **Physics Testing**: Use `speed` and `gravity` commands for parameter tuning
- **Console Logging**: All debug output visible in dev console

## Future Enhancements

### Potential Features
- **Audio System**: Background music and sound effects (framework ready)
- **Multiple Characters**: Different skydiver types with unique abilities
- **Weather Effects**: Dynamic wind and weather conditions
- **Leaderboards**: Online score comparison system
- **Enhanced Mobile**: Additional touch gesture support
- **Power-up Expansion**: More collectible types and visual effects
- **Visual Polish**: Particle systems and shader effects

### Technical Improvements  
- **Audio Implementation**: Use existing volume control framework
- **Shader Effects**: Enhanced visual quality and atmospheric effects
- **Particle Systems**: Cloud, wind, and collision effects
- **Save System**: Progress and high score persistence
- **Analytics**: Player behavior tracking and telemetry
- **Performance Optimization**: Further mobile device optimization
- **Testing Automation**: Expanded unit testing with GUT framework

## Credits

**Game Design & Development**: Sky Drop Team
**Engine**: Godot 4.4.1
**Platform**: itch.io
**Repository**: GitHub
**Development Environment**: WSL2 Ubuntu + Windows backup

---

*This documentation is automatically updated with each major release. For the latest version, check the GitHub repository.*