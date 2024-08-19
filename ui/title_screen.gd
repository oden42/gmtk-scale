extends Control

@onready var start_button: Button = %StartButton
@onready var exit_button: Button = %ExitButton

@onready var credits_panel: PanelContainer = %CreditsPanel


func _on_start_button_button_up() -> void:
	get_tree().change_scene_to_file("res://level/level.tscn")
	GameManager.reset_game()


func _on_credits_button_button_up() -> void:
	credits_panel.visible = true
	await get_tree().create_timer(5).timeout
	credits_panel.visible = false


func _on_close_credits_button_button_down() -> void:
	credits_panel.visible = false
