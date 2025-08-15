extends Node

var score = 0
var time_elapsed = 0.0
var game_started = false
var game_over = false

signal score_updated(new_score)
signal time_updated(time)
signal game_finished(final_time, lives_remaining)

func _ready():
	set_process(false)
	start_game()

func start_game():
	game_started = true
	game_over = false
	time_elapsed = 0.0
	score = 0
	set_process(true)

func _process(delta):
	if not game_over and game_started:
		time_elapsed += delta
		emit_signal("time_updated", time_elapsed)
	
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