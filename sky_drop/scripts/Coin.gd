extends Area2D

@onready var visual = $Visual
@onready var glow = $Glow
@onready var animation_player = $AnimationPlayer

var collected = false
var coin_value = 10
var floating_speed = 50.0
var bob_amplitude = 3.0
var bob_frequency = 2.0
var time_alive = 0.0

signal coin_collected(coin, position)

func _ready():
	# Add to coins group for magnet detection
	add_to_group("coins")
	
	# Set up floating animation
	create_floating_animation()
	animation_player.play("float")
	
	# Connect to game manager for collection
	var game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		coin_collected.connect(game_manager._on_coin_collected)

func _physics_process(delta):
	if collected:
		return
		
	time_alive += delta
	
	# Float downward slowly
	global_position.y += floating_speed * delta
	
	# Remove if off screen
	if global_position.y > get_viewport().size.y + 100:
		queue_free()

func _on_body_entered(body):
	if collected:
		return
		
	if body.name == "Player":
		collect()

func collect():
	if collected:
		return
		
	collected = true
	coin_collected.emit(self, global_position)
	
	# Trigger particle effect only if visible on screen
	var particle_manager = get_node_or_null("/root/Main/ParticleManager")
	if particle_manager and is_visible_in_tree():
		# Check if position is within visible screen bounds
		var viewport = get_viewport()
		if viewport:
			var camera = viewport.get_camera_2d()
			if camera:
				var screen_pos = camera.get_screen_center_position()
				var screen_size = viewport.get_visible_rect().size
				var relative_pos = global_position - screen_pos + screen_size / 2
				
				# Only create particles if coin is on screen
				if relative_pos.x >= -50 and relative_pos.x <= screen_size.x + 50 and \
				   relative_pos.y >= -50 and relative_pos.y <= screen_size.y + 50:
					particle_manager.trigger_coin_effect(global_position)
	
	# Play collection animation
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
	
	# Play coin collection sound
	AudioManager.play_sound("coin_collect", -8.0)  # Slightly quieter

func create_floating_animation():
	var animation = Animation.new()
	animation.length = 1.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add rotation track (using VALUE track for 2D rotation)
	var rotation_track = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rotation_track, NodePath("Visual:rotation"))
	animation.track_insert_key(rotation_track, 0.0, 0.0)
	animation.track_insert_key(rotation_track, 0.5, PI)
	animation.track_insert_key(rotation_track, 1.0, 2 * PI)
	
	# Add bobbing track (using VALUE track for 2D position)
	var position_track = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("Visual:position"))
	animation.track_insert_key(position_track, 0.0, Vector2(0, -bob_amplitude))
	animation.track_insert_key(position_track, 0.5, Vector2(0, bob_amplitude))
	animation.track_insert_key(position_track, 1.0, Vector2(0, -bob_amplitude))
	
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("float", animation)
	animation_player.add_animation_library("default", animation_library)
