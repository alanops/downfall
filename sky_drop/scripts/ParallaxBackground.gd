extends ParallaxBackground

@export var scroll_speed: float = 100.0

func _process(delta):
	# Scroll the background based on player falling speed
	var player = get_node_or_null("/root/Main/Player")
	if player:
		var fall_speed = player.velocity.y
		scroll_offset.y += fall_speed * delta * 0.5  # Half speed for parallax effect