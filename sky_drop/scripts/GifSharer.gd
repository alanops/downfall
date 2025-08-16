extends Node

# Imgur API configuration
const IMGUR_CLIENT_ID = "YOUR_CLIENT_ID_HERE"  # Replace with actual client ID
const IMGUR_API_URL = "https://api.imgur.com/3/image"
const MAX_DAILY_UPLOADS = 50

# Upload state
var is_uploading = false
var upload_queue = []
var current_http_request: HTTPRequest = null

# Rate limiting
var daily_upload_count = 0
var last_upload_date = ""

# Signals
signal upload_started()
signal upload_completed(share_url: String)
signal upload_failed(error: String)

func _ready():
	load_upload_stats()

func load_upload_stats():
	var config = ConfigFile.new()
	if config.load("user://sharing_stats.cfg") == OK:
		daily_upload_count = config.get_value("stats", "daily_count", 0)
		last_upload_date = config.get_value("stats", "last_date", "")
		
		# Reset count if new day
		var current_date = Time.get_date_string_from_system()
		if current_date != last_upload_date:
			daily_upload_count = 0
			last_upload_date = current_date
			save_upload_stats()

func save_upload_stats():
	var config = ConfigFile.new()
	config.set_value("stats", "daily_count", daily_upload_count)
	config.set_value("stats", "last_date", last_upload_date)
	config.save("user://sharing_stats.cfg")

func can_upload() -> bool:
	return daily_upload_count < MAX_DAILY_UPLOADS

func get_remaining_uploads() -> int:
	return MAX_DAILY_UPLOADS - daily_upload_count

func share_gif(frames: Array) -> bool:
	if not can_upload():
		emit_signal("upload_failed", "Daily upload limit reached (%d/%d)" % [daily_upload_count, MAX_DAILY_UPLOADS])
		return false
	
	if is_uploading:
		emit_signal("upload_failed", "Another upload is in progress")
		return false
	
	# Convert frames to GIF data
	var gif_data = create_gif_from_frames(frames)
	if gif_data.size() == 0:
		emit_signal("upload_failed", "Failed to create GIF data")
		return false
	
	# Start upload
	start_upload(gif_data)
	return true

func create_gif_from_frames(frames: Array) -> PackedByteArray:
	# For now, we'll create a single frame PNG as proof of concept
	# In production, you'd use a proper GIF encoder library
	
	if frames.size() == 0:
		return PackedByteArray()
	
	# Use the middle frame as representative image
	var middle_frame_index = frames.size() / 2
	var representative_frame = frames[middle_frame_index]
	
	if representative_frame is Image:
		# Convert to PNG for now (Imgur accepts PNG and will display it)
		return representative_frame.save_png_to_buffer()
	
	return PackedByteArray()

func start_upload(image_data: PackedByteArray):
	is_uploading = true
	emit_signal("upload_started")
	
	# Create HTTP request
	current_http_request = HTTPRequest.new()
	add_child(current_http_request)
	current_http_request.request_completed.connect(_on_upload_complete)
	
	# Prepare headers
	var headers = [
		"Authorization: Client-ID " + IMGUR_CLIENT_ID,
	]
	
	# Convert image to base64
	var base64_data = Marshalls.raw_to_base64(image_data)
	
	# Create form data
	var body = "image=" + base64_data + "&type=base64&title=Sky Drop Epic Moment"
	
	# Send request
	var error = current_http_request.request(
		IMGUR_API_URL,
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	
	if error != OK:
		is_uploading = false
		emit_signal("upload_failed", "Failed to start upload request")
		current_http_request.queue_free()
		current_http_request = null

func _on_upload_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	is_uploading = false
	
	# Clean up HTTP request
	if current_http_request:
		current_http_request.queue_free()
		current_http_request = null
	
	# Check response
	if response_code != 200:
		emit_signal("upload_failed", "Upload failed with code: " + str(response_code))
		return
	
	# Parse JSON response
	var json_string = body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		emit_signal("upload_failed", "Failed to parse server response")
		return
	
	var response_data = json.data
	if response_data.has("data") and response_data["data"].has("link"):
		var share_link = response_data["data"]["link"]
		
		# Update upload count
		daily_upload_count += 1
		save_upload_stats()
		
		# Copy to clipboard
		OS.set_clipboard(share_link)
		
		emit_signal("upload_completed", share_link)
	else:
		emit_signal("upload_failed", "Invalid response from server")

func create_share_message(url: String) -> String:
	return "Check out my epic Sky Drop moment! 🪂 " + url + " #SkyDropGame"