extends Control

func _ready():
	$VBoxContainer/RetryButton.grab_focus()

func _input(event):
	if Input.is_action_just_pressed("reset_game"):
		_on_retry_button_pressed()

func set_score_info(score, time, lives):
	$VBoxContainer/ScoreLabel.text = "Score: " + str(score)
	$VBoxContainer/TimeLabel.text = "Time: " + format_time(time)

func format_time(seconds):
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millisecs = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millisecs]

func _on_retry_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")