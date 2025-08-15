extends Area2D

signal player_landed

func _ready():
	add_to_group("ground")

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player landed!")
		emit_signal("player_landed")
		
		# Get the game manager and end the game
		var game_manager = get_node_or_null("../GameManager")
		if game_manager:
			print("Ending game with lives: ", body.lives)
			game_manager.end_game(body.lives)
		else:
			print("Could not find GameManager")