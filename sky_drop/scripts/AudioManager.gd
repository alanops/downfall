extends Node

# Audio buses
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

# Sound effect preloads
var sounds = {
	# Player sounds
	"test": preload("res://assets/sounds/player/test.ogg"),
	"parachute_deploy": preload("res://assets/sounds/parachute_open.wav"),
	"player_hit": preload("res://assets/sounds/damage.ogg"),
	"coin_collect": preload("res://assets/sounds/coin_collect.wav"),
	
	# Environment sounds
	"wind_rushing": preload("res://assets/sounds/wind_heavy.ogg"),
	"wind_gentle": preload("res://assets/sounds/wind_light.ogg"),
	
	# UI sounds
	"game_over": preload("res://assets/sounds/game_over.ogg"),
	"start": preload("res://assets/sounds/start.wav"),
	"button": preload("res://assets/sounds/button.ogg"),
	
	# Music tracks
	"music_1": preload("res://assets/sounds/music_1.ogg"),
	"music_2": preload("res://assets/sounds/music 2.ogg"),
	"music_3": preload("res://assets/sounds/music 3.ogg"),
}

# Audio stream players pool
var sfx_players = []
var music_player: AudioStreamPlayer

# Settings
var master_volume = 1.0
var music_volume = 1.0
var sfx_volume = 1.0

# Web audio state
var audio_enabled = false
var first_user_interaction = false

func _ready():
	# Set up audio buses first
	setup_audio_buses()
	
	# Create audio stream players pool for sound effects
	for i in range(10):  # Pool of 10 players for concurrent sounds
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		sfx_players.append(player)
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	
	# Enable audio after first user interaction on web
	if OS.has_feature("web"):
		get_viewport().gui_input.connect(_on_first_input)
	else:
		audio_enabled = true

func setup_audio_buses():
	# Check if buses exist, create if not
	var master_idx = AudioServer.get_bus_index(MASTER_BUS)
	if master_idx == -1:
		print("Warning: Master bus not found")
		
	var music_idx = AudioServer.get_bus_index(MUSIC_BUS)
	if music_idx == -1:
		# Create Music bus
		AudioServer.add_bus()
		var new_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_idx, MUSIC_BUS)
		AudioServer.set_bus_send(new_idx, MASTER_BUS)
		
	var sfx_idx = AudioServer.get_bus_index(SFX_BUS)
	if sfx_idx == -1:
		# Create SFX bus
		AudioServer.add_bus()
		var new_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_idx, SFX_BUS)
		AudioServer.set_bus_send(new_idx, MASTER_BUS)

func play_sound(sound_name: String, volume_db: float = 0.0, pitch: float = 1.0):
	if not audio_enabled:
		return
		
	if not sounds.has(sound_name):
		print("Sound not found: " + sound_name)
		return
		
	# Find an available player
	for player in sfx_players:
		if not player.playing:
			player.stream = sounds[sound_name]
			player.volume_db = volume_db
			player.pitch_scale = pitch
			player.play()
			return
			
	# All players busy, use the first one (will cut off existing sound)
	print("All audio players busy, cutting off sound")
	sfx_players[0].stream = sounds[sound_name]
	sfx_players[0].volume_db = volume_db
	sfx_players[0].pitch_scale = pitch
	sfx_players[0].play()

func play_sound_at_position(sound_name: String, pos: Vector2, volume_db: float = 0.0):
	# For 2D positional audio - implement if needed
	# For now, just play normally
	play_sound(sound_name, volume_db)

func stop_all_sounds():
	for player in sfx_players:
		if player.playing:
			player.stop()

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	var db = linear_to_db(master_volume) if master_volume > 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS), db)

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	var db = linear_to_db(music_volume) if music_volume > 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), db)

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	var db = linear_to_db(sfx_volume) if sfx_volume > 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), db)

# Music playback functions
func play_music(music_name: String, volume_db: float = -10.0, loop: bool = true):
	if not audio_enabled:
		return
		
	if not sounds.has(music_name):
		print("Music not found: " + music_name)
		return
		
	var audio_stream = sounds[music_name]
	# Create a copy for web compatibility
	if OS.has_feature("web") and audio_stream is AudioStreamOggVorbis:
		var stream_copy = audio_stream.duplicate()
		stream_copy.loop = loop
		music_player.stream = stream_copy
	else:
		music_player.stream = audio_stream
		if music_player.stream:
			music_player.stream.loop = loop
	
	music_player.volume_db = volume_db
	music_player.play()

func stop_music():
	if music_player.playing:
		music_player.stop()

func fade_out_music(duration: float = 1.0):
	if not music_player.playing:
		return
		
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, duration)
	tween.tween_callback(stop_music)

# Looping sound effects (for wind)
var looping_sounds = {}

func play_looping_sound(sound_name: String, player_id: String = "default", volume_db: float = -5.0):
	if not audio_enabled:
		return
		
	if not sounds.has(sound_name):
		print("Sound not found: " + sound_name)
		return
		
	# Stop existing loop if any
	stop_looping_sound(player_id)
	
	# Find available player
	for player in sfx_players:
		if not player.playing:
			var audio_stream = sounds[sound_name]
			# Create a copy for web compatibility
			if OS.has_feature("web") and audio_stream is AudioStreamOggVorbis:
				var stream_copy = audio_stream.duplicate()
				stream_copy.loop = true
				player.stream = stream_copy
			else:
				player.stream = audio_stream
				if player.stream:
					player.stream.loop = true
			
			player.volume_db = volume_db
			player.play()
			looping_sounds[player_id] = player
			return

func stop_looping_sound(player_id: String = "default"):
	if looping_sounds.has(player_id):
		var player = looping_sounds[player_id]
		if player and player.playing:
			if player.stream:
				player.stream.loop = false
			player.stop()
		looping_sounds.erase(player_id)

# Handle first user interaction for web audio
func _on_first_input(event):
	if not first_user_interaction and (event is InputEventMouseButton or event is InputEventKey):
		if event.pressed:
			first_user_interaction = true
			audio_enabled = true
			print("Audio enabled after user interaction")
			get_viewport().gui_input.disconnect(_on_first_input)

# Public function to enable audio (call on first button press)
func enable_audio():
	if not audio_enabled:
		audio_enabled = true
		first_user_interaction = true
		print("Audio manually enabled")
