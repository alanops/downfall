extends CharacterBody2D

const SPEED = 200.0
const ACCELERATION = 800.0
const FRICTION = 600.0
const AIR_RESISTANCE = 50.0
const GRAVITY_NORMAL = 400.0
const GRAVITY_PARACHUTE = 100.0
const GRAVITY_FAST_DIVE = 800.0
const MAX_FALL_SPEED = 600.0
const MAX_FALL_SPEED_PARACHUTE = 150.0
const MAX_FALL_SPEED_FAST_DIVE = 1000.0
const PARACHUTE_DRAG = 0.95
const WIND_STRENGTH = 30.0

var parachute_deployed = false
var lives = 3
var parachutes_available = 1
var can_deploy_parachute = true
var game_finished = false
var wind_time = 0.0
var deployment_transition_time = 0.0
var is_transitioning = false
var is_fast_diving = false

signal lives_changed(new_lives)
signal parachute_toggled(deployed)
signal hit_hazard()

func _ready():
	add_to_group("player")

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
	
	# Handle reset
	if Input.is_action_just_pressed("reset_game"):
		get_tree().reload_current_scene()
	
	# Apply gravity based on current state
	var gravity = GRAVITY_NORMAL
	var max_fall = MAX_FALL_SPEED
	
	if parachute_deployed:
		gravity = GRAVITY_PARACHUTE
		max_fall = MAX_FALL_SPEED_PARACHUTE
	elif is_fast_diving:
		gravity = GRAVITY_FAST_DIVE
		max_fall = MAX_FALL_SPEED_FAST_DIVE
	
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall)
	
	# Handle horizontal movement with smooth acceleration
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	
	# Apply acceleration or friction based on input
	if direction != 0:
		velocity.x += direction * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -SPEED, SPEED)
	else:
		# Apply friction when no input
		var friction_force = FRICTION if is_on_floor() else AIR_RESISTANCE
		if velocity.x > 0:
			velocity.x = max(0, velocity.x - friction_force * delta)
		elif velocity.x < 0:
			velocity.x = min(0, velocity.x + friction_force * delta)
	
	# Add wind effect when parachute is deployed
	if parachute_deployed:
		wind_time += delta
		var wind_force = sin(wind_time * 2.0) * WIND_STRENGTH
		velocity.x += wind_force * delta
		
		# Apply parachute drag to horizontal movement
		velocity.x *= PARACHUTE_DRAG
	
	move_and_slide()
	
	# Update camera to follow player vertically only
	var camera = get_node("../GameCamera")
	if camera:
		camera.position.x = 180  # Keep camera centered horizontally
		camera.position.y = global_position.y  # Follow player vertically
	
	# Check if we landed (on ground)
	if is_on_floor():
		finish_game()

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
		# Add initial deployment physics impulse
		velocity.y *= 0.6  # Sudden slowdown when parachute opens
		velocity.x *= 0.8  # Slight horizontal slowdown
	
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
	
	if lives <= 0:
		# Game over
		get_tree().call_deferred("change_scene_to_file", "res://scenes/GameOver.tscn")

func add_parachute():
	parachutes_available += 1

func _on_area_2d_area_entered(area):
	if area.is_in_group("hazards"):
		take_damage()
	elif area.is_in_group("powerups"):
		add_parachute()
		area.queue_free()

func finish_game():
	if not game_finished:
		game_finished = true
		print("Player finished the game!")
		
		# Get game manager and end the game
		var game_manager = get_node_or_null("../GameManager")
		if game_manager:
			game_manager.end_game(lives)