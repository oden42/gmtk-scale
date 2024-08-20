extends CanvasLayer

const AUDIO_OFF = preload("res://ui/icons/audioOff.png")
const AUDIO_ON = preload("res://ui/icons/audioOn.png")
const MUSIC_OFF = preload("res://ui/icons/musicOff.png")
const MUSIC_ON = preload("res://ui/icons/musicOn.png")

var time_elapsed: float = 0.0
var time_left: float = 90.0
var score: int = 0

@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var sound_icon: TextureRect = %SoundIcon
@onready var music_icon: TextureRect = %MusicIcon
@onready var sound_button: TextureButton = %SoundButton
@onready var music_button: TextureButton = %MusicButton

@onready var top_hud: Control = %"Top HUD"
@onready var volume_control: Control = %VolumeControl


@onready var game_over_screen: Control = $GameOverScreen


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	if !AudioManager.music_enabled:
		music_button.button_pressed = false
		music_icon.texture = MUSIC_OFF

func _process(delta):
	if GameManager.game_is_over or GameManager.game_is_paused:
		return
	time_elapsed += delta
	time_left -= delta
	#time_label.text = set_time(time_elapsed, false)
	time_label.text = set_time(time_left, false)
	
	if time_left <= 0:
		GameManager.pause_game(true)
		GameManager.game_is_over = true
		top_hud.visible = false
		game_over_screen.show_screen()
		print("Game Over")

func set_time(time: float, use_milliseconds: bool) -> String:
	# Found this here: https://gamedevbeginner.com/how-to-make-a-timer-in-godot-count-up-down-in-minutes-seconds/
	var minutes := time / 60
	# fmod is Modulo, or remainder for floats
	var seconds := fmod(time, 60)
	
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
		
	var milliseconds := fmod(time, 1) * 100
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]


func _on_score_changed(value: int) -> void:
	score_label.text = str(value)


func _on_sound_button_toggled(toggled_on: bool) -> void:
	#print("pressed ", toggled_on)
	if toggled_on:
		sound_icon.texture = AUDIO_ON
		AudioManager.toggle_mute(false)
	else:
		sound_icon.texture = AUDIO_OFF
		AudioManager.toggle_mute(true)


func _on_music_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		music_icon.texture = MUSIC_ON
		AudioManager.toggle_music(true)
	else:
		music_icon.texture = MUSIC_OFF
		AudioManager.toggle_music(false)
