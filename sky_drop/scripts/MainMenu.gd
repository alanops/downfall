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
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_credit_link_clicked(meta):
	# Open the URL in default browser
	OS.shell_open(str(meta))