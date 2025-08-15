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

func end_game(lives_remaining):
	game_over = true
	set_process(false)
	
	# Calculate score based on time and lives
	var time_bonus = max(0, 10000 - int(time_elapsed * 100))
	var lives_bonus = lives_remaining * 1000
	score = time_bonus + lives_bonus
	
	emit_signal("score_updated", score)
	emit_signal("game_finished", time_elapsed, lives_remaining)

func format_time(seconds):
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millisecs = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millisecs]