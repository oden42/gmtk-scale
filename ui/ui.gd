extends CanvasLayer

var time_elapsed: float = 0.0
var score: int = 0

@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)


func _process(delta):
	time_elapsed += delta
	time_label.text = set_time(time_elapsed, false)


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
