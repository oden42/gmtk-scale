extends Node

# NOTE used https://www.youtube.com/watch?v=t5LYFJ0bSx8

@export var start_count: int = 10
@export var audio_bus: StringName = "SFX"
@export var music_enabled: bool = true

var player_list: Array[SoundPlayer]

@onready var sfx_node: Node = $SFX
@onready var music_stream: AudioStreamPlayer2D = $MusicStream

func _ready() -> void:
	if music_enabled:
		music_stream.play()
	for i in start_count:
		create_player()

func create_player() -> void:
	var new_player := SoundPlayer.new()
	new_player.bus = audio_bus
	add_child(new_player)
	player_list.append(new_player)

func get_player() -> SoundPlayer:
	if player_list.is_empty():
		create_player()
	return player_list.pop_back()

func return_player(player: SoundPlayer, sound: SoundResource) -> void:
	sound.audio_stream_player = null
	player_list.append(player)

func play(sound: SoundResource) -> void:
	if sound.audio_stream_player != null:
		sound.play(sound.audio_stream_player)
		return
	var player := get_player()
	player.finished.connect(return_player.bind(player,sound), CONNECT_ONE_SHOT)
	sound.play(player)

func toggle_music(enabled: bool) -> void:
	if enabled:
		music_stream.play()
	else:
		music_stream.stop()

func toggle_mute(enabled: bool) -> void:
	var bus: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus, enabled)
