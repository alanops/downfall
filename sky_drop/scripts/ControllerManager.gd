extends Node

# Controller detection and management
var is_is_controller_connected = false
var controller_device_id = -1
var controller_name = ""
var deadzone = 0.2

# Vibration settings
var vibration_enabled = true
var vibration_strength = 0.5

# Controller layout detection
enum ControllerType {
	UNKNOWN,
	XBOX,
	PLAYSTATION,
	NINTENDO,
	GENERIC
}
var controller_type = ControllerType.UNKNOWN

signal controller_connected(device_id: int, controller_name: String)
signal controller_disconnected(device_id: int)

func _ready():
	# Connect to input device signals
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	# Check for already connected controllers
	check_connected_controllers()

func check_connected_controllers():
	var connected_joypads = Input.get_connected_joypads()
	if connected_joypads.size() > 0:
		controller_device_id = connected_joypads[0]
		is_controller_connected = true
		controller_name = Input.get_joy_name(controller_device_id)
		controller_type = detect_controller_type(controller_name)
		print("Controller detected: ", controller_name, " (", get_controller_type_name(), ")")
		emit_signal("controller_connected", controller_device_id, controller_name)
	else:
		is_controller_connected = false
		controller_device_id = -1
		print("No controller detected")

func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		is_controller_connected = true
		controller_device_id = device_id
		controller_name = Input.get_joy_name(device_id)
		controller_type = detect_controller_type(controller_name)
		print("Controller connected: ", controller_name, " (", get_controller_type_name(), ")")
		emit_signal("controller_connected", device_id, controller_name)
		
		# Show notification
		show_controller_notification(true)
	else:
		if device_id == controller_device_id:
			is_controller_connected = false
			controller_device_id = -1
			controller_name = ""
			controller_type = ControllerType.UNKNOWN
			print("Controller disconnected")
			emit_signal("controller_disconnected", device_id)
			
			# Show notification
			show_controller_notification(false)

func detect_controller_type(name: String) -> ControllerType:
	var lower_name = name.to_lower()
	
	if "xbox" in lower_name or "microsoft" in lower_name:
		return ControllerType.XBOX
	elif "playstation" in lower_name or "ps4" in lower_name or "ps5" in lower_name or "dualshock" in lower_name or "dualsense" in lower_name:
		return ControllerType.PLAYSTATION
	elif "nintendo" in lower_name or "switch" in lower_name or "joy-con" in lower_name:
		return ControllerType.NINTENDO
	else:
		return ControllerType.GENERIC

func get_controller_type_name() -> String:
	match controller_type:
		ControllerType.XBOX:
			return "Xbox Controller"
		ControllerType.PLAYSTATION:
			return "PlayStation Controller"
		ControllerType.NINTENDO:
			return "Nintendo Controller"
		ControllerType.GENERIC:
			return "Generic Controller"
		_:
			return "Unknown Controller"

func get_button_prompt(action: String) -> String:
	if not is_controller_connected:
		return ""
	
	# Get input events for the action
	var events = InputMap.action_get_events(action)
	
	for event in events:
		if event is InputEventJoypadButton:
			return get_button_name(event.button_index)
		elif event is InputEventJoypadMotion:
			return get_axis_name(event.axis, event.axis_value)
	
	return ""

func get_button_name(button_index: int) -> String:
	match controller_type:
		ControllerType.XBOX:
			return get_xbox_button_name(button_index)
		ControllerType.PLAYSTATION:
			return get_playstation_button_name(button_index)
		ControllerType.NINTENDO:
			return get_nintendo_button_name(button_index)
		_:
			return get_generic_button_name(button_index)

func get_xbox_button_name(button_index: int) -> String:
	match button_index:
		0: return "A"
		1: return "B"
		2: return "X"
		3: return "Y"
		4: return "LB"
		5: return "RB"
		6: return "Back"
		7: return "Start"
		8: return "L3"
		9: return "R3"
		10: return "Guide"
		11: return "D-Up"
		12: return "D-Down"
		13: return "D-Left"
		14: return "D-Right"
		_: return "Button " + str(button_index)

func get_playstation_button_name(button_index: int) -> String:
	match button_index:
		0: return "×"  # Cross
		1: return "○"  # Circle
		2: return "□"  # Square
		3: return "△"  # Triangle
		4: return "L1"
		5: return "R1"
		6: return "Share"
		7: return "Options"
		8: return "L3"
		9: return "R3"
		10: return "PS"
		11: return "D-Up"
		12: return "D-Down"
		13: return "D-Left"
		14: return "D-Right"
		_: return "Button " + str(button_index)

func get_nintendo_button_name(button_index: int) -> String:
	match button_index:
		0: return "B"
		1: return "A"
		2: return "Y"
		3: return "X"
		4: return "L"
		5: return "R"
		6: return "-"
		7: return "+"
		8: return "L-Stick"
		9: return "R-Stick"
		10: return "Home"
		11: return "D-Up"
		12: return "D-Down"
		13: return "D-Left"
		14: return "D-Right"
		_: return "Button " + str(button_index)

func get_generic_button_name(button_index: int) -> String:
	match button_index:
		0: return "Button 1"
		1: return "Button 2"
		2: return "Button 3"
		3: return "Button 4"
		4: return "L1"
		5: return "R1"
		6: return "Select"
		7: return "Start"
		8: return "L3"
		9: return "R3"
		10: return "Home"
		11: return "D-Up"
		12: return "D-Down"
		13: return "D-Left"
		14: return "D-Right"
		_: return "Button " + str(button_index)

func get_axis_name(axis: int, value: float) -> String:
	var direction = "+" if value > 0 else "-"
	match axis:
		0: return "L-Stick " + ("Right" if value > 0 else "Left")
		1: return "L-Stick " + ("Down" if value > 0 else "Up")
		2: return "R-Stick " + ("Right" if value > 0 else "Left")
		3: return "R-Stick " + ("Down" if value > 0 else "Up")
		4: return "LT"
		5: return "RT"
		_: return "Axis " + str(axis) + direction

func vibrate(duration: float, weak_magnitude: float = 0.5, strong_magnitude: float = 0.5):
	if not is_controller_connected or not vibration_enabled:
		return
	
	# Apply vibration strength setting
	weak_magnitude *= vibration_strength
	strong_magnitude *= vibration_strength
	
	# Start vibration
	Input.start_joy_vibration(controller_device_id, weak_magnitude, strong_magnitude, duration)

func stop_vibration():
	if is_controller_connected:
		Input.stop_joy_vibration(controller_device_id)

func show_controller_notification(connected: bool):
	var hud = get_node_or_null("/root/Main/HUD")
	if not hud:
		return
	
	var notification = Label.new()
	if connected:
		notification.text = "🎮 " + controller_name + " connected!"
		notification.add_theme_color_override("font_color", Color.GREEN)
	else:
		notification.text = "🎮 Controller disconnected"
		notification.add_theme_color_override("font_color", Color.RED)
	
	notification.position = Vector2(10, 250)
	notification.size = Vector2(340, 40)
	notification.add_theme_font_size_override("font_size", 16)
	
	hud.add_child(notification)
	
	# Auto-remove after 3 seconds
	var tween = create_tween()
	tween.tween_delay(3.0)
	tween.tween_callback(notification.queue_free)

# Analog stick input helpers
func get_left_stick_vector() -> Vector2:
	if not is_controller_connected:
		return Vector2.ZERO
	
	var x = Input.get_joy_axis(controller_device_id, 0)
	var y = Input.get_joy_axis(controller_device_id, 1)
	
	# Apply deadzone
	var vec = Vector2(x, y)
	if vec.length() < deadzone:
		return Vector2.ZERO
	
	return vec

func get_right_stick_vector() -> Vector2:
	if not is_controller_connected:
		return Vector2.ZERO
	
	var x = Input.get_joy_axis(controller_device_id, 2)
	var y = Input.get_joy_axis(controller_device_id, 3)
	
	# Apply deadzone
	var vec = Vector2(x, y)
	if vec.length() < deadzone:
		return Vector2.ZERO
	
	return vec

func get_trigger_value(left: bool) -> float:
	if not is_controller_connected:
		return 0.0
	
	var axis = 4 if left else 5
	var value = Input.get_joy_axis(controller_device_id, axis)
	
	# Normalize trigger value (some controllers report -1 to 1, others 0 to 1)
	return (value + 1.0) / 2.0
