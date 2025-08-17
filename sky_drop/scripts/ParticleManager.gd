extends Node2D

func _ready():
	# Connect to game events
	var game_manager = get_node_or_null("../GameManager")
	if game_manager:
		game_manager.coin_collected_ui.connect(_on_coin_collected)

func create_coin_particles(pos: Vector2):
	# Simple sparkle effect for coin collection
	for i in range(8):
		var particle = create_simple_particle()
		add_child(particle)
		particle.global_position = pos
		
		# Random direction and speed
		var angle = randf() * 2 * PI
		var speed = randf_range(50, 150)
		var direction = Vector2(cos(angle), sin(angle))
		
		# Animate particle
		var tween = create_tween()
		tween.parallel().tween_property(particle, "global_position", pos + direction * speed, 0.5)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.parallel().tween_property(particle, "scale", Vector2(0.1, 0.1), 0.5)
		tween.tween_callback(particle.queue_free)

func create_powerup_particles(pos: Vector2, color: Color = Color.GREEN):
	# Burst effect for power-up collection
	for i in range(12):
		var particle = create_simple_particle()
		particle.color = color
		add_child(particle)
		particle.global_position = pos
		
		# Radial burst pattern
		var angle = (i / 12.0) * 2 * PI
		var speed = randf_range(80, 200)
		var direction = Vector2(cos(angle), sin(angle))
		
		# Animate particle
		var tween = create_tween()
		tween.parallel().tween_property(particle, "global_position", pos + direction * speed, 0.7)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.7)
		tween.parallel().tween_property(particle, "scale", Vector2(0.2, 0.2), 0.7)
		tween.tween_callback(particle.queue_free)

func create_impact_particles(pos: Vector2):
	# Explosion effect for collisions
	for i in range(6):
		var particle = create_simple_particle()
		particle.color = Color.RED
		particle.scale = Vector2(3.0, 3.0)
		add_child(particle)
		particle.global_position = pos
		
		# Random scatter
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		
		# Animate particle
		var tween = create_tween()
		tween.parallel().tween_property(particle, "global_position", pos + offset, 0.3)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(particle, "scale", Vector2(0.5, 0.5), 0.3)
		tween.tween_callback(particle.queue_free)

func create_parachute_particles(pos: Vector2):
	# Wind trail effect for parachute deployment
	for i in range(10):
		var particle = create_simple_particle()
		particle.color = Color.WHITE
		particle.scale = Vector2(2.0, 2.0)
		add_child(particle)
		particle.global_position = pos + Vector2(randf_range(-20, 20), randf_range(-10, 10))
		
		# Upward drift
		var drift = Vector2(randf_range(-50, 50), randf_range(-100, -50))
		
		# Animate particle
		var tween = create_tween()
		tween.parallel().tween_property(particle, "global_position", pos + drift, 1.0)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 1.0)
		tween.parallel().tween_property(particle, "scale", Vector2(0.1, 0.1), 1.0)
		tween.tween_callback(particle.queue_free)

func create_simple_particle() -> ColorRect:
	var particle = ColorRect.new()
	particle.size = Vector2(4, 4)
	particle.color = Color.WHITE
	particle.anchor_left = 0.5
	particle.anchor_right = 0.5
	particle.anchor_top = 0.5
	particle.anchor_bottom = 0.5
	return particle

func _on_coin_collected(coin_value: int, combo_multiplier: int):
	# This will be called when a coin is collected
	# We need the position, which we'll get from the coin itself
	pass

# Public methods to trigger effects
func trigger_coin_effect(pos: Vector2):
	create_coin_particles(pos)

func trigger_powerup_effect(pos: Vector2, powerup_type: String = ""):
	var color = Color.GREEN
	match powerup_type:
		"shield":
			color = Color.CYAN
		"magnet":
			color = Color.PURPLE
		"ghost":
			color = Color(1, 1, 1, 0.5)
		"speed":
			color = Color.ORANGE
	create_powerup_particles(pos, color)

func trigger_impact_effect(pos: Vector2):
	create_impact_particles(pos)

func trigger_parachute_effect(pos: Vector2):
	create_parachute_particles(pos)