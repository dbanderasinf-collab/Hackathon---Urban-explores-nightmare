extends Node2D


func _on_player_won() -> void:
	$end_animation.play("won")


func _on_end_animation_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://main_menue.tscn")


func _on_player_died() -> void:
	$end_animation.play("died")
