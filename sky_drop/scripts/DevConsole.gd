extends CanvasLayer

@onready var console_panel = $ConsolePanel
@onready var command_input = $ConsolePanel/VBoxContainer/InputContainer/CommandInput
@onready var output_text = $ConsolePanel/VBoxContainer/ScrollContainer/OutputText
@onready var sound_menu = $SoundMenu
@onready var master_slider = $SoundMenu/VBoxContainer/MasterVolumeContainer/MasterSlider
@onready var music_slider = $SoundMenu/VBoxContainer/MusicVolumeContainer/MusicSlider
@onready var sfx_slider = $SoundMenu/VBoxContainer/SFXVolumeContainer/SFXSlider
@onready var test_music_button = $SoundMenu/VBoxContainer/TestButtonsContainer/TestMusicButton
@onready var test_sfx_button = $SoundMenu/VBoxContainer/TestButtonsContainer/TestSFXButton

var is_console_open = false
var command_history = []
var history_index = -1

var game_manager
var player

func _ready():
	print("DevConsole _ready() called")
	# Start hidden
	visible = false
	is_console_open = false
	print("DevConsole set to visible: ", visible)
	
	# Get references to game objects
	game_manager = get_node_or_null("/root/Main/GameManager")
	player = get_node_or_null("/root/Main/Player")
	print("GameManager found: ", game_manager != null)
	print("Player found: ", player != null)
	
	# Connect command input
	if command_input:
		command_input.text_submitted.connect(_on_command_submitted)
	
	# Connect sound menu controls
	if master_slider:
		master_slider.value_changed.connect(_on_master_volume_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	if test_music_button:
		test_music_button.pressed.connect(_on_test_music_pressed)
	if test_sfx_button:
		test_sfx_button.pressed.connect(_on_test_sfx_pressed)
	
	print_to_console("Dev Console initialized. Type 'help' for commands.")

func _input(event):
	# Handle dev console toggle
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == 96 or event.keycode == KEY_F1:  # Backtick or F1
			print("Dev console toggle detected!")
			toggle_console()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and is_console_open:  # ESC to close console
			print("ESC pressed - closing console")
			toggle_console()
			get_viewport().set_input_as_handled()
	
	# Only process other input if console is open
	if not is_console_open:
		return
		
	if event.is_action_pressed("ui_accept") and event.shift_pressed:  # Shift+Enter
		toggle_sound_menu()
		get_viewport().set_input_as_handled()
	
	if is_console_open and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				navigate_history(-1)
			KEY_DOWN:
				navigate_history(1)

func toggle_console():
	is_console_open = !is_console_open
	visible = is_console_open
	print("Console toggled, visible: ", visible, " open: ", is_console_open)
	
	if is_console_open:
		if command_input:
			command_input.grab_focus()
			command_input.select_all()
		# Pause the game when console is open
		get_tree().paused = true
		print("Game paused, console open")
	else:
		# Unpause when console closes
		get_tree().paused = false
		if sound_menu:
			sound_menu.visible = false
		print("Game unpaused, console closed")

func toggle_sound_menu():
	if not is_console_open:
		toggle_console()
	if sound_menu:
		sound_menu.visible = !sound_menu.visible

func navigate_history(direction):
	if command_history.is_empty():
		return
		
	history_index += direction
	history_index = clamp(history_index, -1, command_history.size() - 1)
	
	if command_input:
		if history_index == -1:
			command_input.text = ""
		else:
			command_input.text = command_history[history_index]
		
		command_input.caret_column = command_input.text.length()

func _on_command_submitted(command: String):
	print("Command submitted: ", command)
	if command.strip_edges().is_empty():
		return
	
	# Add to history
	command_history.append(command)
	if command_history.size() > 50:  # Limit history size
		command_history.pop_front()
	history_index = -1
	
	# Display command
	print_to_console("> " + command)
	
	# Execute command
	execute_command(command.strip_edges())
	
	# Clear input
	if command_input:
		command_input.text = ""

func print_to_console(text: String):
	if output_text:
		output_text.text += text + "\n"
		# Auto-scroll to bottom
		var scroll_container = output_text.get_parent()
		if scroll_container is ScrollContainer:
			await get_tree().process_frame
			scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func execute_command(command: String):
	var parts = command.split(" ", false)
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	match cmd:
		"help":
			show_help()
		"clear":
			output_text.text = ""
		"godmode":
			toggle_godmode()
		"lives":
			set_lives(args)
		"teleport":
			teleport_player(args)
		"spawn":
			spawn_hazard(args)
		"speed":
			set_player_speed(args)
		"parachute":
			force_parachute_state(args)
		"score":
			set_score(args)
		"time":
			set_time(args)
		"gravity":
			set_gravity(args)
		"wind":
			set_wind(args)
		"soundtest":
			test_sounds(args)
		"music":
			control_music(args)
		"reset":
			reset_game()
		"fps":
			show_fps_info()
		"altitude":
			show_altitude_info()
		_:
			print_to_console("Unknown command: " + cmd + ". Type 'help' for available commands.")

func show_help():
	var help_text = """Available Commands:
	
Game Control:
- godmode - Toggle invincibility
- lives <number> - Set number of lives
- score <number> - Set current score
- time <seconds> - Set game time
- reset - Reset game to start
- teleport <x> <y> - Move player to position

Player Control:
- speed <multiplier> - Adjust player movement speed
- parachute <true/false> - Force parachute state
- gravity <multiplier> - Adjust gravity strength
- wind <x> <y> - Set wind force

Spawning:
- spawn plane - Spawn a plane hazard
- spawn cloud - Spawn a cloud
- spawn powerup - Spawn a power-up

Audio:
- soundtest <type> - Test sound effects
- music <play/stop/volume> - Control background music

Debug:
- fps - Show FPS and performance info
- altitude - Show current altitude and position info
- clear - Clear console output
- help - Show this help message

Controls:
- ESC - Toggle dev console
- Shift+Enter - Toggle sound menu
- Up/Down arrows - Navigate command history"""
	
	print_to_console(help_text)

func toggle_godmode():
	if player:
		var current = player.godmode_enabled
		player.set_godmode(!current)
		print_to_console("Godmode: " + ("ON" if !current else "OFF"))

func set_lives(args):
	if args.is_empty():
		print_to_console("Current lives: " + str(player.lives if player else "N/A"))
		return
	
	var new_lives = args[0].to_int()
	if player:
		player.lives = new_lives
		print_to_console("Lives set to: " + str(new_lives))

func teleport_player(args):
	if args.size() < 2:
		print_to_console("Usage: teleport <x> <y>")
		return
	
	var x = args[0].to_float()
	var y = args[1].to_float()
	
	if player:
		player.global_position = Vector2(x, y)
		print_to_console("Player teleported to: " + str(Vector2(x, y)))

func spawn_hazard(args):
	if args.is_empty():
		print_to_console("Usage: spawn <plane/cloud/powerup>")
		return
	
	var spawner = get_node("/root/Main/HazardSpawner")
	if not spawner:
		print_to_console("HazardSpawner not found")
		return
	
	match args[0].to_lower():
		"plane":
			spawner.spawn_hazard()
			print_to_console("Spawned plane hazard")
		"cloud":
			spawner.spawn_cloud()
			print_to_console("Spawned cloud")
		"powerup":
			spawner.spawn_powerup()
			print_to_console("Spawned power-up")
		_:
			print_to_console("Unknown spawn type: " + args[0])

func set_player_speed(args):
	if args.is_empty():
		print_to_console("Current speed multiplier: " + str(player.speed_multiplier if player else "N/A"))
		return
	
	var multiplier = args[0].to_float()
	if player:
		player.set_speed_multiplier(multiplier)
		print_to_console("Speed multiplier set to: " + str(multiplier))

func force_parachute_state(args):
	if args.is_empty():
		print_to_console("Current parachute state: " + str(player.parachute_deployed if player else "N/A"))
		return
	
	var state = args[0].to_lower() == "true"
	if player:
		player.parachute_deployed = state
		player.update_parachute_visibility()
		print_to_console("Parachute state set to: " + str(state))

func set_score(args):
	if args.is_empty():
		print_to_console("Current score: " + str(game_manager.score if game_manager else "N/A"))
		return
	
	var new_score = args[0].to_int()
	if game_manager:
		game_manager.score = new_score
		game_manager.emit_signal("score_updated", new_score)
		print_to_console("Score set to: " + str(new_score))

func set_time(args):
	if args.is_empty():
		print_to_console("Current time: " + str(game_manager.game_time if game_manager else "N/A"))
		return
	
	var new_time = args[0].to_float()
	if game_manager:
		game_manager.game_time = new_time
		print_to_console("Time set to: " + str(new_time))

func set_gravity(args):
	if args.is_empty():
		print_to_console("Current gravity multiplier: " + str(player.gravity_multiplier if player else "N/A"))
		return
	
	var multiplier = args[0].to_float()
	if player:
		player.set_gravity_multiplier(multiplier)
		print_to_console("Gravity multiplier set to: " + str(multiplier))

func set_wind(args):
	if args.is_empty():
		if player and player.has_wind_override:
			print_to_console("Current wind override: " + str(player.wind_override))
		else:
			print_to_console("No wind override active")
		return
	elif args.size() == 1 and args[0].to_lower() == "clear":
		if player:
			player.clear_wind_override()
			print_to_console("Wind override cleared")
		return
	elif args.size() < 2:
		print_to_console("Usage: wind <x> <y> or wind clear")
		return
	
	var wind_x = args[0].to_float()
	var wind_y = args[1].to_float()
	if player:
		player.set_wind_override(Vector2(wind_x, wind_y))
		print_to_console("Wind force set to: " + str(Vector2(wind_x, wind_y)))

func test_sounds(args):
	if args.is_empty():
		print_to_console("Usage: soundtest <parachute/hit/wind/powerup>")
		return
	
	# We'll implement this when we add audio
	print_to_console("Sound test for: " + args[0])

func control_music(args):
	if args.is_empty():
		print_to_console("Usage: music <play/stop/volume>")
		return
	
	# We'll implement this when we add audio
	print_to_console("Music control: " + args[0])

func reset_game():
	if game_manager:
		game_manager.reset_game()
		print_to_console("Game reset")

func show_fps_info():
	var fps = Engine.get_frames_per_second()
	var static_memory = OS.get_static_memory_usage()
	var process_id = OS.get_process_id()
	
	var info = "FPS: " + str(fps) + "\n"
	info += "Memory: " + str(static_memory / 1024 / 1024) + " MB\n"
	info += "Process ID: " + str(process_id)
	
	print_to_console(info)

func show_altitude_info():
	if player:
		var current_y = player.global_position.y
		var progress = (current_y - player.STARTING_Y_POSITION) / player.TOTAL_FALL_DISTANCE
		var altitude = player.current_altitude_feet
		
		var info = "=== ALTITUDE INFO ===\n"
		info += "Current Y Position: " + str(int(current_y)) + "\n"
		info += "Fall Progress: " + str(int(progress * 100)) + "%\n"
		info += "Altitude: " + str(altitude) + " ft\n"
		info += "Distance Fallen: " + str(int(player.STARTING_ALTITUDE_FEET - altitude)) + " ft\n"
		info += "Distance to Ground: " + str(altitude) + " ft"
		
		print_to_console(info)
	else:
		print_to_console("Player not found!")

# Sound Menu Callbacks
func _on_master_volume_changed(value: float):
	set_master_volume(value)
	print_to_console("Master volume: " + str(int(value * 100)) + "%")

func _on_music_volume_changed(value: float):
	set_music_volume(value)
	print_to_console("Music volume: " + str(int(value * 100)) + "%")

func _on_sfx_volume_changed(value: float):
	set_sfx_volume(value)
	print_to_console("SFX volume: " + str(int(value * 100)) + "%")

func _on_test_music_pressed():
	print_to_console("Testing background music...")
	# Will implement when we add audio system

func _on_test_sfx_pressed():
	print_to_console("Testing sound effects...")
	# Will implement when we add audio system

# Audio Control Functions
func set_master_volume(volume_percent: float):
	var db = linear_to_db(volume_percent) if volume_percent > 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func set_music_volume(volume_percent: float):
	var db = linear_to_db(volume_percent) if volume_percent > 0 else -80
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, db)

func set_sfx_volume(volume_percent: float):
	var db = linear_to_db(volume_percent) if volume_percent > 0 else -80
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, db)
