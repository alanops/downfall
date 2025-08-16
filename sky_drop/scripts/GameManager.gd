extends Node

var score = 0
var time_elapsed = 0.0
var game_started = false
var game_over = false

# Coin collection and combo system
var coins_collected = 0
var current_combo = 0
var combo_timer = 0.0
var combo_timeout = 2.0  # Time between collections to maintain combo
var base_coin_value = 10

signal score_updated(new_score)
signal time_updated(time)
signal game_finished(final_time, lives_remaining)
signal combo_updated(combo_count, multiplier)
signal coin_collected_ui(coin_value, combo_multiplier)

func _ready():
	set_process(false)
	start_game()

func start_game():
	game_started = true
	game_over = false
	time_elapsed = 0.0
	score = 0
	coins_collected = 0
	current_combo = 0
	combo_timer = 0.0
	set_process(true)

func _process(delta):
	if not game_over and game_started:
		time_elapsed += delta
		emit_signal("time_updated", time_elapsed)
		
		# Update combo timer
		if current_combo > 0:
			combo_timer -= delta
			if combo_timer <= 0:
				reset_combo()
	
	# Check for reset key
	if Input.is_action_just_pressed("reset_game"):
		reset_game()

func end_game(lives_remaining):
	if game_over:
		return  # Already ended
		
	print("GameManager: Ending game with time: ", time_elapsed, " lives: ", lives_remaining)
	game_over = true
	set_process(false)
	
	# Calculate score based on time and lives
	var time_bonus = max(0, 10000 - int(time_elapsed * 100))
	var lives_bonus = lives_remaining * 1000
	score = time_bonus + lives_bonus
	
	emit_signal("score_updated", score)
	emit_signal("game_finished", time_elapsed, lives_remaining)
	
	# Store results in global data
	GameData.set_game_results(score, time_elapsed, lives_remaining)
	
	# Show game over screen after a short delay
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func format_time(seconds):
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millisecs = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millisecs]

func reset_game():
	get_tree().reload_current_scene()

func _on_ground_player_landed():
	var player = get_node_or_null("../Player")
	if player:
		end_game(player.lives)

# Coin collection system
func _on_coin_collected(coin, position):
	if game_over:
		return
		
	coins_collected += 1
	current_combo += 1
	combo_timer = combo_timeout
	
	# Calculate score with combo multiplier
	var combo_multiplier = get_combo_multiplier()
	var coin_value = base_coin_value * combo_multiplier
	score += coin_value
	
	emit_signal("score_updated", score)
	emit_signal("combo_updated", current_combo, combo_multiplier)
	emit_signal("coin_collected_ui", coin_value, combo_multiplier)
	
	print("Coin collected! Value: ", coin_value, " Combo: ", current_combo, "x", combo_multiplier)

func get_combo_multiplier():
	if current_combo <= 1:
		return 1
	elif current_combo <= 3:
		return 2
	elif current_combo <= 6:
		return 3
	elif current_combo <= 10:
		return 4
	else:
		return 5

func reset_combo():
	if current_combo > 0:
		print("Combo broken! Was at: ", current_combo)
		current_combo = 0
		emit_signal("combo_updated", current_combo, get_combo_multiplier())
