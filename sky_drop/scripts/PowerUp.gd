extends Area2D

@export var fall_speed: float = 50.0
@export var bob_amplitude: float = 10.0
@export var bob_frequency: float = 2.0

enum PowerUpType {
	PARACHUTE,
	SPEED_BOOST,
	SHIELD,
	MAGNET,
	GHOST
}

@export var powerup_type: PowerUpType = PowerUpType.PARACHUTE

var time: float = 0.0
var initial_x: float

func _ready():
	add_to_group("powerups")
	initial_x = position.x
	update_visual()

func get_powerup_name() -> String:
	match powerup_type:
		PowerUpType.PARACHUTE:
			return "parachute"
		PowerUpType.SPEED_BOOST:
			return "speed"
		PowerUpType.SHIELD:
			return "shield"
		PowerUpType.MAGNET:
			return "magnet"
		PowerUpType.GHOST:
			return "ghost"
		_:
			return "unknown"

func update_visual():
	var sprite = $Sprite
	if sprite:
		match powerup_type:
			PowerUpType.PARACHUTE:
				sprite.color = Color.GREEN
			PowerUpType.SPEED_BOOST:
				sprite.color = Color.ORANGE
			PowerUpType.SHIELD:
				sprite.color = Color.CYAN
			PowerUpType.MAGNET:
				sprite.color = Color.PURPLE
			PowerUpType.GHOST:
				sprite.color = Color(1, 1, 1, 0.7)

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
		# Trigger particle effect
		var particle_manager = get_node_or_null("/root/Main/ParticleManager")
		if particle_manager:
			var powerup_name = get_powerup_name()
			particle_manager.trigger_powerup_effect(global_position, powerup_name)
		
		match powerup_type:
			PowerUpType.PARACHUTE:
				body.add_parachute()
			PowerUpType.SPEED_BOOST:
				body.add_speed_boost()
			PowerUpType.SHIELD:
				body.add_shield()
			PowerUpType.MAGNET:
				body.add_magnet()
			PowerUpType.GHOST:
				body.add_ghost_mode()
		queue_free()