extends Node2D

var mouse_play = false
var mouse_exit = false
var mouse_inst = false
var mouse_back = false
var game_starting = false

@onready var animation_player = $state_player

func _ready() -> void:
	animation_player.play("on")
	$static.play("static")
	get_tree().paused = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") && !game_starting:
		if mouse_play:
			game_starting = true
			animation_player.play("start")
			$Start.start()
		elif mouse_exit:
			get_tree().quit()
		elif mouse_inst:
			animation_player.play("instructions")
		elif mouse_back:
			animation_player.play("main")

func _on_play_button_mouse_entered() -> void:
	mouse_play = true


func _on_play_button_mouse_exited() -> void:
	mouse_play = false


func _on_exit_button_mouse_entered() -> void:
	mouse_exit = true


func _on_exit_button_mouse_exited() -> void:
	mouse_exit = false


func _on_instruct_button_mouse_entered() -> void:
	mouse_inst = true


func _on_instruct_button_mouse_exited() -> void:
	mouse_inst = false


func _on_back_button_mouse_entered() -> void:
	mouse_back = true


func _on_back_button_mouse_exited() -> void:
	mouse_back = false


func _on_start_timeout() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
