extends CanvasLayer

@onready var time_label = $TimeLabel
@onready var lives_label = $LivesLabel
@onready var parachute_label = $ParachuteLabel
@onready var score_label = $ScoreLabel
@onready var combo_label = $ComboLabel
@onready var altitude_label = $AltitudeLabel
@onready var difficulty_label = $DifficultyLabel
@onready var controls_label = $ControlsLabel

var game_manager

func _ready():
	game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.connect("time_updated", _on_time_updated)
		game_manager.connect("score_updated", _on_score_updated)
		game_manager.connect("combo_updated", _on_combo_updated)
		update_difficulty_display()
	
	# Connect to player for altitude updates
	var player = get_node("/root/Main/Player")
	if player:
		player.connect("altitude_changed", _on_altitude_changed)
	
	# Connect to controller manager for dynamic control prompts
	if ControllerManager:
		ControllerManager.connect("controller_connected", _on_controller_connected)
		ControllerManager.connect("controller_disconnected", _on_controller_disconnected)
		update_control_prompts()

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

func _on_controller_connected(device_id: int, controller_name: String):
	update_control_prompts()

func _on_controller_disconnected(device_id: int):
	update_control_prompts()

func update_control_prompts():
	if not controls_label:
		return
	
	if ControllerManager.is_controller_connected:
		# Show controller-specific prompts
		var move_button = ControllerManager.get_button_prompt("move_left")
		var parachute_button = ControllerManager.get_button_prompt("parachute")
		var reset_button = ControllerManager.get_button_prompt("reset_game")
		var dive_button = ControllerManager.get_button_prompt("dive_fast")
		
		controls_label.text = "🎮 L-Stick = Move, %s = Parachute, %s = Reset, %s = Console" % [
			parachute_button,
			reset_button,
			ControllerManager.get_button_prompt("toggle_dev_console")
		]
	else:
		# Show keyboard controls
		controls_label.text = "Controls: Arrow/WASD = Move, Space = Parachute, R = Reset, ` = Dev Console, 1/2/3 = Difficulty"

func _input(event):
	if event is InputEventKey and event.pressed:
		if game_manager:
			match event.keycode:
				KEY_1:
					game_manager.set_difficulty(game_manager.Difficulty.EASY)
					update_difficulty_display()
				KEY_2:
					game_manager.set_difficulty(game_manager.Difficulty.NORMAL)
					update_difficulty_display()
				KEY_3:
					game_manager.set_difficulty(game_manager.Difficulty.HARD)
					update_difficulty_display()

func update_difficulty_display():
	if game_manager and difficulty_label:
		difficulty_label.text = "Difficulty: " + game_manager.get_difficulty_name()
