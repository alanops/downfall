# Sky Drop - Test Suite

Comprehensive Playwright testing suite for the Sky Drop skydiving arcade game.

## Overview

This test suite provides automated end-to-end testing for Sky Drop across multiple browsers and devices, ensuring consistent gameplay experience and visual quality.

## Test Categories

### 🚀 Game Launch & Navigation (`game-launch.test.js`)
- Game loading and initialization
- Main menu display and functionality
- Canvas rendering and responsiveness
- Keyboard input handling
- Aspect ratio and layout validation

### 🎮 Gameplay Mechanics (`gameplay-mechanics.test.js`)
- Player movement controls (arrows, WASD)
- Parachute deployment system
- Game reset functionality
- Rapid input handling
- Extended gameplay session testing

### ⚡ Performance Testing (`performance.test.js`)
- Load time validation (<20 seconds)
- Memory usage monitoring
- Frame rate measurement (30+ FPS)
- Browser tab visibility handling
- Window resize responsiveness

### 🎨 Visual Regression (`visual-regression.test.js`)
- Screenshot comparison testing
- Multi-layer parallax validation
- Parachute deployment visuals
- Cross-viewport consistency
- Interactive visual feedback

### 🌐 Cross-Browser Compatibility (`cross-browser.test.js`)
- Chromium, Firefox, WebKit support
- WebGL capability verification
- Mobile touch event handling
- Input method consistency
- Viewport orientation testing

## Setup & Installation

### Prerequisites
- Node.js 18+
- npm or yarn

### Install Dependencies
```bash
cd tests
npm install
npx playwright install
```

### Run Tests

#### All Tests
```bash
npm test
```

#### Specific Browser
```bash
npm run test:chrome    # Chromium only
npm run test:firefox   # Firefox only
npm run test:webkit    # WebKit/Safari only
```

#### Mobile Testing
```bash
npm run test:mobile
```

#### Headed Mode (Visual)
```bash
npm run test:headed
```

#### Debug Mode
```bash
npm run test:debug
```

#### UI Mode (Interactive)
```bash
npm run test:ui
```

## Test Configuration

### Browser Support
- **Chromium**: Primary testing browser
- **Firefox**: Cross-browser compatibility
- **WebKit**: Safari compatibility
- **Mobile Chrome**: Touch/mobile testing
- **Mobile Safari**: iOS compatibility

### Test Environment
- **Target URL**: https://downfallgames.itch.io/downfall
- **Viewport**: Portrait orientation (360x640 preferred)
- **Timeout**: 15 seconds for game loading
- **Screenshots**: Taken on failures and for visual regression

### Performance Thresholds
- **Load Time**: < 20 seconds
- **Frame Rate**: > 30 FPS (target 60 FPS)
- **Memory Growth**: < 50MB during extended play
- **Responsiveness**: < 1.5 second response time

## CI/CD Integration

### GitHub Actions
Tests run automatically on:
- Push to main/develop branches
- Pull requests
- Daily scheduled runs (2 AM UTC)
- Manual workflow dispatch

### Test Matrix
- **Desktop**: Chromium, Firefox, WebKit
- **Mobile**: Chrome Mobile, Safari Mobile
- **Performance**: Dedicated performance testing
- **Visual**: Screenshot comparison testing

### Artifacts
- Test reports (30 days retention)
- Screenshots on failure (7 days retention)
- Performance metrics
- Visual diff comparisons

## Test Structure

```
tests/
├── e2e/                    # End-to-end test files
│   ├── game-launch.test.js
│   ├── gameplay-mechanics.test.js
│   ├── performance.test.js
│   ├── visual-regression.test.js
│   └── cross-browser.test.js
├── package.json            # Dependencies and scripts
├── playwright.config.js    # Test configuration
└── README.md              # This file
```

## Game-Specific Testing

### Sky Drop Mechanics Tested
- **Physics**: Realistic freefall and parachute physics
- **Controls**: Arrow keys, WASD, Space (parachute), R (reset)
- **Visuals**: Multi-layer parallax background system
- **Performance**: 60 FPS gameplay in browser
- **Compatibility**: HTML5 canvas across all browsers

### Test Scenarios
1. **Normal Gameplay**: Start → Move → Deploy parachute → Land
2. **Extended Play**: Long session testing (memory/performance)
3. **Rapid Input**: Stress testing with fast inputs
4. **Visual States**: Menu, gameplay, parachute deployment
5. **Error Recovery**: Reset functionality and state management

## Debugging Tests

### Common Issues
- **Loading Timeout**: Game may take longer on slow connections
- **Frame Detection**: itch.io iframe structure changes
- **Input Focus**: Canvas must be focused for keyboard events
- **Screenshot Variance**: Dynamic content causes visual test failures

### Debug Commands
```bash
# Run single test file
npx playwright test game-launch.test.js

# Run with browser visible
npx playwright test --headed

# Run specific test
npx playwright test -g "should load the game page successfully"

# Generate test with codegen
npx playwright codegen https://downfallgames.itch.io/downfall
```

### Trace Viewer
```bash
# View test traces
npx playwright show-trace trace.zip
```

## Contributing

### Adding New Tests
1. Create test file in `e2e/` directory
2. Follow existing naming convention
3. Use `test.describe()` for grouping
4. Include proper timeouts and waits
5. Add meaningful assertions

### Visual Testing Guidelines
- Use appropriate threshold values (0.2-0.4)
- Account for dynamic content
- Test multiple viewport sizes
- Include fallback assertions

### Performance Testing
- Monitor memory usage patterns
- Validate frame rates
- Test under various conditions
- Include browser-specific optimizations

## Reporting

### Test Reports
- HTML reports generated automatically
- JSON/JUnit formats for CI integration
- Screenshots attached to failed tests
- Performance metrics included

### View Reports
```bash
npm run report
```

Reports are also available as GitHub Actions artifacts.

## Maintenance

### Regular Updates
- Update Playwright version monthly
- Review and update screenshot baselines
- Monitor performance thresholds
- Check browser compatibility changes

### Test Health
- Monitor test flakiness
- Update selectors if game changes
- Adjust timeouts based on performance
- Review visual regression thresholds

---

**Game URL**: https://downfallgames.itch.io/downfall
**Test Environment**: Automated via GitHub Actions
**Coverage**: Cross-browser, mobile, performance, visual regression