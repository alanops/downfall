extends Node

@onready var recording_label = null
var is_recording = false
var recording_timer = 0.0
var recording_duration = 5.0  # 5 seconds
var frames_captured = []
var capture_interval = 1.0 / 15.0  # 15 FPS for GIF
var last_capture_time = 0.0
var recording_start_time = 0.0

# For storing captured frames
var viewport_texture: ViewportTexture
var gif_frames: Array = []

signal recording_started()
signal recording_finished(gif_path: String)

func _ready():
	# Create recording indicator label
	create_recording_ui()
	print("GIF Recorder initialized")

func create_recording_ui():
	# Create a label to show recording status
	recording_label = Label.new()
	recording_label.text = ""
	recording_label.position = Vector2(10, 130)  # Below altimeter
	recording_label.size = Vector2(200, 30)
	recording_label.add_theme_color_override("font_color", Color.RED)
	recording_label.add_theme_font_size_override("font_size", 16)
	recording_label.visible = false
	
	# Add to HUD canvas layer
	var hud = get_node_or_null("../HUD")
	if hud:
		hud.add_child(recording_label)
		print("Recording UI added to HUD")
	else:
		print("Warning: Could not find HUD node for recording UI")

func _input(event):
	# Handle GIF recording hotkey (F12)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			if not is_recording:
				start_recording()
			else:
				stop_recording()

func _process(delta):
	if is_recording:
		recording_timer += delta
		
		# Update recording UI
		var remaining_time = recording_duration - recording_timer
		if recording_label:
			recording_label.text = "🎬 Recording: %.1fs" % remaining_time
		
		# Capture frame at intervals
		if Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60 - last_capture_time >= capture_interval:
			capture_frame()
			last_capture_time = Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60
		
		# Stop recording after duration
		if recording_timer >= recording_duration:
			stop_recording()

func start_recording():
	if is_recording:
		return
		
	print("Starting GIF recording...")
	is_recording = true
	recording_timer = 0.0
	gif_frames.clear()
	recording_start_time = Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60
	last_capture_time = recording_start_time
	
	# Show recording UI
	if recording_label:
		recording_label.visible = true
	
	emit_signal("recording_started")

func stop_recording():
	if not is_recording:
		return
		
	print("Stopping GIF recording...")
	is_recording = false
	
	# Hide recording UI
	if recording_label:
		recording_label.visible = false
	
	# Save GIF
	save_gif()

func capture_frame():
	# Get the current viewport
	var viewport = get_viewport()
	if not viewport:
		print("Warning: Could not get viewport for frame capture")
		return
	
	# Get the texture from viewport
	var img = viewport.get_texture().get_image()
	if img:
		gif_frames.append(img)
		print("Frame captured: ", gif_frames.size())

func save_gif():
	if gif_frames.size() == 0:
		print("No frames captured for GIF")
		return
	
	# Show share dialog
	show_share_dialog()

func create_ffmpeg_script(frames_dir: String, gif_path: String, timestamp: String):
	# Create conversion scripts for different platforms
	var absolute_frames_dir = ProjectSettings.globalize_path(frames_dir)
	var absolute_gif_path = ProjectSettings.globalize_path("user://gifs/sky_drop_%s.gif" % timestamp)
	
	# Windows batch file
	var bat_content = """@echo off
echo Converting frames to GIF...
ffmpeg -r 15 -i "%s/frame_%%03d.png" -vf "palettegen" "%s/palette.png"
ffmpeg -r 15 -i "%s/frame_%%03d.png" -i "%s/palette.png" -filter_complex "paletteuse" "%s"
echo GIF created: %s
pause
""" % [absolute_frames_dir, absolute_frames_dir, absolute_frames_dir, absolute_frames_dir, absolute_gif_path, absolute_gif_path]
	
	var bat_file = FileAccess.open("user://gifs/create_gif_%s.bat" % timestamp, FileAccess.WRITE)
	if bat_file:
		bat_file.store_string(bat_content)
		bat_file.close()
	
	# Linux/Mac shell script
	var sh_content = """#!/bin/bash
echo "Converting frames to GIF..."
ffmpeg -r 15 -i "%s/frame_%%03d.png" -vf "palettegen" "%s/palette.png"
ffmpeg -r 15 -i "%s/frame_%%03d.png" -i "%s/palette.png" -filter_complex "paletteuse" "%s"
echo "GIF created: %s"
""" % [absolute_frames_dir, absolute_frames_dir, absolute_frames_dir, absolute_frames_dir, absolute_gif_path, absolute_gif_path]
	
	var sh_file = FileAccess.open("user://gifs/create_gif_%s.sh" % timestamp, FileAccess.WRITE)
	if sh_file:
		sh_file.store_string(sh_content)
		sh_file.close()

func show_share_dialog():
	# Create share dialog
	var dialog = preload("res://scenes/ShareDialog.tscn").instantiate()
	dialog.set_gif_frames(gif_frames)
	dialog.share_requested.connect(_on_share_requested)
	dialog.save_locally_requested.connect(_on_save_locally_requested)
	
	# Add to scene
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()

func _on_share_requested():
	# Get GIF sharer
	var gif_sharer = get_node_or_null("../GifSharer")
	if gif_sharer:
		gif_sharer.upload_started.connect(_on_upload_started)
		gif_sharer.upload_completed.connect(_on_upload_completed)
		gif_sharer.upload_failed.connect(_on_upload_failed)
		
		if not gif_sharer.share_gif(gif_frames):
			show_error_notification("Failed to start upload")
	else:
		show_error_notification("GIF Sharer not found!")

func _on_save_locally_requested():
	# Original local save functionality
	save_frames_locally()

func save_frames_locally():
	# Create timestamp for filename
	var time_dict = Time.get_datetime_dict_from_system()
	var timestamp = "%04d%02d%02d_%02d%02d%02d" % [
		time_dict.year, time_dict.month, time_dict.day,
		time_dict.hour, time_dict.minute, time_dict.second
	]
	
	# Create output directory if it doesn't exist
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("gifs"):
		dir.make_dir("gifs")
	
	var gif_path = "user://gifs/sky_drop_%s.gif" % timestamp
	
	# Since Godot doesn't have built-in GIF encoding, we'll save as a series of PNG files
	# and provide instructions for creating a GIF
	var frames_dir = "user://gifs/sky_drop_%s_frames" % timestamp
	dir.make_dir(frames_dir)
	
	# Save individual frames
	for i in range(gif_frames.size()):
		var frame_path = "%s/frame_%03d.png" % [frames_dir, i]
		gif_frames[i].save_png(frame_path)
	
	# Create a batch file for ffmpeg conversion
	create_ffmpeg_script(frames_dir, gif_path, timestamp)
	
	print("GIF frames saved to: ", frames_dir)
	print("Captured ", gif_frames.size(), " frames over ", recording_duration, " seconds")
	
	# Show notification to player
	show_local_save_notification(timestamp)
	
	emit_signal("recording_finished", gif_path)

func show_local_save_notification(timestamp: String):
	# Create a temporary notification
	var notification = Label.new()
	notification.text = "🎬 Recording saved! Check user://gifs/ folder\nUse create_gif_%s script to convert to GIF" % timestamp
	notification.position = Vector2(10, 160)
	notification.size = Vector2(350, 60)
	notification.add_theme_color_override("font_color", Color.GREEN)
	notification.add_theme_font_size_override("font_size", 14)
	notification.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Add to HUD
	var hud = get_node_or_null("../HUD")
	if hud:
		hud.add_child(notification)
		
		# Remove notification after 5 seconds
		var tween = create_tween()
		tween.tween_delay(5.0)
		tween.tween_callback(notification.queue_free)

func _on_upload_started():
	show_upload_notification("Uploading GIF to Imgur...", Color.YELLOW)

func _on_upload_completed(share_url: String):
	show_share_success_notification(share_url)

func _on_upload_failed(error: String):
	show_error_notification("Upload failed: " + error)

func show_upload_notification(text: String, color: Color):
	var notification = Label.new()
	notification.text = "🌐 " + text
	notification.position = Vector2(10, 160)
	notification.size = Vector2(350, 40)
	notification.add_theme_color_override("font_color", color)
	notification.add_theme_font_size_override("font_size", 16)
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Add to HUD
	var hud = get_node_or_null("../HUD")
	if hud:
		hud.add_child(notification)
		notification.name = "UploadNotification"

func show_share_success_notification(url: String):
	# Remove any existing upload notification
	var hud = get_node_or_null("../HUD")
	if hud:
		var old_notification = hud.get_node_or_null("UploadNotification")
		if old_notification:
			old_notification.queue_free()
	
	# Create success notification
	var notification = RichTextLabel.new()
	notification.bbcode_enabled = true
	notification.text = "[center][color=lime]✅ GIF Uploaded Successfully![/color][/center]\n[center][url]%s[/url][/center]\n[center][color=gray](Link copied to clipboard)[/color][/center]" % url
	notification.fit_content = true
	notification.position = Vector2(30, 200)
	notification.size = Vector2(300, 100)
	notification.add_theme_font_size_override("normal_font_size", 14)
	
	if hud:
		hud.add_child(notification)
		
		# Auto-remove after 7 seconds
		var tween = create_tween()
		tween.tween_delay(7.0)
		tween.tween_callback(notification.queue_free)

func show_error_notification(error: String):
	# Remove any existing upload notification
	var hud = get_node_or_null("../HUD")
	if hud:
		var old_notification = hud.get_node_or_null("UploadNotification")
		if old_notification:
			old_notification.queue_free()
	
	# Create error notification
	var notification = Label.new()
	notification.text = "❌ " + error
	notification.position = Vector2(10, 160)
	notification.size = Vector2(350, 60)
	notification.add_theme_color_override("font_color", Color.RED)
	notification.add_theme_font_size_override("font_size", 14)
	notification.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	if hud:
		hud.add_child(notification)
		
		# Remove after 5 seconds
		var tween = create_tween()
		tween.tween_delay(5.0)
		tween.tween_callback(notification.queue_free)

# Console command integration
func trigger_recording():
	if not is_recording:
		start_recording()
		return "GIF recording started (5 seconds)"
	else:
		return "Already recording... %.1fs remaining" % (recording_duration - recording_timer)

func get_recording_info():
	if is_recording:
		return "Recording in progress: %.1fs / %.1fs" % [recording_timer, recording_duration]
	else:
		return "Not currently recording. Press F12 or use 'gif' command to start."