extends Area2D

@export var cloud_size = 100.0
@export var particle_count = 15
@export var move_speed = 100.0
@export var move_direction = 1

var particles = []
var screen_width = 360
var time = 0.0

func _ready():
	add_to_group("clouds")
	create_particle_cloud()
	print("Particle cloud created at position: ", position)

func _physics_process(delta):
	time += delta
	
	# Move the entire cloud
	position.x += move_speed * move_direction * delta
	
	# Animate particles
	animate_particles(delta)
	
	# Wrap around screen
	if position.x > screen_width + 200:
		position.x = -200
	elif position.x < -200:
		position.x = screen_width + 200

func create_particle_cloud():
	# Create collision shape
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = cloud_size
	collision_shape.shape = circle_shape
	add_child(collision_shape)
	
	# Create multiple particles for cloud effect
	for i in range(particle_count):
		var particle = create_cloud_particle()
		add_child(particle)
		particles.append(particle)
		
		# Position particles in cluster
		var angle = randf() * 2 * PI
		var distance = randf() * cloud_size * 0.8
		particle.position = Vector2(cos(angle), sin(angle)) * distance

func create_cloud_particle():
	var particle = ColorRect.new()
	
	# Random size for each particle
	var size = randf_range(8, 20)
	particle.size = Vector2(size, size)
	
	# Cloud color - light blue/white with transparency
	particle.color = Color(0.9, 0.95, 1.0, randf_range(0.3, 0.7))
	
	# Center anchor
	particle.anchor_left = 0.5
	particle.anchor_right = 0.5
	particle.anchor_top = 0.5
	particle.anchor_bottom = 0.5
	
	return particle

func animate_particles(delta):
	# Gentle floating animation for each particle
	for i in range(particles.size()):
		if particles[i] and is_instance_valid(particles[i]):
			var particle = particles[i]
			
			# Gentle bobbing motion
			var bob_speed = 1.0 + i * 0.1  # Slight variation per particle
			var bob_amount = 3.0
			particle.position.y += sin(time * bob_speed + i) * bob_amount * delta
			
			# Slight horizontal drift
			var drift_speed = 0.5 + i * 0.05
			particle.position.x += sin(time * drift_speed + i * 2) * 1.5 * delta
			
			# Fade in/out animation
			var alpha_variation = 0.2 * sin(time * 0.8 + i * 0.5)
			particle.modulate.a = 0.5 + alpha_variation

func _on_body_entered(body):
	if body.is_in_group("player"):
		# This is handled in Player script now
		pass