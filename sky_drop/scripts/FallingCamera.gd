extends Camera2D

@export var target: Node2D  # The player to follow
@export var vertical_offset: float = -150.0  # Player appears this many pixels above center (negative = player higher)
@export var follow_speed: float = 10.0  # How quickly camera follows player
@export var horizontal_deadzone: float = 50.0  # Player can move this far before camera follows horizontally

var target_position: Vector2

func _ready():
	if not target:
		target = get_node_or_null("../Player")
	
	if target:
		# Start camera at player position with offset
		global_position = Vector2(target.global_position.x, target.global_position.y - vertical_offset)

func _process(delta):
	if not target:
		return
	
	# Always follow player's Y position (falling) with offset
	var target_y = target.global_position.y - vertical_offset
	
	# For horizontal, only follow if player moves beyond deadzone
	var target_x = global_position.x  # Start with current camera X
	var horizontal_distance = target.global_position.x - global_position.x
	
	if abs(horizontal_distance) > horizontal_deadzone:
		# Player is beyond deadzone, move camera to keep them in bounds
		if horizontal_distance > horizontal_deadzone:
			target_x = target.global_position.x - horizontal_deadzone
		elif horizontal_distance < -horizontal_deadzone:
			target_x = target.global_position.x + horizontal_deadzone
	
	target_position = Vector2(target_x, target_y)
	
	# Smoothly move camera to target position
	global_position = global_position.lerp(target_position, follow_speed * delta)