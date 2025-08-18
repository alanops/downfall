extends Control

@onready var milo_credit = $CreditsContainer/MiloCredit
@onready var alan_credit = $CreditsContainer/AlanCredit

func _ready():
	$VBoxContainer/StartButton.grab_focus()
	
	# Connect clickable credits
	if milo_credit:
		milo_credit.meta_clicked.connect(_on_credit_link_clicked)
	if alan_credit:
		alan_credit.meta_clicked.connect(_on_credit_link_clicked)

func _input(event):
	if Input.is_action_just_pressed("reset_game"):
		_on_start_button_pressed()

func _on_start_button_pressed():
	# Enable audio for web browsers on first interaction
	AudioManager.enable_audio()
	# Play menu click sound (using test sound as menu click)
	AudioManager.play_sound("start", -10.0)  # Play button sound
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_button_pressed():
	AudioManager.play_sound("button", -10.0)  # Play button sound
	get_tree().quit()

func _on_credit_link_clicked(meta):
	# Open the URL in default browser
	OS.shell_open(str(meta))
