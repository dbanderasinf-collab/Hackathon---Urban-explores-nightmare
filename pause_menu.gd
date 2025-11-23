extends Node2D


var game_over = false

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("escape") && !game_over :
		get_tree().paused = !get_tree().paused
		$".".set_visible(!is_visible())


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_player_won() -> void:
	game_over = true


func _on_player_died() -> void:
	game_over = true
