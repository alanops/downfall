extends Control

@onready var vibration_toggle = $VBoxContainer/VibrationContainer/VibrationToggle
@onready var vibration_strength_slider = $VBoxContainer/VibrationStrengthContainer/StrengthSlider
@onready var deadzone_slider = $VBoxContainer/DeadzoneContainer/DeadzoneSlider
@onready var controller_status_label = $VBoxContainer/ControllerStatusLabel
@onready var test_vibration_button = $VBoxContainer/TestVibrationButton

func _ready():
	# Load settings
	vibration_toggle.button_pressed = ControllerManager.vibration_enabled
	vibration_strength_slider.value = ControllerManager.vibration_strength
	deadzone_slider.value = ControllerManager.deadzone
	
	# Connect signals
	vibration_toggle.toggled.connect(_on_vibration_toggled)
	vibration_strength_slider.value_changed.connect(_on_vibration_strength_changed)
	deadzone_slider.value_changed.connect(_on_deadzone_changed)
	test_vibration_button.pressed.connect(_on_test_vibration_pressed)
	
	# Connect to controller manager
	ControllerManager.controller_connected.connect(_on_controller_status_changed)
	ControllerManager.controller_disconnected.connect(_on_controller_status_changed)
	
	# Update initial status
	update_controller_status()

func _on_vibration_toggled(enabled: bool):
	ControllerManager.vibration_enabled = enabled
	vibration_strength_slider.editable = enabled
	test_vibration_button.disabled = not enabled or not ControllerManager.is_controller_connected

func _on_vibration_strength_changed(value: float):
	ControllerManager.vibration_strength = value

func _on_deadzone_changed(value: float):
	ControllerManager.deadzone = value

func _on_test_vibration_pressed():
	if ControllerManager.is_controller_connected:
		ControllerManager.vibrate(0.5, 0.5, 0.7)

func _on_controller_status_changed(_device_id):
	update_controller_status()

func update_controller_status():
	if ControllerManager.is_controller_connected:
		controller_status_label.text = "🎮 " + ControllerManager.controller_name + " connected"
		controller_status_label.modulate = Color.GREEN
		test_vibration_button.disabled = not ControllerManager.vibration_enabled
	else:
		controller_status_label.text = "🎮 No controller connected"
		controller_status_label.modulate = Color.RED
		test_vibration_button.disabled = true