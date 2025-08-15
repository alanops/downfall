#!/usr/bin/env gdscript
# Simple test validator that checks if test files are properly structured

extends SceneTree

func _ready():
	print("=== Sky Drop Test Validation ===")
	
	var test_files = [
		"res://tests/test_player.gd",
		"res://tests/test_game_manager.gd", 
		"res://tests/test_hazard.gd",
		"res://tests/test_powerup.gd"
	]
	
	var valid_tests = 0
	var total_tests = 0
	
	for test_file in test_files:
		print("\nValidating: " + test_file)
		if validate_test_file(test_file):
			valid_tests += 1
			print("✅ VALID")
		else:
			print("❌ INVALID")
		total_tests += 1
	
	print("\n=== Validation Summary ===")
	print("Valid tests: %d/%d" % [valid_tests, total_tests])
	
	if valid_tests == total_tests:
		print("🎉 All tests are properly structured!")
		print("\nTo run these tests:")
		print("1. Open project in Godot Editor")
		print("2. Install GUT plugin from AssetLib")
		print("3. Use GUT panel to run tests")
	else:
		print("⚠️  Some tests need fixing")
	
	quit()

func validate_test_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("  - File not found")
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var checks = [
		"extends GutTest",
		"func before_each",
		"func after_each", 
		"func test_"
	]
	
	var passed_checks = 0
	for check in checks:
		if content.contains(check):
			passed_checks += 1
			print("  ✓ Contains: " + check)
		else:
			print("  ✗ Missing: " + check)
	
	return passed_checks >= 3  # Allow some flexibility