extends GutTest

var Hazard = preload("res://scripts/Hazard.gd")
var hazard

func before_each():
	hazard = Hazard.new()
	hazard.position = Vector2(180, -50)

func after_each():
	if hazard:
		hazard.queue_free()

func test_hazard_movement():
	var initial_y = hazard.position.y
	hazard.fall_speed = 200
	hazard._physics_process(0.1)
	
	assert_gt(hazard.position.y, initial_y, "Hazard should move downward")
	assert_almost_eq(hazard.position.y, initial_y + 20, 0.1, "Hazard should move at correct speed")

func test_hazard_types():
	# Test all hazard types exist and have correct properties
	var types = ["airplane", "bird", "helicopter", "missile", "debris"]
	
	for type in types:
		hazard.hazard_type = type
		hazard._ready()
		assert_gt(hazard.danger_level, 0, "Hazard type %s should have danger level" % type)

func test_hazard_offscreen_detection():
	# Position hazard on screen
	hazard.position.y = 300
	assert_false(hazard._is_offscreen(), "Hazard should not be offscreen at y=300")
	
	# Position hazard below screen
	hazard.position.y = 700
	assert_true(hazard._is_offscreen(), "Hazard should be offscreen at y=700")

func test_hazard_collision_area():
	# Verify hazard has collision shape
	hazard._ready()
	var collision_shape = hazard.get_node_or_null("CollisionShape2D")
	assert_not_null(collision_shape, "Hazard should have collision shape")

func test_hazard_speed_multiplier():
	hazard.fall_speed = 100
	hazard.speed_multiplier = 2.0
	
	var initial_y = hazard.position.y
	hazard._physics_process(0.1)
	
	var distance_moved = hazard.position.y - initial_y
	assert_almost_eq(distance_moved, 20, 0.1, "Hazard should respect speed multiplier")

func test_hazard_rotation():
	# Some hazards should rotate (like debris)
	hazard.hazard_type = "debris"
	hazard.should_rotate = true
	
	var initial_rotation = hazard.rotation
	hazard._physics_process(0.1)
	
	assert_ne(hazard.rotation, initial_rotation, "Debris should rotate")