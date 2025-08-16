extends Control

@onready var milo_credit = $CreditsContainer/MiloCredit
@onready var alan_credit = $CreditsContainer/AlanCredit

func _ready():
	$VBoxContainer/RetryButton.grab_focus()
	
	# Load and display the game results
	display_results()
	
	# Connect clickable credits
	if milo_credit:
		milo_credit.meta_clicked.connect(_on_credit_link_clicked)
	if alan_credit:
		alan_credit.meta_clicked.connect(_on_credit_link_clicked)

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

func _on_credit_link_clicked(meta):
	# Open the URL in default browser
	OS.shell_open(str(meta))

func display_results():
	print("GameOver: Displaying results - Score: ", GameData.final_score, " Time: ", GameData.final_time)
	$VBoxContainer/ScoreLabel.text = "Score: " + str(GameData.final_score)
	$VBoxContainer/TimeLabel.text = "Time: " + format_time(GameData.final_time)
