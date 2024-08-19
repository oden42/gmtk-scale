extends Node

signal score_changed(score: int)

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var game_is_paused: bool = false
var game_is_over: bool = false


func pause_game(paused: bool) -> void:
	if paused:
		game_is_paused = true
		print("Pause game")
		get_tree().paused = true
	else:
		game_is_paused = false
		print("Unpause game")
		get_tree().paused = false


func reset_game() -> void:
	score = 0
	game_is_paused = false
	game_is_over = false
	get_tree().paused = false
