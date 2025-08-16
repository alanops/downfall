extends Node

var camera: Camera2D
var shake_intensity = 0.0
var shake_duration = 0.0
var shake_timer = 0.0
var original_position: Vector2

signal shake_finished

func _ready():
	# Find the camera in the scene
	camera = get_viewport().get_camera_2d()
	if not camera:
		print("Warning: No Camera2D found for screen shake")
		return
	original_position = camera.global_position

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		
		# Calculate shake offset
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		
		# Apply shake with decay
		var decay_factor = shake_timer / shake_duration
		shake_offset *= decay_factor
		
		if camera:
			camera.global_position = original_position + shake_offset
		
		if shake_timer <= 0:
			# Reset camera position
			if camera:
				camera.global_position = original_position
			shake_finished.emit()

func shake(duration: float, intensity: float):
	shake_duration = duration
	shake_intensity = intensity
	shake_timer = duration
	
	if camera:
		original_position = camera.global_position

func shake_impulse(intensity: float, duration: float = 0.2):
	shake(duration, intensity)

# Preset shake effects
func shake_collision():
	shake_impulse(8.0, 0.3)

func shake_parachute():
	shake_impulse(5.0, 0.2)

func shake_powerup():
	shake_impulse(3.0, 0.15)

func shake_coin():
	shake_impulse(1.5, 0.1)