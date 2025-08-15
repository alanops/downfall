extends Node2D

@export var plane_scene: PackedScene
@export var cloud_scene: PackedScene
@export var powerup_scene: PackedScene

@export var spawn_interval_min: float = 1.0
@export var spawn_interval_max: float = 3.0
@export var powerup_chance: float = 0.1

var spawn_timer: float = 0.0
var next_spawn_time: float = 2.0
var screen_height = 360
var spawn_margin = 50

func _ready():
	randomize()
	next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= next_spawn_time:
		spawn_hazard()
		spawn_timer = 0.0
		next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

func spawn_hazard():
	var spawn_y = randf_range(spawn_margin, screen_height - spawn_margin)
	
	# Chance to spawn power-up instead
	if randf() < powerup_chance and powerup_scene:
		var powerup = powerup_scene.instantiate()
		add_child(powerup)
		powerup.position = Vector2(640 + 50, spawn_y)
		return
	
	# Randomly choose between plane and cloud
	var hazard
	if randf() < 0.7 and plane_scene:  # 70% chance for plane
		hazard = plane_scene.instantiate()
	elif cloud_scene:
		hazard = cloud_scene.instantiate()
	else:
		return
	
	add_child(hazard)
	
	# Randomly spawn from left or right
	if randf() < 0.5:
		hazard.position = Vector2(-50, spawn_y)
		hazard.move_direction = 1
	else:
		hazard.position = Vector2(690, spawn_y)
		hazard.move_direction = -1
	
	# Vary the speed
	hazard.move_speed = randf_range(100, 250)