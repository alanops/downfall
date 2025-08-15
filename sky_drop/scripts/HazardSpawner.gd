extends Node2D

@export var plane_scene: PackedScene
@export var cloud_scene: PackedScene
@export var powerup_scene: PackedScene

@export var spawn_interval_min: float = 1.2
@export var spawn_interval_max: float = 3.5
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
		print("Attempting to spawn hazard...")
		spawn_hazard()
		spawn_timer = 0.0
		next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

func spawn_hazard():
	# Get player position and spawn hazards around the player
	var player = get_node_or_null("../Player")
	if not player:
		return
		
	var player_y = player.global_position.y
	# Spawn hazards ahead of the player (below them as they fall)
	var spawn_y = randf_range(player_y + 100, player_y + 800)
	
	# Don't spawn beyond the ground
	if spawn_y > 3900:
		return
	
	# Progressive difficulty - more power-ups in later sections
	var current_powerup_chance = powerup_chance
	if player_y > 2000:  # After halfway point
		current_powerup_chance += 0.05  # 20% chance instead of 15%
	
	# Chance to spawn power-up instead
	if randf() < current_powerup_chance and powerup_scene:
		var powerup = powerup_scene.instantiate()
		add_child(powerup)
		powerup.position = Vector2(screen_width + 50, spawn_y)
		print("Spawned power-up at Y: ", spawn_y, " Player at Y: ", player_y)
		return
	
	# Randomly choose between plane and cloud (50/50 split)
	var hazard
	var hazard_type = "unknown"
	if randf() < 0.5 and plane_scene:  # 50% chance for plane
		hazard = plane_scene.instantiate()
		hazard_type = "plane"
	elif cloud_scene:
		hazard = cloud_scene.instantiate()
		hazard_type = "cloud"
	else:
		print("Error: Could not create hazard - missing scene references")
		return
	
	add_child(hazard)
	
	# Randomly spawn from left or right
	if randf() < 0.5:
		hazard.position = Vector2(-50, spawn_y)
		hazard.move_direction = 1
	else:
		hazard.position = Vector2(screen_width + 50, spawn_y)
		hazard.move_direction = -1
	
	# Vary the speed
	hazard.move_speed = randf_range(100, 250)
	
	print("Spawned ", hazard_type, " at Y: ", spawn_y, " Player at Y: ", player_y)