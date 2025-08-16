extends CharacterBody2D

const SPEED = 200.0
const ACCELERATION = 800.0
const FRICTION = 600.0
const AIR_RESISTANCE = 50.0
const GRAVITY_NORMAL = 400.0
const GRAVITY_PARACHUTE = 100.0
const GRAVITY_FAST_DIVE = 800.0
const GRAVITY_SPEED_BOOST = 1200.0
const MAX_FALL_SPEED = 600.0
const MAX_FALL_SPEED_PARACHUTE = 150.0
const MAX_FALL_SPEED_FAST_DIVE = 1000.0
const MAX_FALL_SPEED_SPEED_BOOST = 1400.0
const PARACHUTE_DRAG = 0.95
const WIND_STRENGTH = 30.0
const SPEED_BOOST_DURATION = 5.0

var parachute_deployed = false
var lives = 3
var parachutes_available = 1
var can_deploy_parachute = true
var game_finished = false
var wind_time = 0.0
var deployment_transition_time = 0.0
var is_transitioning = false
var is_fast_diving = false
var speed_boost_time = 0.0
var has_speed_boost = false

# New power-up variables
var shield_time = 0.0
var has_shield = false
var magnet_time = 0.0
var has_magnet = false
var ghost_time = 0.0
var has_ghost = false
var magnet_range = 100.0
const SHIELD_DURATION = 8.0
const MAGNET_DURATION = 10.0
const GHOST_DURATION = 5.0

# Cloud effect variables
var in_cloud = false
var cloud_drag_multiplier = 0.5  # More noticeable slowdown

# Altitude tracking
const STARTING_ALTITUDE_FEET = 13500  # Realistic skydiving altitude
const GROUND_Y_POSITION = 27000
const STARTING_Y_POSITION = -200
const TOTAL_FALL_DISTANCE = GROUND_Y_POSITION - STARTING_Y_POSITION  # 27200 units
var current_altitude_feet = STARTING_ALTITUDE_FEET

# Dev console variables
var godmode_enabled = false
var speed_multiplier = 1.0
var gravity_multiplier = 1.0
var wind_override = Vector2.ZERO
var has_wind_override = false

# Touch controls
var touch_start_pos = Vector2.ZERO
var is_touching = false
var swipe_threshold = 50.0
var tap_threshold = 0.3
var touch_start_time = 0.0

signal lives_changed(new_lives)
signal parachute_toggled(deployed)
signal hit_hazard()
signal altitude_changed(altitude_feet)

var screen_shake: Node
var particle_manager: Node2D

func _ready():
	add_to_group("player")
	# Get reference to screen shake and particle manager
	screen_shake = get_node_or_null("../ScreenShake")
	particle_manager = get_node_or_null("../ParticleManager")
	# Ensure we start with 3 lives and emit signal for UI update
	lives = 3
	emit_signal("lives_changed", lives)

func _input(event):
	# Handle touch/swipe controls
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started
			touch_start_pos = event.position
			is_touching = true
			touch_start_time = Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60
		else:
			# Touch ended
			if is_touching:
				var touch_end_pos = event.position
				var swipe_vector = touch_end_pos - touch_start_pos
				var touch_duration = (Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60) - touch_start_time
				
				# Check for tap (short touch with minimal movement)
				if touch_duration < tap_threshold and swipe_vector.length() < swipe_threshold:
					# Tap = deploy parachute
					if can_deploy_parachute:
						toggle_parachute()
				else:
					# Process swipe gestures
					if abs(swipe_vector.x) > swipe_threshold:
						# Horizontal swipe - movement
						if swipe_vector.x > 0:
							# Swipe right
							velocity.x += 100
						else:
							# Swipe left  
							velocity.x -= 100
					
					if abs(swipe_vector.y) > swipe_threshold:
						# Vertical swipe - dive control
						if swipe_vector.y > 0:
							# Swipe down - fast dive
							is_fast_diving = true
						else:
							# Swipe up - normal dive
							is_fast_diving = false
			
			is_touching = false
	
	elif event is InputEventScreenDrag and is_touching:
		# Continuous touch movement for steering
		var drag_vector = event.position - touch_start_pos
		if abs(drag_vector.x) > 20:  # Dead zone
			# Tilt-style steering while touching
			var tilt_strength = clamp(drag_vector.x / 200.0, -1.0, 1.0)
			velocity.x += tilt_strength * ACCELERATION * get_physics_process_delta_time()

func _physics_process(delta):
	# Don't process movement if game is finished
	if game_finished:
		return
		
	# Handle parachute toggle
	if Input.is_action_just_pressed("parachute") and can_deploy_parachute:
		toggle_parachute()
	
	# Handle dive controls
	if Input.is_action_pressed("dive_fast"):
		is_fast_diving = true
	elif Input.is_action_pressed("dive_normal") or Input.is_action_just_released("dive_fast"):
		is_fast_diving = false
	
	# Add analog stick dive control
	if ControllerManager.controller_connected:
		var stick_y = ControllerManager.get_left_stick_vector().y
		if stick_y > 0.5:  # Stick pushed down
			is_fast_diving = true
		elif stick_y < -0.5:  # Stick pushed up
			is_fast_diving = false
	
	# Handle reset
	if Input.is_action_just_pressed("reset_game"):
		get_tree().reload_current_scene()
	
	# Update power-up timers
	if has_speed_boost:
		speed_boost_time -= delta
		if speed_boost_time <= 0:
			has_speed_boost = false
	
	if has_shield:
		shield_time -= delta
		if shield_time <= 0:
			has_shield = false
			print("Shield deactivated!")
	
	if has_magnet:
		magnet_time -= delta
		if magnet_time <= 0:
			has_magnet = false
			print("Magnet deactivated!")
		else:
			# Attract nearby coins
			attract_coins()
	
	if has_ghost:
		ghost_time -= delta
		if ghost_time <= 0:
			has_ghost = false
			print("Ghost mode deactivated!")
			modulate.a = 1.0  # Return to normal visibility
		else:
			modulate.a = 0.7  # Semi-transparent while in ghost mode
	
	# Apply gravity based on current state
	var gravity = GRAVITY_NORMAL
	var max_fall = MAX_FALL_SPEED
	
	if parachute_deployed:
		gravity = GRAVITY_PARACHUTE
		max_fall = MAX_FALL_SPEED_PARACHUTE
	elif has_speed_boost:
		gravity = GRAVITY_SPEED_BOOST
		max_fall = MAX_FALL_SPEED_SPEED_BOOST
	elif is_fast_diving:
		gravity = GRAVITY_FAST_DIVE
		max_fall = MAX_FALL_SPEED_FAST_DIVE
	
	velocity.y += gravity * gravity_multiplier * delta
	velocity.y = min(velocity.y, max_fall)
	
	# Apply cloud drag effect
	if in_cloud and not parachute_deployed:
		velocity.y *= cloud_drag_multiplier
	
	# Update altitude calculation
	update_altitude()
	
	# Handle horizontal movement with smooth acceleration
	var direction = 0
	
	# Keyboard/D-pad input
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	
	# Add analog stick support with deadzone
	if ControllerManager.controller_connected:
		var stick_input = ControllerManager.get_left_stick_vector().x
		if abs(stick_input) > 0:
			direction = stick_input  # Use analog value for smoother control
	
	# Apply acceleration or friction based on input
	if direction != 0:
		velocity.x += direction * ACCELERATION * speed_multiplier * delta
		velocity.x = clamp(velocity.x, -SPEED * speed_multiplier, SPEED * speed_multiplier)
	else:
		# Apply friction when no input
		var friction_force = FRICTION if is_on_floor() else AIR_RESISTANCE
		if velocity.x > 0:
			velocity.x = max(0, velocity.x - friction_force * delta)
		elif velocity.x < 0:
			velocity.x = min(0, velocity.x + friction_force * delta)
	
	# Add wind effect when parachute is deployed
	if parachute_deployed:
		if has_wind_override:
			velocity.x += wind_override.x * delta
			velocity.y += wind_override.y * delta
		else:
			wind_time += delta
			var wind_force = sin(wind_time * 2.0) * WIND_STRENGTH
			velocity.x += wind_force * delta
		
		# Apply parachute drag to horizontal movement
		velocity.x *= PARACHUTE_DRAG
	
	move_and_slide()
	
	# Clamp player position to screen boundaries
	var screen_width = 360  # From project.godot viewport_width
	global_position.x = clamp(global_position.x, 20, screen_width - 20)
	
	# Update camera to follow player vertically only
	var camera = get_node("../GameCamera")
	if camera:
		camera.position.x = 180  # Keep camera centered horizontally
		camera.position.y = global_position.y  # Follow player vertically
	
	# Check if we landed (on ground)
	if is_on_floor():
		if parachute_deployed:
			finish_game()
		else:
			# Hard landing without parachute - instant death with 0 score
			instant_death()

func toggle_parachute():
	if not parachute_deployed and parachutes_available <= 0:
		return
	
	if is_transitioning:
		return
		
	parachute_deployed = !parachute_deployed
	is_transitioning = true
	deployment_transition_time = 0.0
	emit_signal("parachute_toggled", parachute_deployed)
	
	# Create smooth transition effect
	create_tween().tween_method(_update_parachute_transition, 0.0, 1.0, 0.3)
	
	# Reset wind time when deploying parachute
	if parachute_deployed:
		wind_time = 0.0
		# Add initial deployment physics impulse with upward jerk
		velocity.y *= 0.6  # Sudden slowdown when parachute opens
		velocity.y -= 150  # Upward jerk effect
		velocity.x *= 0.8  # Slight horizontal slowdown
		# Screen shake and particles for parachute deployment
		if screen_shake:
			screen_shake.shake_parachute()
		if particle_manager:
			particle_manager.trigger_parachute_effect(global_position)
		# Controller vibration for parachute deployment
		if ControllerManager.controller_connected:
			ControllerManager.vibrate(0.2, 0.3, 0.5)  # Medium vibration
	
	# Visual feedback with smooth transitions
	if has_node("ParachuteSprite"):
		var parachute_sprite = $ParachuteSprite
		parachute_sprite.visible = parachute_deployed
		if parachute_deployed:
			# Animate parachute appearance
			parachute_sprite.modulate.a = 0.0
			parachute_sprite.scale = Vector2(0.5, 0.5)
			var tween = create_tween()
			tween.parallel().tween_property(parachute_sprite, "modulate:a", 1.0, 0.3)
			tween.parallel().tween_property(parachute_sprite, "scale", Vector2(1.0, 1.0), 0.3)
		else:
			# Quick fade out when closing parachute
			var tween = create_tween()
			tween.tween_property(parachute_sprite, "modulate:a", 0.0, 0.1)
	
	if has_node("ParachuteLabel"):
		$ParachuteLabel.visible = parachute_deployed

func _update_parachute_transition(progress: float):
	deployment_transition_time = progress
	if progress >= 1.0:
		is_transitioning = false
	
	# Add subtle visual effects during transition
	if has_node("PlayerSprite"):
		var sprite = $PlayerSprite
		if parachute_deployed:
			# Slight rotation during deployment
			sprite.rotation = lerp(0.0, 0.1, progress)
		else:
			sprite.rotation = lerp(0.1, 0.0, progress)

func _process(_delta):
	# Update player sprite rotation based on dive state
	if has_node("PlayerSprite") and not is_transitioning:
		var sprite = $PlayerSprite
		if is_fast_diving and not parachute_deployed:
			# Streamlined diving pose
			sprite.rotation = lerp(sprite.rotation, 0.0, 0.1)
			sprite.scale = lerp(sprite.scale, Vector2(0.9, 1.1), 0.1)
		else:
			# Normal pose
			sprite.rotation = lerp(sprite.rotation, 0.0, 0.1)
			sprite.scale = lerp(sprite.scale, Vector2(1.0, 1.0), 0.1)

func take_damage():
	lives -= 1
	emit_signal("lives_changed", lives)
	emit_signal("hit_hazard")
	# Screen shake and particles for collision
	if screen_shake:
		screen_shake.shake_collision()
	if particle_manager:
		particle_manager.trigger_impact_effect(global_position)
	
	# Controller vibration feedback
	if ControllerManager.controller_connected:
		ControllerManager.vibrate(0.3, 0.8, 0.8)  # Strong vibration for damage
	
	if lives <= 0:
		# Game over
		get_tree().call_deferred("change_scene_to_file", "res://scenes/GameOver.tscn")

func add_parachute():
	parachutes_available += 1

func add_speed_boost():
	has_speed_boost = true
	speed_boost_time = SPEED_BOOST_DURATION

func add_shield():
	has_shield = true
	shield_time = SHIELD_DURATION
	print("Shield activated for ", SHIELD_DURATION, " seconds!")

func add_magnet():
	has_magnet = true
	magnet_time = MAGNET_DURATION
	print("Magnet activated for ", MAGNET_DURATION, " seconds!")

func add_ghost_mode():
	has_ghost = true
	ghost_time = GHOST_DURATION
	print("Ghost mode activated for ", GHOST_DURATION, " seconds!")

func _on_area_2d_area_entered(area):
	if area.is_in_group("hazards") and not godmode_enabled and not has_shield and not has_ghost:
		take_damage()
	elif area.is_in_group("clouds"):
		# Clouds slow descent but don't damage
		enter_cloud_effect()
	elif area.is_in_group("powerups"):
		add_parachute()
		area.queue_free()

func _on_area_2d_area_exited(area):
	if area.is_in_group("clouds"):
		exit_cloud_effect()

func attract_coins():
	# Find all coins in the scene and attract them if they're within range
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		if coin and is_instance_valid(coin):
			var distance = global_position.distance_to(coin.global_position)
			if distance <= magnet_range:
				# Pull coin towards player
				var direction = (global_position - coin.global_position).normalized()
				var attraction_force = 200.0 * (1.0 - distance / magnet_range)
				coin.global_position += direction * attraction_force * get_physics_process_delta_time()

func enter_cloud_effect():
	in_cloud = true
	# Visual feedback - slight blue tint when in cloud
	modulate = Color(0.9, 0.95, 1.0, 1.0)
	print("Entered cloud - descent slowed")

func exit_cloud_effect():
	in_cloud = false
	# Return to normal color (unless in ghost mode)
	if not has_ghost:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	print("Exited cloud - normal descent")

func update_altitude():
	# Calculate current altitude based on Y position
	# Convert game units to feet (linear interpolation)
	var progress = (global_position.y - STARTING_Y_POSITION) / TOTAL_FALL_DISTANCE
	progress = clamp(progress, 0.0, 1.0)
	
	var new_altitude = int(STARTING_ALTITUDE_FEET * (1.0 - progress))
	new_altitude = max(0, new_altitude)  # Don't go below ground level
	
	if new_altitude != current_altitude_feet:
		current_altitude_feet = new_altitude
		emit_signal("altitude_changed", current_altitude_feet)

func instant_death():
	if not game_finished:
		game_finished = true
		print("Player died from hard landing!")
		
		# Screen shake and particles for hard landing
		if screen_shake:
			screen_shake.shake_collision()
		if particle_manager:
			particle_manager.trigger_impact_effect(global_position)
		
		# Get game manager and end the game with 0 score
		var game_manager = get_node_or_null("../GameManager")
		if game_manager:
			game_manager.end_game_death()

func finish_game():
	if not game_finished:
		game_finished = true
		print("Player finished the game!")
		
		# Get game manager and end the game
		var game_manager = get_node_or_null("../GameManager")
		if game_manager:
			game_manager.end_game(lives)

# Dev Console Methods
func set_godmode(enabled: bool):
	godmode_enabled = enabled

func set_speed_multiplier(multiplier: float):
	speed_multiplier = multiplier

func set_gravity_multiplier(multiplier: float):
	gravity_multiplier = multiplier

func set_wind_override(wind_force: Vector2):
	wind_override = wind_force
	has_wind_override = true

func clear_wind_override():
	has_wind_override = false
	wind_override = Vector2.ZERO

func update_parachute_visibility():
	if has_node("ParachuteSprite"):
		$ParachuteSprite.visible = parachute_deployed
	if has_node("ParachuteLabel"):
		$ParachuteLabel.visible = parachute_deployed