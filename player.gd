extends Sprite2D

const flashlight_max = 120.0
const thermo_max = 60.0
const decible_max = 60.0
const middle_x = 4
const size_max = 7
const color_over_half = Color(1, 1, 0.141, 1)
const color_under_half = Color(0.947, 0.112, 0, 1)
const m_movment_oppertunity = 6
const m_stunned_max = 1
const hunting_min = 2
const m_agro_adder = 1
const m_agro_divider = 6
const M_kill_check_behind = 1
const M_kill_check_sides = 2
const M_kill_check_front = 4
const M_kill_check_Light_multipler = 2

var m_kill_min = M_kill_check_behind
var m_kill = 0
var m_movment = 0.0
var m_stunned = 0.0
var m_stunned_condition = false
var m_state = 1
var m_aggresion = 0
var monster_location
var m_hunt = 100
var m_prev_direction = 2

var item = 0
var battery_dead_f = false
var battery_dead_t = false
var battery_dead_d = false
var flashlight_battery = flashlight_max
var flashlight_on = false
var thermo_battery = thermo_max
var decible_battery = thermo_max
# null = 0 up = 1, left = 2, down = 3, right = 4.
var mouse_location = 0
var current_sprite = 0

var location = [middle_x,1]
var changing_rooms = false
var locked = true
var door_closed = true

var key_location
var key = false
var lock = 4
var rng = RandomNumberGenerator.new()
# up = 0, left = 1, down = 2, right = 3.
# this is in order to give more of an animation to 
# the character and help store values for the game
var direction = 1

@onready var keys_audio = $keys
@onready var locks_audio = $Locks

@onready var flashlight = $flashlight
@onready var key_storage = $"../GUI/key_storage"
@onready var flashlight_meter = $"../GUI/flashlight_meter"
@onready var thermo_meter = $"../GUI/thermomiter_meter"
@onready var decible_meter = $"../GUI/decibmal_meter"

@onready var left_button = $"../left/left_collsion"
@onready var right_button = $"../right/right_collsion"
@onready var up_button = $"../up/up_collsion"
@onready var down_button = $"../down/down_collsion"

@onready var room_changer_timer = $"../room_changer"
@onready var animation_player = $player_animation

@onready var cur_room = $"../current_room"
@onready var east_room = $"../east_room"
@onready var west_room = $"../west_room"
@onready var north_room = $"../north_room"
@onready var south_room = $"../south_room"

@onready var light_wall_left = $"../light_walls/left"
@onready var light_wall_right = $"../light_walls/right"
@onready var light_wall_down = $"../light_walls/bottem"
@onready var light_wall_top_exit = $"../light_walls/top_exit"
@onready var light_wall_top = $"../light_walls/top"
@onready var light_wall_top_left = $"../light_walls/top_left"
@onready var light_wall_top_right = $"../light_walls/top_right"
@onready var key_node = $"../keys"
@onready var lock_node = $"../lock"

@onready var display = $"../GUI/display"

@export var timer = 0

signal won
signal died
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("start")
	rng.randomize()
	key_location = [rng.randi_range(1,7), rng.randi_range(4,7)]
	monster_location = [rng.randi_range(1,7), 7]

func kill_check() -> void:
	m_hunt = hunting_min + m_aggresion
	m_kill += 1
	if flashlight_on:
		m_kill_min *= M_kill_check_Light_multipler
	print(m_kill_min)
	if m_kill >= m_kill_min:
		died.emit()
		get_tree().paused = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !m_stunned_condition:
		m_movment += delta + (m_aggresion/m_agro_divider)*delta
		if flashlight_on:
			if direction == 0:
				if monster_location[0] == location[0] && monster_location[1] == location[1]-1:
					m_stunned += delta
			elif direction == 1:
				if monster_location[0] == location[0]-1 && monster_location[1] == location[1]:
					m_stunned += delta
			elif direction == 2:
				if monster_location[0] == location[0] && monster_location[1] == location[1]+1:
					m_stunned += delta
			elif direction == 3:
				if monster_location[0] == location[0]+1 && monster_location[1] == location[1]:
					m_stunned += delta
		if m_stunned >= m_stunned_max:
			m_stunned = m_stunned_max*3
			m_stunned_condition = true
			m_aggresion += m_agro_adder
			$scream2.play(0)
	else:
		m_stunned -= delta
		if m_stunned <= 0:
			m_stunned_condition = false
	if m_movment >= m_movment_oppertunity && !changing_rooms:
		m_movment = 0
		if m_state == 0:
			if monster_location[0] >= location[0]-1 && monster_location[0] <= location[0]+1 && monster_location[1] >= location[1]-1 && monster_location[1] <= location[1]+1 :
				if m_state != 1:
					m_state = 1
					m_hunt = hunting_min + m_aggresion
					m_aggresion += m_agro_adder*2
			else:
				var moved = false
				var m_direction = rng.randi_range(0, 3)
				while !moved:
					if m_direction == 0 && monster_location[1] != 1 && m_prev_direction != 2:
						monster_location[1] -= 1
						moved = true
						m_prev_direction = 0
					elif m_direction == 1 && monster_location[0] != 1 && m_prev_direction != 3:
						monster_location[0] -= 1
						moved = true
						m_prev_direction = 1
					elif m_direction == 2 && monster_location[1] != size_max && m_prev_direction != 0:
						monster_location[1] += 1
						moved = true
						m_prev_direction = 2
					elif m_direction == 3 && monster_location[0] != size_max && m_prev_direction != 1:
						monster_location[0] += 1
						moved = true
						m_prev_direction = 3
					else:
						m_direction = (m_direction+1)%4
		elif m_state == 1:
			print(monster_location)
			if monster_location[0] == location[0] && monster_location[1] == location[1]-1:
				if direction == 0:
					m_kill_min = M_kill_check_front
				elif direction == 1:
					m_kill_min = M_kill_check_sides
				elif direction == 2:
					m_kill_min = M_kill_check_behind
				elif direction == 3:
					m_kill_min = M_kill_check_sides
				kill_check()
			elif monster_location[0] == location[0]-1 && monster_location[1] == location[1]:
				if direction == 1:
					m_kill_min = M_kill_check_front
				elif direction == 2:
					m_kill_min = M_kill_check_sides
				elif direction == 3:
					m_kill_min = M_kill_check_behind
				elif direction == 0:
					m_kill_min = M_kill_check_sides
				kill_check()
			elif monster_location[0] == location[0] && monster_location[1] == location[1]+1:
				if direction == 2:
					m_kill_min = M_kill_check_front
				elif direction == 3:
					m_kill_min = M_kill_check_sides
				elif direction == 0:
					m_kill_min = M_kill_check_behind
				elif direction == 1:
					m_kill_min = M_kill_check_sides
				kill_check()
			elif monster_location[0] == location[0]+1 && monster_location[1] == location[1]:
				if direction == 3:
					m_kill_min = M_kill_check_front
				elif direction == 0:
					m_kill_min = M_kill_check_sides
				elif direction == 1:
					m_kill_min = M_kill_check_behind
				elif direction == 2:
					m_kill_min = M_kill_check_sides
				kill_check()
			else:
				if !(monster_location[0] == location[0] && monster_location[1] == location[1]):
					var distance_x = location[0] - monster_location[0]
					var distance_y = location[1] - monster_location[1]
					var m_direction = rng.randi_range(0,abs(distance_x)+abs(distance_y))
					if m_direction <= abs(distance_x) && distance_x != 0:
						monster_location[0] += distance_x/abs(distance_x)
					else:
						monster_location[1] += distance_y/abs(distance_y)
				m_hunt -= 1
				if m_kill > 0:
					m_kill -= 2
					if m_kill == 0:
						m_kill = 0
				if m_hunt <= 0:
					m_state = 0
					m_hunt = 0
					m_kill = 0
					m_aggresion -= m_agro_adder*2
	
	
	timer += delta
	
	if Input.is_action_just_pressed("e"):
		if item == 1:
			item = 0
			display.play("hide")
		else:
			item = 1
		if direction == 2:
			if item == 1:
				set_frame(current_sprite+2)
			elif item == 2:
				set_frame(current_sprite+1)
			else:
				set_frame(current_sprite)
		elif direction == 0:
			set_frame(current_sprite)
		else:
			set_frame(current_sprite+item)
		
	
	if Input.is_action_just_pressed("R"):
		if item == 2:
			item = 0
			display.play("hide")
		else:
			item = 2
		if direction == 2:
			if item == 1:
				set_frame(current_sprite+2)
			elif item == 2:
				set_frame(current_sprite+1)
			else:
				set_frame(current_sprite)
		elif direction == 0:
			set_frame(current_sprite)
		else:
			set_frame(current_sprite+item)
	
	if changing_rooms:
		display.play("hide")
	elif item == 1:
		if thermo_battery <= 0 && !battery_dead_t:
			battery_dead_t = true
		thermo_meter.set_scale(Vector2(thermo_battery/thermo_max,1))
		if thermo_battery < thermo_max/2 :
			thermo_meter.set_color(color_under_half)
		else:
			thermo_meter.set_color(color_over_half)
		if battery_dead_t:
			display.play("thermo_dead")
		elif monster_location[0] >= location[0]-1 && monster_location[0] <= location[0]+1:
			if monster_location[1] >= location[1]-1 && monster_location[1] <= location[1]+1 :
				display.play("thermo_cold")
			else:
				display.play("thermo_norm")
			thermo_battery -= delta
		else:
			display.play("thermo_norm")
			thermo_battery -= delta
	elif item == 2:
		if decible_battery <= 0 && !battery_dead_d:
			battery_dead_d = true
		decible_meter.set_scale(Vector2(decible_battery/decible_max,1))
		if decible_battery < decible_max/2 :
			decible_meter.set_color(color_under_half)
		else:
			decible_meter.set_color(color_over_half)
		if battery_dead_d:
			display.play("decible_dead")
		elif direction == 0:
			decible_battery -= delta
			if monster_location[0] == location[0] && monster_location[1] == location[1]-1:
				display.play("decible_high")
			elif monster_location[0] == location[0] && monster_location[1] == location[1]-2:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]+1 && monster_location[1] == location[1]-1:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]-1 && monster_location[1] == location[1]-1:
				display.play("decible_elevated")
			else:
				display.play("decible_quiet")
		elif direction == 1:
			decible_battery -= delta
			if monster_location[0] == location[0]-1 && monster_location[1] == location[1]:
				display.play("decible_high")
			elif monster_location[0] == location[0]-2 && monster_location[1] == location[1]:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]-1 && monster_location[1] == location[1]+1:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]-1 && monster_location[1] == location[1]-1:
				display.play("decible_elevated")
			else:
				display.play("decible_quiet")
		elif direction == 2:
			decible_battery -= delta
			if monster_location[0] == location[0] && monster_location[1] == location[1]+1:
				display.play("decible_high")
			elif monster_location[0] == location[0] && monster_location[1] == location[1]+2:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]+1 && monster_location[1] == location[1]+1:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]-1 && monster_location[1] == location[1]+1:
				display.play("decible_elevated")
			else:
				display.play("decible_quiet")
		elif direction == 3:
			decible_battery -= delta
			if monster_location[0] == location[0]+1 && monster_location[1] == location[1]:
				display.play("decible_high")
			elif monster_location[0] == location[0]+2 && monster_location[1] == location[1]:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]+1 && monster_location[1] == location[1]+1:
				display.play("decible_elevated")
			elif monster_location[0] == location[0]+1 && monster_location[1] == location[1]-1:
				display.play("decible_elevated")
			else:
				display.play("decible_quiet")
		else: 
			decible_battery -= delta
	
	if Input.is_action_just_pressed("Up") :
		current_sprite = 9
		set_frame(current_sprite)
		flashlight.set_texture_offset(Vector2(25,-25))
		flashlight.set_rotation_degrees(-45)
		direction = 0
	elif Input.is_action_just_pressed("Down") :
		current_sprite = 6
		if item == 1:
			set_frame(current_sprite+2)
		elif item == 2:
			set_frame(current_sprite+1)
		else:
			set_frame(current_sprite)
		flashlight.set_texture_offset(Vector2(-28,28))
		flashlight.set_rotation_degrees(-225)
		direction = 2
	elif Input.is_action_just_pressed("Left") :
		current_sprite = 0
		set_frame(current_sprite+item)
		flashlight.set_texture_offset(Vector2(31,14))
		flashlight.set_rotation_degrees(-135)
		direction = 1
	elif Input.is_action_just_pressed("Right") :
		current_sprite = 3
		set_frame(current_sprite+item)
		flashlight.set_texture_offset(Vector2(-14,-31))
		flashlight.set_rotation_degrees(45)
		direction = 3
	
	if Input.is_action_just_pressed("Space") :
		if !battery_dead_f:
			flashlight.set_visible(!flashlight.is_visible())
			flashlight_on = !flashlight_on
	if flashlight_on && !battery_dead_f && !changing_rooms:
		flashlight_battery -= delta
		flashlight_meter.set_scale(Vector2(flashlight_battery/flashlight_max,1))
		if flashlight_battery < flashlight_max/2 :
			flashlight_meter.set_color(color_under_half)
		else:
			flashlight_meter.set_color(color_over_half)
	if flashlight_battery <= 0 && !battery_dead_f:
		battery_dead_f = true
		flashlight.set_visible(!flashlight.is_visible())
		flashlight_on = !flashlight_on
	
	if Input.is_action_just_pressed("Q"):
		m_movment += m_aggresion/m_agro_divider
		if key_location[0] == location[0] && key_location[1] == location[1] && !key && !changing_rooms:
			key = true
			key_storage.set_visible(true)
			key_node.set_visible(false)
			m_aggresion += 1
			keys_audio.play()
	
	if Input.is_action_just_pressed("left_click") && !changing_rooms:
		if location[0] == middle_x && location[1] == 1 && mouse_location == 1:
			if key && lock > 0:
				locks_audio.play()
				m_movment += m_aggresion/m_agro_divider
				m_aggresion += m_agro_adder
				lock -= 1
				key = false;
				key_storage.set_visible(false)
				if lock > 0:
					key_location = [rng.randi_range(1,7),rng.randi_range(4,7)]
					key_storage.set_frame(key_storage.get_frame()-1)
					key_node.set_frame(key_node.get_frame()-1)
					lock_node.set_frame(lock_node.get_frame()-1)
				elif lock == 0 && locked:
					lock_node.set_visible(false)
					key_node.set_visible(false)
					key_location = [-1,-1]
					locked = false
			elif lock == 0 && door_closed:
				locks_audio.play()
				m_movment += m_aggresion/m_agro_divider
				m_aggresion += m_agro_adder
				door_closed = false
				cur_room.set_frame(10)
			elif !door_closed:
				won.emit()
				get_tree().paused = true
		elif mouse_location == 1 && location[1] != 1:
			location[1] -= 1
			moving()
		elif mouse_location == 2 && location[0] != 1:
			location[0] -= 1
			moving()
		elif mouse_location == 3 && location[1] != size_max:
			location[1] += 1
			moving()
		elif mouse_location == 4 && location[0] != size_max:
			location[0] += 1
			moving()
		if location[0] == middle_x && location[1] == 1:
			up_button.set_disabled(false)
		elif location[1] == 1:
			up_button.set_disabled(true)
		else:
			up_button.set_disabled(false)
		if location[0] == 1:
			left_button.set_disabled(true)
		else:
			left_button.set_disabled(false)
		if location[1] == size_max:
			down_button.set_disabled(true)
		else:
			down_button.set_disabled(false)
		if location[0] == size_max:
			right_button.set_disabled(true)
		else:
			right_button.set_disabled(false)
		if monster_location[0] == location[0] && monster_location[1] == location[1]:
			m_kill = 100000
			kill_check()

func moving() -> void:
	changing_rooms = true
	animation_player.play("moving")
	room_changer_timer.start()

func _on_left_mouse_entered() -> void:
	mouse_location = 2


func _on_left_mouse_exited() -> void:
	mouse_location = 0


func _on_right_mouse_entered() -> void:
	mouse_location = 4


func _on_right_mouse_exited() -> void:
	mouse_location = 0


func _on_up_mouse_entered() -> void:
	mouse_location = 1


func _on_up_mouse_exited() -> void:
	mouse_location = 0


func _on_down_mouse_entered() -> void:
	mouse_location = 3


func _on_down_mouse_exited() -> void:
	mouse_location = 0

# location = [4,1]
func _on_room_changer_timeout() -> void:
	if key_location[0] == location[0] && key_location[1] == location[1] && !key:
		key_node.set_visible(true)
	else:
		key_node.set_visible(false)
	if location[0] == middle_x && location[1] == 1 :
		if locked:
			lock_node.set_visible(true)
		else:
			lock_node.set_visible(false)
		west_room.set_frame(1)
		east_room.set_frame(1)
		north_room.set_frame(5)
		south_room.set_frame(0)
		top_lights(true)
		if door_closed:
			cur_room.set_frame(9)
		else :
			cur_room.set_frame(10)
	else:
		lock_node.set_visible(false)
		top_lights(false)
		if location[0] == 1:
			light_wall_left.set_visible(true)
			light_wall_right.set_visible(false)
		elif location[0] == size_max:
			light_wall_left.set_visible(false)
			light_wall_right.set_visible(true)
		else:
			light_wall_left.set_visible(false)
			light_wall_right.set_visible(false)
		if location[1] == 1:
			light_wall_top.set_visible(true)
			light_wall_down.set_visible(false)
		elif location[1] == size_max:
			light_wall_top.set_visible(false)
			light_wall_down.set_visible(true)
		else:
			light_wall_top.set_visible(false)
			light_wall_down.set_visible(false)
		if location[1] == 1:
			north_room.set_frame(5)
			south_room.set_frame(0)
			cur_room.set_frame(1)
		elif location[1] == size_max:
			north_room.set_frame(0)
			south_room.set_frame(1)
			cur_room.set_frame(5)
		else: 
			north_room.set_frame(0)
			south_room.set_frame(0)
			cur_room.set_frame(0)
		if location[0] == 1:
			east_room.set_frame(0)
			west_room.set_frame(7)
			if location[1] == 1:
				cur_room.set_frame(2)
			elif location[1] == size_max:
				cur_room.set_frame(4)
			else:
				cur_room.set_frame(3)
		elif location[0] == size_max:
			east_room.set_frame(3)
			west_room.set_frame(0)
			if location[1] == 1:
				cur_room.set_frame(8)
			elif location[1] == size_max:
				cur_room.set_frame(6)
			else:
				cur_room.set_frame(7)
		else: 
			east_room.set_frame(0)
			west_room.set_frame(0)

func top_lights(exit: bool) -> void:
	light_wall_top_exit.set_visible(exit)
	light_wall_top.set_visible(!exit)
	light_wall_top_left.set_visible(!exit)
	light_wall_top_right.set_visible(!exit)


func _on_player_animation_animation_finished(anim_name: StringName) -> void:
	changing_rooms = false
