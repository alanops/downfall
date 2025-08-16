extends Area2D

enum HazardType { PLANE, CLOUD }

@export var hazard_type: HazardType = HazardType.PLANE
@export var move_speed: float = 150.0
@export var move_direction: int = 1  # 1 for right, -1 for left

var screen_width = 360

func _ready():
	# Only planes go in hazards group (cause damage)
	if hazard_type == HazardType.PLANE:
		add_to_group("hazards")
		set_collision_layer_value(2, true)
		print("Plane created at position: ", position, " moving ", "right" if move_direction > 0 else "left")
		
		# Randomly select between plane sprites
		var sprite = $Sprite2D
		if sprite:
			if randf() < 0.5:
				var plane2_texture = load("res://assets/sprites/plane_2.webp")
				if plane2_texture:
					sprite.texture = plane2_texture
			
			# Flip sprite based on movement direction
			# Sprites face right by default, so flip when moving left
			sprite.flip_h = move_direction < 0
			
			print("Plane _ready: move_direction = ", move_direction, ", flip_h = ", sprite.flip_h)
	else:
		# Clouds go in their own group (slow player but don't damage)
		add_to_group("clouds")
		set_collision_layer_value(3, true)
		modulate.a = 0.7  # Make clouds semi-transparent
		print("Cloud created at position: ", position)

func _physics_process(delta):
	# Update debug labels
	if hazard_type == HazardType.PLANE:
		var dir_label = $DirectionLabel
		var flip_label = $FlipLabel
		var sprite = $Sprite2D
		if dir_label:
			dir_label.text = "RIGHT" if move_direction > 0 else "LEFT"
		if flip_label and sprite:
			flip_label.text = "FLIP" if sprite.flip_h else "NORMAL"
	
	# Move horizontally
	position.x += move_speed * move_direction * delta
	
	# Wrap around screen or destroy if off-screen
	if hazard_type == HazardType.PLANE:
		if position.x > screen_width + 100:
			if move_direction > 0:
				queue_free()
			else:
				position.x = screen_width + 100
		elif position.x < -100:
			if move_direction < 0:
				queue_free()
			else:
				position.x = -100
	else:
		# Clouds wrap around
		if position.x > screen_width + 200:
			position.x = -200
		elif position.x < -200:
			position.x = screen_width + 200

func _on_body_entered(body):
	if body.has_method("take_damage") and hazard_type == HazardType.PLANE:
		body.take_damage()
	elif body.is_in_group("player") and hazard_type == HazardType.CLOUD:
		# Apply cloud effect (handled in player)
		pass
