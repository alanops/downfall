# Sky Drop - Godot Unit Tests

This directory contains unit tests for Sky Drop using the GUT (Godot Unit Test) framework.

## Setup

1. **Install GUT in your Godot project:**
   - Open your project in Godot
   - Go to AssetLib tab
   - Search for "Gut" 
   - Download and install the latest version
   - Enable the GUT plugin in Project Settings > Plugins

2. **Configure GUT:**
   - Go to Project > Tools > GUT
   - Set test directory to `res://tests/`
   - Configure other settings as needed

## Running Tests

### In Godot Editor:
1. Open the GUT panel (bottom dock or Project > Tools > GUT)
2. Click "Run All" to run all tests
3. Or select specific test files to run

### From Command Line:
```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd

# Run specific test file
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_player.gd

# Run with options
godot --headless -s addons/gut/gut_cmdln.gd -gexit -glog=2
```

## Test Structure

```
tests/
├── test_player.gd        # Player movement, physics, and controller tests
├── test_game_manager.gd  # Game state, scoring, and difficulty tests  
├── test_hazard.gd        # Hazard behavior and collision tests
├── test_powerup.gd       # Five power-up types and functionality tests
├── gut_config.gd         # GUT configuration
└── README.md            # This file
```

## Writing Tests

Basic test structure:
```gdscript
extends GutTest

func before_each():
    # Setup before each test
    pass

func after_each():
    # Cleanup after each test
    pass

func test_something():
    assert_eq(actual, expected, "Error message")
    assert_true(condition, "Error message")
    assert_false(condition, "Error message")
```

## Available Assertions

- `assert_eq(actual, expected)` - Equal
- `assert_ne(actual, expected)` - Not equal
- `assert_gt(actual, expected)` - Greater than
- `assert_lt(actual, expected)` - Less than
- `assert_true(condition)` - Is true
- `assert_false(condition)` - Is false
- `assert_null(value)` - Is null
- `assert_not_null(value)` - Is not null
- `assert_between(value, low, high)` - Value in range
- `assert_signal_emitted(obj, signal_name)` - Signal was emitted

## Best Practices

1. **Test Isolation**: Each test should be independent
2. **Clear Names**: Use descriptive test function names
3. **Single Assertion**: Test one thing per test function
4. **Mock Dependencies**: Use doubles/stubs for external dependencies
5. **Fast Tests**: Keep tests fast and focused

## Coverage Areas

Current test coverage includes:
- ✅ Player movement and physics (multi-input support)
- ✅ Game state management and difficulty modes
- ✅ Hazard spawning and behavior (planes and clouds)
- ✅ Five power-up types and effects (Shield, Magnet, Ghost, Speed Boost, Parachute Refill)
- ✅ Advanced scoring system with combo multipliers
- ✅ Collision detection and lives management
- ✅ Audio system integration (AudioManager)
- ✅ Controller input and vibration feedback
- ⬜ Parallax background (visual, hard to unit test)
- ⬜ Save/load system (if implemented)
- ⬜ Screen shake and visual effects

## CI Integration

To run tests in CI/CD:
```yaml
# Example GitHub Actions
- name: Run Godot Tests
  run: |
    godot --headless -s addons/gut/gut_cmdln.gd -gexit -gtest=res://tests/ -gjunit_xml_file=test_results.xml
```

## Debugging Tests

1. Use `print()` statements in tests
2. Set GUT log level to verbose (2)
3. Run specific failing tests in isolation
4. Use Godot debugger with breakpoints

## Performance Testing

For performance-critical code:
```gdscript
func test_performance():
    var start = OS.get_ticks_msec()
    # Run operation many times
    for i in range(1000):
        operation()
    var elapsed = OS.get_ticks_msec() - start
    assert_lt(elapsed, 100, "Operation too slow")
```