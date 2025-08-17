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
var landing_arrow: Control
var player: Node2D
var ground_position = Vector2(180, 27000)  # Landing zone center

func _ready():
	game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.connect("time_updated", _on_time_updated)
		game_manager.connect("score_updated", _on_score_updated)
		game_manager.connect("combo_updated", _on_combo_updated)
		update_difficulty_display()
	
	# Connect to player for altitude updates
	player = get_node("/root/Main/Player")
	if player:
		player.connect("altitude_changed", _on_altitude_changed)
	
	# Create landing zone arrow
	create_landing_arrow()
	
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
		
		controls_label.text = "GAMEPAD: L-Stick = Move, %s = Parachute, %s = Reset, %s = Console" % [
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

func show_tutorial_flash():
	# Create a tutorial overlay label
	var tutorial_label = Label.new()
	tutorial_label.text = "*** MISSION ***\nREACH LANDING ZONE\nAS FAST AS POSSIBLE!\n\nDIVE FAST TO WIN!\nDEPLOY PARACHUTE LATE!\n\nSPACE = PARACHUTE\nARROW/WASD = MOVE\n\nAVOID PLANES!\nCOLLECT SPEED BOOSTS!"
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_label.position = Vector2(0, 120)
	tutorial_label.size = Vector2(360, 280)
	tutorial_label.modulate = Color.YELLOW
	tutorial_label.add_theme_font_size_override("font_size", 13)
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Add a semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.position = Vector2(0, 0)
	background.size = Vector2(360, 640)
	
	# Add to scene
	add_child(background)
	add_child(tutorial_label)
	
	# Flash animation
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(tutorial_label, "modulate:a", 0.3, 0.5)
	tween.tween_property(tutorial_label, "modulate:a", 1.0, 0.5)
	
	# Remove after 3 seconds
	await get_tree().create_timer(3.0).timeout
	background.queue_free()
	tutorial_label.queue_free()

func show_success_message(final_score: int, final_time: float):
	# Create success overlay
	var success_label = Label.new()
	var time_message = ""
	if final_time < 30.0:
		time_message = "*** LIGHTNING FAST! ***"
	elif final_time < 45.0:
		time_message = "*** SPEEDY DESCENT! ***"
	else:
		time_message = "*** MISSION COMPLETE! ***"
	
	success_label.text = "*** SUCCESSFUL LANDING! ***\n\n%s\n\nTime: %s\nScore: %d\n\nRestarting..." % [time_message, format_time(final_time), final_score]
	success_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	success_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	success_label.position = Vector2(20, 200)
	success_label.size = Vector2(320, 240)
	success_label.modulate = Color.GREEN
	success_label.add_theme_font_size_override("font_size", 16)
	success_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Add semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0, 0.3, 0, 0.8)  # Green tint
	background.position = Vector2(0, 0)
	background.size = Vector2(360, 640)
	
	# Add to scene
	add_child(background)
	add_child(success_label)
	
	# Fade out after delay
	await get_tree().create_timer(2.5).timeout
	var tween = create_tween()
	tween.parallel().tween_property(background, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(success_label, "modulate:a", 0.0, 0.5)
	await tween.finished
	background.queue_free()
	success_label.queue_free()

func show_failure_message(final_time: float):
	# Create failure overlay
	var failure_label = Label.new()
	failure_label.text = "*** MISSION FAILED ***\n\nCrashed without parachute!\nTime: %s\n\nTry again..." % [format_time(final_time)]
	failure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	failure_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	failure_label.position = Vector2(20, 200)
	failure_label.size = Vector2(320, 240)
	failure_label.modulate = Color.RED
	failure_label.add_theme_font_size_override("font_size", 16)
	failure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Add semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0.3, 0, 0, 0.8)  # Red tint
	background.position = Vector2(0, 0)
	background.size = Vector2(360, 640)
	
	# Add to scene
	add_child(background)
	add_child(failure_label)
	
	# Fade out after delay
	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	tween.parallel().tween_property(background, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(failure_label, "modulate:a", 0.0, 0.5)
	await tween.finished
	background.queue_free()
	failure_label.queue_free()

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millisecs = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millisecs]

func create_landing_arrow():
	# Create arrow container
	landing_arrow = Control.new()
	landing_arrow.size = Vector2(60, 60)
	landing_arrow.position = Vector2(150, 300)  # Center of screen
	add_child(landing_arrow)
	
	# Create arrow label with Unicode arrow
	var arrow_label = Label.new()
	arrow_label.text = ">"
	arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow_label.size = Vector2(60, 60)
	arrow_label.add_theme_font_size_override("font_size", 40)
	arrow_label.modulate = Color.GREEN
	landing_arrow.add_child(arrow_label)
	
	# Create distance label
	var distance_label = Label.new()
	distance_label.name = "DistanceLabel"
	distance_label.text = "LANDING ZONE"
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance_label.position = Vector2(-30, 45)
	distance_label.size = Vector2(120, 20)
	distance_label.add_theme_font_size_override("font_size", 10)
	distance_label.modulate = Color.WHITE
	landing_arrow.add_child(distance_label)
	
	# Start invisible, will show when player moves away from landing zone
	landing_arrow.visible = false

func _process(delta):
	update_landing_arrow()

func update_landing_arrow():
	if not player or not landing_arrow:
		return
	
	# Calculate distance from player to landing zone
	var player_pos = player.global_position
	var distance_to_landing = abs(player_pos.x - ground_position.x)
	
	# Show arrow if player is more than 200 units away from landing zone horizontally
	if distance_to_landing > 200:
		landing_arrow.visible = true
		
		# Calculate direction to landing zone
		var direction = 1 if ground_position.x > player_pos.x else -1
		
		# Position arrow on edge of screen pointing toward landing zone
		var arrow_x = 50 if direction > 0 else 260
		landing_arrow.position.x = arrow_x
		
		# Update arrow direction using consistent triangle arrows
		var arrow_label = landing_arrow.get_child(0)
		if direction > 0:
			arrow_label.text = ">"  # Right arrow
		else:
			arrow_label.text = "<"  # Left arrow
		
		# Update distance text
		var distance_label = landing_arrow.get_node("DistanceLabel")
		var distance_text = "LANDING ZONE\n%.0f units" % distance_to_landing
		distance_label.text = distance_text
		
		# Pulse animation for attention
		var pulse_scale = 1.0 + sin(Time.get_time_dict_from_system()["second"] * 3.0) * 0.2
		landing_arrow.scale = Vector2(pulse_scale, pulse_scale)
		
	else:
		landing_arrow.visible = false
