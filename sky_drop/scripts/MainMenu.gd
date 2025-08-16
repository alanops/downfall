extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _input(event):
	if Input.is_action_just_pressed("reset_game"):
		_on_start_button_pressed()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
