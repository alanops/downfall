extends Node2D

@export var plane_scene: PackedScene
@export var cloud_scene: PackedScene
@export var powerup_scene: PackedScene

var coin_scene = preload("res://scenes/Coin.tscn")
var particle_cloud_scene = preload("res://scenes/ParticleCloud.tscn")

@export var spawn_interval_min: float = 0.4
@export var spawn_interval_max: float = 1.0
@export var powerup_chance: float = 0.15

var spawn_timer: float = 0.0
var next_spawn_time: float = 2.0
var screen_width = 360
var screen_height = 640
var spawn_margin = 50
var spawn_height_range = 26800  # Spawn hazards throughout the extended 45-second fall

func _ready():
	randomize()
	next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)
	print("HazardSpawner ready! First spawn in: ", next_spawn_time, " seconds")
	print("Plane scene loaded: ", plane_scene != null)
	print("Cloud scene loaded: ", cloud_scene != null)
	print("PowerUp scene loaded: ", powerup_scene != null)

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= next_spawn_time:
		print("Attempting to spawn hazards...")
		
		# Get difficulty settings from GameManager
		var game_manager = get_node_or_null("../GameManager")
		var difficulty = 1  # Default to NORMAL
		if game_manager:
			difficulty = game_manager.current_difficulty
		
		# Adjust spawn count based on difficulty
		var num_spawns = 1  # Default
		match difficulty:
			0:  # EASY
				num_spawns = randi_range(1, 2)  # 1-2 obstacles per spawn
			1:  # NORMAL
				num_spawns = randi_range(2, 3)  # 2-3 obstacles per spawn
			2:  # HARD
				num_spawns = randi_range(3, 5)  # 3-5 obstacles per spawn
		
		for i in range(num_spawns):
			spawn_hazard()
		
		# Also spawn some random coins in safe areas
		if randf() < 0.3:  # 30% chance per spawn cycle
			spawn_safe_coins()
		
		spawn_timer = 0.0
		next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

func spawn_hazard():
	# Get player position for reference
	var player = get_node_or_null("../Player")
	if not player:
		return
		
	var player_y = player.global_position.y
	
	# Convert altitude range to Y positions  
	# 12,000 ft = ~11% of fall = Y position ~2,792
	# 4,000 ft = ~70% of fall = Y position ~18,840
	var altitude_12000_y = -200 + (27200 * 0.11)  # ~2,792
	var altitude_4000_y = -200 + (27200 * 0.70)   # ~18,840
	
	# Don't spawn if player hasn't reached the hazard zone yet
	if player_y < altitude_12000_y - 500:  # Smaller buffer
		return
	
	# Always spawn below player with minimum reaction distance
	var min_distance_ahead = 500  # Minimum distance below player for reaction time
	var max_distance_ahead = 1200  # Maximum distance below player
	var spawn_y = randf_range(player_y + min_distance_ahead, player_y + max_distance_ahead)
	
	# Clamp to hazard zone bounds
	spawn_y = clamp(spawn_y, altitude_12000_y, altitude_4000_y)
	
	# Progressive difficulty - more power-ups in later sections
	var current_powerup_chance = powerup_chance
	if player_y > 2000:  # After halfway point
		current_powerup_chance += 0.05  # 20% chance instead of 15%
	
	# Chance to spawn power-up instead
	if randf() < current_powerup_chance and powerup_scene:
		var powerup = powerup_scene.instantiate()
		add_child(powerup)
		
		# Randomly choose power-up type with varied distribution
		var powerup_roll = randf()
		if powerup_roll < 0.3:
			powerup.powerup_type = powerup.PowerUpType.PARACHUTE
		elif powerup_roll < 0.5:
			powerup.powerup_type = powerup.PowerUpType.SPEED_BOOST
		elif powerup_roll < 0.7:
			powerup.powerup_type = powerup.PowerUpType.SHIELD
		elif powerup_roll < 0.85:
			powerup.powerup_type = powerup.PowerUpType.MAGNET
		else:
			powerup.powerup_type = powerup.PowerUpType.GHOST
		
		powerup.position = Vector2(randf_range(50, screen_width - 50), spawn_y)
		print("Spawned power-up at Y: ", spawn_y, " Player at Y: ", player_y)
		return
	
	# Get difficulty settings for plane vs cloud ratio
	var game_manager = get_node_or_null("../GameManager")
	var difficulty = 1  # Default to NORMAL
	if game_manager:
		difficulty = game_manager.current_difficulty
	
	# Adjust plane chance based on difficulty (reduced cloud frequency)
	var plane_chance = 0.8  # Default - fewer clouds
	match difficulty:
		0:  # EASY
			plane_chance = 0.7  # 70% planes, 30% clouds (easier)
		1:  # NORMAL
			plane_chance = 0.8  # 80% planes, 20% clouds
		2:  # HARD
			plane_chance = 0.9  # 90% planes, 10% clouds (harder)
	
	var hazard
	var hazard_type = "unknown"
	if randf() < plane_chance and plane_scene:
		hazard = plane_scene.instantiate()
		hazard_type = "plane"
	elif particle_cloud_scene:
		hazard = particle_cloud_scene.instantiate()
		hazard_type = "cloud"
	else:
		print("Error: Could not create hazard - missing scene references")
		return
	
	add_child(hazard)
	
	# Randomly spawn from left or right with extended spawn zones
	if randf() < 0.5:
		hazard.position = Vector2(-200, spawn_y)  # Further left spawn
		hazard.move_direction = 1
		print("Spawning plane from LEFT edge, moving RIGHT (direction = 1)")
	else:
		hazard.position = Vector2(screen_width + 200, spawn_y)  # Further right spawn
		hazard.move_direction = -1
		print("Spawning plane from RIGHT edge, moving LEFT (direction = -1)")
	
	# Update sprite based on direction (only for planes)
	if hazard_type == "plane" and hazard.has_method("update_sprite_direction"):
		hazard.update_sprite_direction()
	
	# Vary the speed based on hazard type
	if hazard_type == "cloud":
		hazard.move_speed = randf_range(50, 150)  # Clouds move slower
	else:
		hazard.move_speed = randf_range(100, 250)  # Planes normal speed
	
	print("Spawned ", hazard_type, " at Y: ", spawn_y, " Player at Y: ", player_y)
	
	# 40% chance to spawn a coin near dangerous hazards (planes only)
	if hazard_type == "plane" and randf() < 0.4:
		spawn_coin_near_hazard(hazard.position)

func spawn_coin_near_hazard(hazard_pos: Vector2):
	# Spawn a coin near a hazard for risk/reward
	if not coin_scene:
		return
		
	var coin = coin_scene.instantiate()
	add_child(coin)
	
	# Position coin near but not exactly on the hazard
	var offset_x = randf_range(-80, 80)
	var offset_y = randf_range(-30, 30)
	coin.global_position = hazard_pos + Vector2(offset_x, offset_y)
	
	print("Spawned risk/reward coin near hazard")

func spawn_safe_coins():
	# Spawn 1-3 coins in relatively safe areas
	var player = get_node_or_null("../Player")
	if not player or not coin_scene:
		return
		
	var num_coins = randi_range(1, 3)
	for i in range(num_coins):
		var coin = coin_scene.instantiate()
		add_child(coin)
		
		# Spawn in safe areas below player - not too close to edges
		var safe_x = randf_range(60, screen_width - 60)
		var safe_y = randf_range(player.global_position.y + 200, player.global_position.y + 600)
		
		coin.global_position = Vector2(safe_x, safe_y)
	
	print("Spawned ", num_coins, " safe coins")

func spawn_cloud():
	# Function for dev console - spawn particle cloud
	if not particle_cloud_scene:
		return
		
	var cloud = particle_cloud_scene.instantiate()
	add_child(cloud)
	
	var player = get_node_or_null("../Player")
	if player:
		cloud.global_position = Vector2(randf_range(50, screen_width - 50), player.global_position.y + 200)
		cloud.move_direction = 1 if randf() < 0.5 else -1
		cloud.move_speed = randf_range(50, 150)

func spawn_powerup():
	# Function for dev console
	if not powerup_scene:
		return
		
	var powerup = powerup_scene.instantiate()
	add_child(powerup)
	
	# Random power-up type
	var powerup_roll = randf()
	if powerup_roll < 0.2:
		powerup.powerup_type = powerup.PowerUpType.PARACHUTE
	elif powerup_roll < 0.4:
		powerup.powerup_type = powerup.PowerUpType.SPEED_BOOST
	elif powerup_roll < 0.6:
		powerup.powerup_type = powerup.PowerUpType.SHIELD
	elif powerup_roll < 0.8:
		powerup.powerup_type = powerup.PowerUpType.MAGNET
	else:
		powerup.powerup_type = powerup.PowerUpType.GHOST
	
	var player = get_node_or_null("../Player")
	if player:
		powerup.global_position = Vector2(randf_range(50, screen_width - 50), player.global_position.y + 150)