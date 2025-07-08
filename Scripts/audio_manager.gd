extends Node

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func _ready() -> void:
	# Start background music
	bgm_player.stream = preload("res://AssetBundle/Audio/BGM.ogg")
	bgm_player.volume_db = -10  # Lower volume for background music
	bgm_player.play()

func play_sound(sound_stream: AudioStream, volume: float = 0.0) -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sound_stream
	audio_player.volume_db = volume
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())