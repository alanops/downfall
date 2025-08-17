extends GutTest

var PowerUp = preload("res://scripts/PowerUp.gd")
var powerup

func before_each():
	powerup = PowerUp.new()
	powerup.position = Vector2(180, -50)

func after_each():
	if powerup:
		powerup.queue_free()

func test_powerup_types():
	var types = ["shield", "slow_time", "magnet", "extra_life"]
	
	for type in types:
		powerup.powerup_type = type
		powerup._ready()
		assert_has(types, powerup.powerup_type, "Powerup type should be valid")

func test_powerup_movement():
	var initial_y = powerup.position.y
	powerup.fall_speed = 150
	powerup._physics_process(0.1)
	
	assert_gt(powerup.position.y, initial_y, "Powerup should fall downward")
	assert_almost_eq(powerup.position.y, initial_y + 15, 0.1, "Powerup should fall at correct speed")

func test_powerup_float_animation():
	# Powerups should have a floating animation
	powerup.float_amplitude = 10
	powerup.float_frequency = 2.0
	
	var initial_x = powerup.position.x
	powerup._physics_process(0.5)
	
	# X position should oscillate
	assert_ne(powerup.position.x, initial_x, "Powerup should float horizontally")

func test_powerup_duration():
	# Test different powerup durations
	powerup.powerup_type = "shield"
	assert_eq(powerup.get_duration(), 5.0, "Shield should last 5 seconds")
	
	powerup.powerup_type = "slow_time"
	assert_eq(powerup.get_duration(), 3.0, "Slow time should last 3 seconds")

func test_powerup_visual_effects():
	powerup._ready()
	
	# Check for particle effects or glow
	var particles = powerup.get_node_or_null("CPUParticles2D")
	if particles:
		assert_true(particles.emitting, "Powerup particles should be emitting")

func test_powerup_collection_signal():
	# Test that powerup emits signal when collected
	watch_signals(powerup)
	powerup.collect()
	
	assert_signal_emitted(powerup, "collected", "Powerup should emit collected signal")
