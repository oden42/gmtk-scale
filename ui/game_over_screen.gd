extends Control


@onready var replay_button: Button = %ReplayButton
@onready var score_amount_label: Label = %ScoreAmountLabel


func show_screen() -> void:
	score_amount_label.text = str(GameManager.score)
	visible = true

func _on_replay_button_button_up() -> void:
	get_tree().change_scene_to_file("res://level/level.tscn")
	GameManager.reset_game()
