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
	
	# Check player altitude - gradual easing below 180ft to show ground edge
	var player_altitude = target.current_altitude_feet if target.has_method("get") and "current_altitude_feet" in target else 0
	var altitude_threshold = 180.0
	var easing_range = 50.0  # Start easing 50ft before threshold
	
	# Calculate easing factor (1.0 = full follow, 0.0 = no follow)
	var follow_factor = 1.0
	if player_altitude < altitude_threshold:
		if player_altitude < (altitude_threshold - easing_range):
			follow_factor = 0.0  # Completely stop following
		else:
			# Smooth easing from 1.0 to 0.0 over the easing range
			var ease_progress = (altitude_threshold - player_altitude) / easing_range
			# Custom ease out function: 1 - (1 - x)^3
			var ease_value = ease_progress * ease_progress * (3.0 - 2.0 * ease_progress)
			follow_factor = 1.0 - ease_value
	
	# Always calculate target Y position
	var ideal_target_y = target.global_position.y - vertical_offset
	var target_y = lerp(global_position.y, ideal_target_y, follow_factor)
	
	# For horizontal, only follow if player moves beyond deadzone
	var target_x = global_position.x  # Start with current camera X
	var horizontal_distance = target.global_position.x - global_position.x
	
	if abs(horizontal_distance) > horizontal_deadzone:
		# Player is beyond deadzone, move camera to keep them in bounds
		if horizontal_distance > horizontal_deadzone:
			target_x = target.global_position.x - horizontal_deadzone
		elif horizontal_distance < -horizontal_deadzone:
			target_x = target.global_position.x + horizontal_deadzone
	
	# Use direct positioning for Y (no blur), smooth only for X
	global_position.y = target_y
	global_position.x = lerp(global_position.x, target_x, follow_speed * delta)
