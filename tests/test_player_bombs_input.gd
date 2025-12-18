extends "res://addons/gut/test.gd"

var world: Node2D
var player: CharacterBody2D

func before_each() -> void:
	GameState.abilities["bombs"] = false

	world = Node2D.new()
	get_tree().root.add_child(world)
	get_tree().set_current_scene(world)

	player = preload("res://scenes/player/Player.tscn").instantiate()
	player.collision_layer = 1
	player.collision_mask = 1
	world.add_child(player)
	await get_tree().process_frame

func after_each() -> void:
	GameState.abilities["bombs"] = false
	_release_key(KEY_F)
	await get_tree().process_frame

	if get_tree().current_scene == world:
		get_tree().set_current_scene(null)
	if is_instance_valid(world):
		world.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	world = null
	player = null

func test_fire_key_plants_bomb_when_morphed_and_unlocked() -> void:
	GameState.abilities["bombs"] = true
	player._toggle_morph()
	await get_tree().process_frame

	_press_key(KEY_F)
	await get_tree().physics_frame
	await get_tree().process_frame

	var bombs: Array[Node] = get_tree().get_nodes_in_group(&"bomb")
	assert_eq(bombs.size(), 1, "pressing F while morphed should plant a bomb")

func test_fire_key_does_not_plant_bomb_when_not_morphed() -> void:
	GameState.abilities["bombs"] = true

	_press_key(KEY_F)
	await get_tree().physics_frame
	await get_tree().process_frame

	var bombs: Array[Node] = get_tree().get_nodes_in_group(&"bomb")
	assert_eq(bombs.size(), 0, "pressing F while standing should not plant a bomb")

func test_fire_key_does_not_plant_bomb_when_locked() -> void:
	player._toggle_morph()
	await get_tree().process_frame

	_press_key(KEY_F)
	await get_tree().physics_frame
	await get_tree().process_frame

	var bombs: Array[Node] = get_tree().get_nodes_in_group(&"bomb")
	assert_eq(bombs.size(), 0, "pressing F while morphed should not plant a bomb when ability is locked")

func _press_key(key: int) -> void:
	var down := InputEventKey.new()
	down.physical_keycode = key as Key
	down.keycode = key as Key
	down.pressed = true
	Input.parse_input_event(down)

func _release_key(key: int) -> void:
	var up := InputEventKey.new()
	up.physical_keycode = key as Key
	up.keycode = key as Key
	up.pressed = false
	Input.parse_input_event(up)

