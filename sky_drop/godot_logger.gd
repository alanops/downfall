extends Node

var log_file_path = "user://game_log.txt"
var log_file: FileAccess

func _ready():
	# Set as autoload singleton
	set_process(true)
	
	# Open log file
	log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
	
	# Connect to tree signals
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)
	
	# Log startup
	log_message("Game started")
	
	# Print the actual log file path for monitoring
	var actual_path = OS.get_user_data_dir() + "/game_log.txt"
	print("Log file location: " + actual_path)
	log_message("Log file: " + actual_path)

func log_message(message: String):
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] %s" % [timestamp, message]
	
	# Print to console
	print(log_entry)
	
	# Write to file
	if log_file:
		log_file.store_line(log_entry)
		log_file.flush()

func _on_node_added(node: Node):
	log_message("Node added: " + node.get_path())

func _on_node_removed(node: Node):
	log_message("Node removed: " + node.get_path())

func _exit_tree():
	log_message("Game closing")
	if log_file:
		log_file.close()

# Custom logging functions for game events
func log_game_event(event_name: String, details: Dictionary = {}):
	var message = "GAME_EVENT: " + event_name
	if details.size() > 0:
		message += " | " + str(details)
	log_message(message)

func log_error(error_message: String):
	log_message("ERROR: " + error_message)
	push_error(error_message)

func log_warning(warning_message: String):
	log_message("WARNING: " + warning_message)
	push_warning(warning_message)