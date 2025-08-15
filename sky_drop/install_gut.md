# Installing GUT Testing Framework

To use the unit tests in the `tests/` directory, you need to install GUT (Godot Unit Test) framework:

## Method 1: Via Godot AssetLib (Recommended)

1. Open your Sky Drop project in Godot
2. Click on the "AssetLib" tab (next to 2D, 3D, Script tabs)
3. Search for "Gut" in the search bar
4. Find "GUT - Godot Unit Testing" by bitwes
5. Click "Download"
6. Click "Install..." 
7. Leave all files checked and click "Install"
8. Once installed, go to Project > Project Settings > Plugins
9. Find "Gut" in the list and check the "Enable" checkbox

## Method 2: Manual Installation

1. Download GUT from: https://github.com/bitwes/Gut/releases
2. Extract the `addons/gut` folder to your project's `addons/` directory
3. Enable the plugin in Project Settings > Plugins

## Verify Installation

1. You should see a GUT button in the bottom panel (where Output, Debugger, etc. are)
2. Or access via Project > Tools > GUT
3. Click on GUT panel and try running the tests

## Running Tests

Once GUT is installed:
1. Open the GUT panel
2. It should automatically find tests in `res://tests/`
3. Click "Run All" to execute all tests

The test files created are:
- `test_player.gd` - Tests player movement, physics, and controls
- `test_game_manager.gd` - Tests game state, scoring, and progression
- `test_hazard.gd` - Tests hazard spawning and movement
- `test_powerup.gd` - Tests powerup behavior and effects

These tests are much more appropriate for a Godot game than browser-based Playwright tests!