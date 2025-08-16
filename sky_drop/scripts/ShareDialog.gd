extends AcceptDialog

var gif_data: Array = []
var gif_sharer: Node = null

signal share_requested()
signal save_locally_requested()

func _ready():
	# Add custom buttons
	add_button("Share Online 🌐", false, "share")
	add_button("Save Locally 💾", false, "save")
	get_ok_button().text = "Cancel"
	
	# Connect button signals
	custom_action.connect(_on_custom_action)
	
	# Get GIF sharer reference
	gif_sharer = get_node_or_null("/root/Main/GifSharer")
	
	# Update remaining uploads label
	if gif_sharer:
		var remaining = gif_sharer.get_remaining_uploads()
		$VBoxContainer/RemainingLabel.text = "Daily uploads remaining: %d/%d" % [remaining, gif_sharer.MAX_DAILY_UPLOADS]
		
		if remaining <= 0:
			$VBoxContainer/RemainingLabel.modulate = Color.RED
			# Disable share button
			for button in get_children():
				if button is Button and button.text.contains("Share Online"):
					button.disabled = true

func _on_custom_action(action: String):
	match action:
		"share":
			emit_signal("share_requested")
			hide()
		"save":
			emit_signal("save_locally_requested")
			hide()

func set_gif_frames(frames: Array):
	gif_data = frames
	
	# Update preview info
	if frames.size() > 0:
		$VBoxContainer/PreviewLabel.text = "🎬 %d frames captured (%.1f seconds)" % [frames.size(), frames.size() / 15.0]