extends Area2D

enum HazardType { PLANE, CLOUD }

@export var hazard_type: HazardType = HazardType.PLANE
@export var move_speed: float = 150.0
@export var move_direction: int = 1  # 1 for right, -1 for left

var screen_width = 360

func update_sprite_direction():
	if hazard_type == HazardType.PLANE:
		var sprite = $Sprite2D
		var file_label = $FileLabel
		if sprite:
			var sprite_name = ""
			print("Setting sprite for move_direction: ", move_direction)
			# Randomly choose between plane_1 and plane_2
			var plane_variant = 1 if randf() < 0.5 else 2
			
			if move_direction < 0:  # Moving left
				if plane_variant == 1:
					sprite.texture = preload("res://assets/sprites/plane_1_left.webp")
					sprite_name = "plane_1_left"
				else:
					sprite.texture = preload("res://assets/sprites/plane_2_left.webp")
					sprite_name = "plane_2_left"
			else:  # Moving right
				if plane_variant == 1:
					sprite.texture = preload("res://assets/sprites/plane_1_right.webp")
					sprite_name = "plane_1_right"
				else:
					sprite.texture = preload("res://assets/sprites/plane_2_right.webp")
					sprite_name = "plane_2_right"
			
			# No flipping needed - using direction-specific sprites
			sprite.flip_h = false
			
			# Update label
			if file_label:
				file_label.text = sprite_name

func _ready():
	# Only planes go in hazards group (cause damage)
	if hazard_type == HazardType.PLANE:
		add_to_group("hazards")
		set_collision_layer_value(2, true)
		print("Plane created at position: ", position, " moving ", "right" if move_direction > 0 else "left", " (move_direction = ", move_direction, ")")
		
		# Set sprite after direction is determined
		update_sprite_direction()
			
	else:
		# Clouds go in their own group (slow player but don't damage)
		add_to_group("clouds")
		set_collision_layer_value(3, true)
		modulate.a = 0.7  # Make clouds semi-transparent
		print("Cloud created at position: ", position)

func _physics_process(delta):
	# Move horizontally
	position.x += move_speed * move_direction * delta
	
	# For planes: extend the off-screen boundaries so they don't disappear when player wanders off
	if hazard_type == HazardType.PLANE:
		# Much larger boundaries to account for player movement
		if position.x > screen_width + 800:  # Extended from 100 to 800
			if move_direction > 0:
				queue_free()
			else:
				position.x = screen_width + 800
		elif position.x < -800:  # Extended from -100 to -800
			if move_direction < 0:
				queue_free()
			else:
				position.x = -800
	else:
		# Clouds wrap around with extended boundaries
		if position.x > screen_width + 800:  # Extended from 200 to 800
			position.x = -800
		elif position.x < -800:  # Extended from -200 to -800
			position.x = screen_width + 800

func _on_body_entered(body):
	if body.has_method("take_damage") and hazard_type == HazardType.PLANE:
		body.take_damage()
	elif body.is_in_group("player") and hazard_type == HazardType.CLOUD:
		# Apply cloud effect
		if body.has_method("enter_cloud_effect"):
			body.enter_cloud_effect()

func _on_body_exited(body):
	if body.is_in_group("player") and hazard_type == HazardType.CLOUD:
		# Remove cloud effect
		if body.has_method("exit_cloud_effect"):
			body.exit_cloud_effect()
