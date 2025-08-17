extends ParallaxBackground

@export var scroll_speed: float = 100.0
var wind_time: float = 0.0
var wind_direction: int = 1  # 1 for right, -1 for left
var wind_change_timer: float = 0.0
var wind_change_interval: float = 8.0  # Change wind direction every 8 seconds

func _process(delta):
	# Scroll the background based on player falling speed
	var player = get_node_or_null("/root/Main/Player")
	if player:
		var fall_speed = player.velocity.y
		scroll_offset.y += fall_speed * delta * 0.5  # Half speed for parallax effect
	
	# Animate cloud wind movement
	wind_time += delta
	wind_change_timer += delta
	
	# Change wind direction periodically
	if wind_change_timer >= wind_change_interval:
		wind_direction *= -1  # Reverse direction
		wind_change_timer = 0.0
		wind_change_interval = randf_range(6.0, 12.0)  # Random interval between changes
	
	# Apply wind movement to cloud layers
	animate_cloud_wind(delta)

func animate_cloud_wind(delta):
	# Get all cloud layers
	var far_clouds = get_node_or_null("FarCloudsLayer")
	var mid_clouds = get_node_or_null("MidCloudsLayer")
	var near_clouds = get_node_or_null("NearCloudsLayer") 
	var fg_clouds = get_node_or_null("ForegroundCloudsLayer")
	
	# Wind strength varies by layer (closer = more affected)
	var base_wind_speed = 15.0
	var wind_variation = sin(wind_time * 0.5) * 5.0  # Gentle variation in wind strength
	
	if far_clouds:
		animate_layer_clouds(far_clouds, (base_wind_speed + wind_variation) * 0.3 * wind_direction, delta)
	if mid_clouds:
		animate_layer_clouds(mid_clouds, (base_wind_speed + wind_variation) * 0.5 * wind_direction, delta)
	if near_clouds:
		animate_layer_clouds(near_clouds, (base_wind_speed + wind_variation) * 0.7 * wind_direction, delta)
	if fg_clouds:
		animate_layer_clouds(fg_clouds, (base_wind_speed + wind_variation) * 1.0 * wind_direction, delta)

func animate_layer_clouds(layer: ParallaxLayer, wind_speed: float, delta: float):
	# Move all cloud sprites in the layer
	for child in layer.get_children():
		if child is Sprite2D:
			child.position.x += wind_speed * delta
			
			# Wrap clouds around when they go off-screen (with extended boundaries)
			var wrap_left = -1200
			var wrap_right = 1560  # 360 + 1200
			
			if child.position.x > wrap_right:
				child.position.x = wrap_left
			elif child.position.x < wrap_left:
				child.position.x = wrap_right