extends CanvasLayer

@onready var time_label = $TimeLabel
@onready var lives_label = $LivesLabel
@onready var parachute_label = $ParachuteLabel
@onready var score_label = $ScoreLabel

var game_manager

func _ready():
	game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.connect("time_updated", _on_time_updated)
		game_manager.connect("score_updated", _on_score_updated)

func _on_time_updated(time):
	time_label.text = "Time: " + game_manager.format_time(time)

func _on_lives_changed(lives):
	lives_label.text = "Lives: " + str(lives)

func _on_parachute_toggled(deployed):
	parachute_label.text = "Parachute: " + ("DEPLOYED" if deployed else "READY")
	parachute_label.modulate = Color.GREEN if deployed else Color.WHITE

func _on_score_updated(score):
	score_label.text = "Score: " + str(score)

func show_game_over(final_time, lives_remaining):
	var game_over_text = "GAME OVER\n"
	game_over_text += "Time: " + game_manager.format_time(final_time) + "\n"
	game_over_text += "Lives Bonus: " + str(lives_remaining * 1000) + "\n"
	game_over_text += "Final Score: " + str(game_manager.score)
	
	# You would show this in a proper game over screen
	print(game_over_text)