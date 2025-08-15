extends GutTest

var Player = preload("res://scripts/Player.gd")
var player_instance

func before_each():
	player_instance = Player.new()
	player_instance.position = Vector2(180, 100)
	player_instance.velocity = Vector2.ZERO

func after_each():
	if player_instance:
		player_instance.queue_free()

func test_initial_state():
	assert_eq(player_instance.is_parachute_deployed, false, "Parachute should start closed")
	assert_eq(player_instance.position, Vector2(180, 100), "Player should be at initial position")
	assert_eq(player_instance.velocity, Vector2.ZERO, "Player should start with zero velocity")

func test_horizontal_movement():
	# Test move left
	player_instance._handle_input({"left": true, "right": false}, 0.1)
	assert_lt(player_instance.velocity.x, 0, "Player should move left")
	
	# Test move right
	player_instance._handle_input({"left": false, "right": true}, 0.1)
	assert_gt(player_instance.velocity.x, 0, "Player should move right")

func test_parachute_deployment():
	# Deploy parachute
	player_instance.is_parachute_deployed = true
	player_instance._apply_physics(0.1)
	
	# Verify terminal velocity is reduced
	assert_true(player_instance.velocity.y < 600, "Terminal velocity should be lower with parachute")

func test_boundary_constraints():
	# Test left boundary
	player_instance.position.x = -10
	player_instance._constrain_to_screen()
	assert_ge(player_instance.position.x, 0, "Player should not go past left boundary")
	
	# Test right boundary
	player_instance.position.x = 370
	player_instance._constrain_to_screen()
	assert_le(player_instance.position.x, 360, "Player should not go past right boundary")

func test_gravity_application():
	var initial_velocity = player_instance.velocity.y
	player_instance._apply_physics(0.1)
	assert_gt(player_instance.velocity.y, initial_velocity, "Gravity should increase downward velocity")

func test_reset_functionality():
	# Change player state
	player_instance.position = Vector2(250, 300)
	player_instance.velocity = Vector2(100, 200)
	player_instance.is_parachute_deployed = true
	
	# Reset
	player_instance.reset_player()
	
	# Verify reset
	assert_eq(player_instance.position, Vector2(180, 100), "Position should reset")
	assert_eq(player_instance.velocity, Vector2.ZERO, "Velocity should reset")
	assert_eq(player_instance.is_parachute_deployed, false, "Parachute should reset")