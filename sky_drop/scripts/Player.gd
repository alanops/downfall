extends CharacterBody2D

const SPEED = 200.0
const GRAVITY_NORMAL = 400.0
const GRAVITY_PARACHUTE = 100.0
const MAX_FALL_SPEED = 600.0
const MAX_FALL_SPEED_PARACHUTE = 150.0

var parachute_deployed = false
var lives = 3
var parachutes_available = 1
var can_deploy_parachute = true

signal lives_changed(new_lives)
signal parachute_toggled(deployed)
signal hit_hazard()

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Handle parachute toggle
	if Input.is_action_just_pressed("parachute") and can_deploy_parachute:
		toggle_parachute()
	
	# Apply gravity
	var gravity = GRAVITY_PARACHUTE if parachute_deployed else GRAVITY_NORMAL
	var max_fall = MAX_FALL_SPEED_PARACHUTE if parachute_deployed else MAX_FALL_SPEED
	
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall)
	
	# Handle horizontal movement
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	
	velocity.x = direction * SPEED
	
	move_and_slide()

func toggle_parachute():
	if not parachute_deployed and parachutes_available <= 0:
		return
		
	parachute_deployed = !parachute_deployed
	emit_signal("parachute_toggled", parachute_deployed)
	
	# Visual feedback
	if has_node("ParachuteSprite"):
		$ParachuteSprite.visible = parachute_deployed
	if has_node("ParachuteLabel"):
		$ParachuteLabel.visible = parachute_deployed

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