# Downfall 🪂

**Professional Vertical-Scrolling Skydiving Arcade Game**  
Built in Godot 4.4.1 with modern development practices.

[![Play Now](https://img.shields.io/badge/Play%20Now-itch.io-FF6B6B?style=for-the-badge&logo=itch.io)](https://downfallgames.itch.io/downfall)
[![Version](https://img.shields.io/badge/Version-1.0.0-4CAF50?style=for-the-badge)](./sky_drop/VERSION)
[![Engine](https://img.shields.io/badge/Engine-Godot%204.4.1-478CBF?style=for-the-badge&logo=godot-engine)](https://godotengine.org/)

---

## 🎮 Game Overview

Downfall is a complete, professional-quality arcade game where players control a skydiver falling from 13,500 feet. Navigate through dynamic obstacles, collect coins with combo multipliers, and strategically deploy your parachute to reach the ground safely. Features realistic physics, multiple difficulty modes, and comprehensive audio design.

**Key Features:**
- **Realistic Physics**: 45-second freefall with accurate terminal velocities
- **Strategic Gameplay**: Risk/reward parachute deployment mechanics
- **Rich Audio**: Professional AudioManager with contextual sound effects
- **Controller Support**: Full gamepad integration with haptic feedback
- **Multiple Difficulty Modes**: Easy (12 lives), Normal (3 lives), Hard (1 life)
- **Advanced Scoring**: Coin collection with 5x combo multipliers
- **Five Power-ups**: Shield, Magnet, Ghost Mode, Speed Boost, Parachute Refill

---

## 🚀 Quick Start

### Play Online
**[🎮 Play Downfall on itch.io](https://downfallgames.itch.io/downfall)**

### Local Development
```bash
# Clone the repository
git clone https://github.com/alanops/downfall.git
cd downfall/sky_drop

# Open in Godot 4.4.1+
godot project.godot

# Or run directly
godot --main-pack project.godot
```

---

## 🎯 Complete Feature Set

### Core Gameplay
- ✅ **Realistic Skydiving Physics** - 600px/s terminal velocity, 45-second freefall
- ✅ **Strategic Parachute System** - Deploy at 150px/s for controlled descent
- ✅ **Dynamic Obstacle System** - Planes and clouds with intelligent spawning
- ✅ **Coin Collection** - Risk/reward positioned near hazards with combo system
- ✅ **Five Power-up Types** - Each with unique mechanics and visual feedback
- ✅ **Difficulty Progression** - Three modes affecting lives and spawn rates

### Technical Excellence
- ✅ **Multi-Input Support** - Keyboard, controller, and touch controls
- ✅ **Professional Audio System** - AudioManager with sound pooling and bus management
- ✅ **Advanced Developer Tools** - 42-command console for debugging and testing
- ✅ **Comprehensive Testing** - 25+ unit tests with GUT framework
- ✅ **CI/CD Pipeline** - Automated deployment to itch.io via GitHub Actions
- ✅ **Performance Optimized** - Stable 60fps on web browsers

### Visual & Audio Design
- ✅ **Multi-layer Parallax** - Professional 3-depth background system
- ✅ **Screen Effects** - Dynamic screen shake and visual feedback
- ✅ **Contextual Audio** - 11 integrated sound effects with spatial awareness
- ✅ **Controller Haptics** - Vibration feedback for impacts and actions
- ✅ **Responsive UI** - Dynamic prompts based on input method

---

## 🛠 Development Team

- **Technical Lead**: Advanced Godot development, systems architecture, CI/CD
- **Game Design**: Physics simulation, game balance, user experience
- **Audio Integration**: Professional audio system with spatial sound design

---

## 📂 Project Structure

```
downfall/
├── sky_drop/                    # Main Godot project
│   ├── scripts/                # 20+ game scripts
│   │   ├── AudioManager.gd     # Professional audio system
│   │   ├── ControllerManager.gd # Full gamepad support
│   │   ├── Player.gd           # Advanced physics and input
│   │   └── DevConsole.gd       # 42-command debug console
│   ├── scenes/                 # 10 scene files
│   ├── assets/                 # Organized sprites and audio
│   │   ├── sprites/           # 30+ high-quality WebP images
│   │   └── sounds/            # 11 professional audio assets
│   ├── tests/                  # Comprehensive test suite
│   ├── PROJECT_SUMMARY.md      # High-level overview
│   ├── DEV_DOCS.md            # Technical documentation
│   └── README_CONTROLLER_SUPPORT.md # Controller guide
└── README.md                   # This file
```

---

## 🧪 Testing & Quality

### Professional Testing Framework
- **25+ Unit Tests** across 4 test categories
- **GUT Integration** for native Godot testing
- **Automated CI** with GitHub Actions
- **Performance Benchmarks** for 60fps stability

### Test Coverage
- ✅ Player physics and multi-input handling
- ✅ Game mechanics and difficulty scaling  
- ✅ Audio system and controller integration
- ✅ Power-up effects and collision detection
- ✅ Scoring system and combo mechanics

---

## 🚢 Deployment

### Live Deployment
- **Production**: [downfallgames.itch.io/downfall](https://downfallgames.itch.io/downfall)
- **Auto-Deploy**: GitHub Actions → itch.io via Butler
- **Platform**: HTML5 with 360x640 portrait mode
- **Performance**: 60fps stable on modern browsers

### Development Pipeline
```bash
# Development workflow
git checkout -b feature/new-feature
# ... make changes ...
git push origin feature/new-feature
gh pr create --title "Feature description"
# → Automatic deployment on merge to main
```

---

## 📖 Documentation

### For Players
- **[Controller Support Guide](./sky_drop/README_CONTROLLER_SUPPORT.md)** - Complete gamepad setup
- **In-Game Help** - Developer console with `help` command

### For Developers  
- **[Technical Documentation](./sky_drop/DEV_DOCS.md)** - Architecture and systems
- **[Test Framework Guide](./sky_drop/TEST_REPORT.md)** - Testing setup and coverage
- **[Audio Implementation](./sky_drop/SOUNDS_NEEDED.md)** - AudioManager details

---

## 🏆 Project Achievements

Downfall represents a **complete, professional-quality game project** featuring:

1. **Production-Ready Code** - Clean architecture, error handling, performance optimization
2. **Modern Development Practices** - Version control, testing, CI/CD, comprehensive documentation  
3. **Accessibility Features** - Multiple input methods, difficulty options, visual/audio feedback
4. **Professional Audio** - Spatial sound design with dynamic contextual playback
5. **Comprehensive Testing** - Unit tests, performance benchmarks, automated validation
6. **Cross-Platform Support** - Web deployment with mobile-friendly controls

---

## 📄 License

This project is developed for educational and portfolio purposes. All code is available under standard repository licensing.

**Third-Party Assets:**
- Engine: [Godot Engine](https://godotengine.org/) (MIT License)
- Testing: [GUT Framework](https://github.com/bitwes/Gut) (MIT License)
- Audio: Original compositions and royalty-free sources

---

**[🎮 Play Downfall Now](https://downfallgames.itch.io/downfall)**

