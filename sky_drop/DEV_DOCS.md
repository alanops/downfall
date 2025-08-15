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
└── Ground (Landing collision)
```

### Physics System
- **Normal Fall Speed**: 600 px/s (~120 mph)
- **Parachute Fall Speed**: 150 px/s (~30 mph)
- **Gravity Normal**: 400 px/s²
- **Gravity Parachute**: 100 px/s²
- **Total Distance**: 27,000 pixels (45-second freefall)

### File Organization

#### Scripts (`/scripts/`)
- `GameManager.gd` - Core game loop, score tracking, scene transitions
- `Player.gd` - Player physics, input handling, camera control
- `HazardSpawner.gd` - Dynamic obstacle spawning system
- `ParallaxBackground.gd` - Background scrolling management
- `GameData.gd` - Singleton for persistent data between scenes
- `HUD.gd` - UI updates and display management
- `Ground.gd` - Landing detection and game completion
- `MainMenu.gd` - Menu navigation and game start
- `GameOver.gd` - End game display and restart options

#### Sprites (`/assets/sprites/`)
- `background_sky_gradient.webp` - Base blue gradient layer
- `clouds_sparse_middle_layer.webp` - Middle parallax cloud layer
- `clouds_dramatic_foreground.webp` - Foreground parallax clouds  
- `clouds_mixed_original.webp` - Menu background clouds
- `ui_button_play.webp` - Custom purple play button

#### Scenes (`/scenes/`)
- `Main.tscn` - Primary gameplay scene
- `MainMenu.tscn` - Start screen with custom UI
- `GameOver.tscn` - End screen with score display
- `Player.tscn` - Player character prefab
- `Plane.tscn` - Hazard obstacle prefab
- `Cloud.tscn` - Slow-down hazard prefab
- `PowerUp.tscn` - Collectible item prefab

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
- **Spawn Interval**: 1.2 - 3.5 seconds between obstacles
- **Spawn Range**: Throughout entire 26,800 pixel fall distance
- **Power-up Chance**: 15% chance for beneficial items
- **Player-Relative**: Hazards spawn 100-800 pixels ahead of player

### Difficulty Progression
- **Early Game**: Fewer obstacles, more time to react
- **Mid Game**: Increased density, strategic parachute timing crucial
- **End Game**: Higher obstacle frequency, precise control required

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
- Enable Godot debug prints for spawn system
- Monitor player position and camera coordinates  
- Verify hazard spawning within valid ranges
- Check collision detection accuracy

## Future Enhancements

### Potential Features
- **Sound System**: Chiptune Mission Impossible soundtrack
- **Multiple Characters**: Different skydiver types
- **Weather Effects**: Dynamic wind and weather conditions
- **Leaderboards**: Online score comparison
- **Mobile Controls**: Touch-based input system
- **Power-up Variety**: More collectible types and effects

### Technical Improvements  
- **Shader Effects**: Enhanced visual quality
- **Particle Systems**: Cloud and wind effects
- **Audio Integration**: Background music and sound effects
- **Save System**: Progress and high score persistence
- **Analytics**: Player behavior tracking

## Credits

**Game Design & Development**: Sky Drop Team
**Engine**: Godot 4.4.1
**Platform**: itch.io
**Repository**: GitHub
**Development Environment**: WSL2 Ubuntu + Windows backup

---

*This documentation is automatically updated with each major release. For the latest version, check the GitHub repository.*