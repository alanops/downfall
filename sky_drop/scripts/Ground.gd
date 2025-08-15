extends Area2D

signal player_landed

func _ready():
	add_to_group("ground")

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("player_landed")
		
		# Get the game manager and end the game
		var game_manager = get_node_or_null("/root/Main/GameManager")
		if game_manager:
			game_manager.end_game(body.lives)