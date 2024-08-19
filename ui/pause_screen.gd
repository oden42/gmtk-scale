extends Control



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and !GameManager.game_is_over:
		if visible:
			close_screen()
		else:
			show_screen()


func show_screen() -> void:
	visible = true
	GameManager.pause_game(true)


func close_screen() -> void:
	visible = false
	GameManager.pause_game(false)


func _on_resume_button_button_up() -> void:
	close_screen()


func _on_restart_button_button_up() -> void:
	get_tree().change_scene_to_file("res://level/level.tscn")
	GameManager.reset_game()


func _on_exit_button_button_up() -> void:
	get_tree().change_scene_to_file("res://ui/title_screen.tscn")
	GameManager.reset_game()
