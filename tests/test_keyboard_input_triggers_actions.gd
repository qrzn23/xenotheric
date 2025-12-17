extends "res://addons/gut/test.gd"

func after_each() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	await get_tree().process_frame

func test_key_a_triggers_move_left_action() -> void:
	var down := InputEventKey.new()
	down.physical_keycode = KEY_A
	down.keycode = KEY_A
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().process_frame
	assert_true(Input.is_action_pressed("move_left"), "KEY_A should trigger move_left")

	var up := InputEventKey.new()
	up.physical_keycode = KEY_A
	up.keycode = KEY_A
	up.pressed = false
	Input.parse_input_event(up)
	await get_tree().process_frame
	assert_false(Input.is_action_pressed("move_left"), "KEY_A release should clear move_left")

func test_key_d_triggers_move_right_action() -> void:
	var down := InputEventKey.new()
	down.physical_keycode = KEY_D
	down.keycode = KEY_D
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().process_frame
	assert_true(Input.is_action_pressed("move_right"), "KEY_D should trigger move_right")

	var up := InputEventKey.new()
	up.physical_keycode = KEY_D
	up.keycode = KEY_D
	up.pressed = false
	Input.parse_input_event(up)
	await get_tree().process_frame
	assert_false(Input.is_action_pressed("move_right"), "KEY_D release should clear move_right")

