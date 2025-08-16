extends CanvasLayer

@onready var time_label = $TimeLabel
@onready var lives_label = $LivesLabel
@onready var parachute_label = $ParachuteLabel
@onready var score_label = $ScoreLabel
@onready var combo_label = $ComboLabel
@onready var altitude_label = $AltitudeLabel

var game_manager

func _ready():
	game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.connect("time_updated", _on_time_updated)
		game_manager.connect("score_updated", _on_score_updated)
		game_manager.connect("combo_updated", _on_combo_updated)
	
	# Connect to player for altitude updates
	var player = get_node("/root/Main/Player")
	if player:
		player.connect("altitude_changed", _on_altitude_changed)

func _on_time_updated(time):
	if time_label:
		time_label.text = "Time: " + game_manager.format_time(time)

func _on_lives_changed(lives):
	if lives_label:
		lives_label.text = "Lives: " + str(lives)

func _on_parachute_toggled(deployed):
	if parachute_label:
		parachute_label.text = "Parachute: " + ("DEPLOYED" if deployed else "READY")
		parachute_label.modulate = Color.GREEN if deployed else Color.WHITE

func _on_score_updated(score):
	if score_label:
		score_label.text = "Score: " + str(score)

func _on_combo_updated(combo_count: int, multiplier: int):
	if combo_label:
		if combo_count > 1:
			combo_label.text = "Combo: " + str(combo_count) + "x (" + str(multiplier) + "x points)"
			combo_label.modulate = Color.YELLOW
			combo_label.visible = true
		else:
			combo_label.visible = false

func _on_altitude_changed(altitude_feet: int):
	if altitude_label:
		# Format altitude with nice styling like real altimeters
		var altitude_text = format_altitude(altitude_feet)
		altitude_label.text = altitude_text
		
		# Color coding based on altitude
		if altitude_feet <= 2500:  # Below recommended minimum deployment altitude
			altitude_label.modulate = Color.RED
		elif altitude_feet <= 5000:  # Caution zone
			altitude_label.modulate = Color.YELLOW
		else:  # Safe zone
			altitude_label.modulate = Color.WHITE

func format_altitude(feet: int) -> String:
	# Format like real skydiving altimeters
	if feet >= 10000:
		return "ALT: %d,000 ft" % [feet / 1000]
	elif feet >= 1000:
		return "ALT: %d,%03d ft" % [feet / 1000, feet % 1000]
	else:
		return "ALT: %d ft" % feet

func show_game_over(final_time, lives_remaining):
	var game_over_text = "GAME OVER\n"
	game_over_text += "Time: " + game_manager.format_time(final_time) + "\n"
	game_over_text += "Lives Bonus: " + str(lives_remaining * 1000) + "\n"
	game_over_text += "Final Score: " + str(game_manager.score)
	
	# You would show this in a proper game over screen
	print(game_over_text)
