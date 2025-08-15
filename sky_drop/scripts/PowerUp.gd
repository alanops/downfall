extends Area2D

@export var fall_speed: float = 50.0
@export var bob_amplitude: float = 10.0
@export var bob_frequency: float = 2.0

var time: float = 0.0
var initial_x: float

func _ready():
	add_to_group("powerups")
	initial_x = position.x

func _physics_process(delta):
	time += delta
	
	# Fall down slowly
	position.y += fall_speed * delta
	
	# Bob left and right
	position.x = initial_x + sin(time * bob_frequency) * bob_amplitude
	
	# Remove if off screen
	if position.y > 400:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_parachute()
		queue_free()