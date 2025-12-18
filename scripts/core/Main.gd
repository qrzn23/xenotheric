extends Node

const PAUSE_MENU_SCENE := preload("res://scenes/ui/PauseMenu.tscn")

@export var start_in_menu: bool = true
@export_file("*.tscn") var start_room_scene: String = "res://scenes/TestRoom.tscn"
@export_file("*.tscn") var start_game_scene: String = "res://scenes/TestRoom2.tscn"
@export_file("*.tscn") var test_room_scene: String = "res://scenes/TestRoom.tscn"
@export_file("*.tscn") var test_room_2_scene: String = "res://scenes/TestRoom2.tscn"
@export_file("*.tscn") var menu_scene: String = "res://scenes/ui/MainMenu.tscn"

@onready var world: Node = $World
@onready var hud: CanvasLayer = $HUD

var _current_room: Node = null
var _menu: Control = null
var _pause_menu: CanvasLayer = null
var _mouse_mode_before_pause: int = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	add_to_group("scene_router")
	process_mode = Node.PROCESS_MODE_ALWAYS
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	if start_in_menu:
		hud.visible = false
		_show_menu()
		return

	if start_room_scene != "":
		hud.visible = true
		change_room(start_room_scene, &"")

func change_room(destination_scene: String, destination_spawn: StringName = &"") -> void:
	call_deferred("_change_room_impl", destination_scene, destination_spawn)

func _change_room_impl(destination_scene: String, destination_spawn: StringName) -> void:
	_close_pause_menu()
	if destination_spawn != &"":
		GameState.pending_spawn = destination_spawn

	if _current_room and is_instance_valid(_current_room):
		if _current_room.get_parent() == world:
			world.remove_child(_current_room)
		_current_room.queue_free()
		_current_room = null

	if destination_scene == "":
		return

	var packed := load(destination_scene) as PackedScene
	if not packed:
		push_error("Main: failed to load room: %s" % destination_scene)
		return

	var room := packed.instantiate() as Node
	world.add_child(room)
	_current_room = room
	_connect_room_doors(room)

func _connect_room_doors(room: Node) -> void:
	var stack: Array[Node] = [room]
	while stack.size() > 0:
		var node := stack.pop_back() as Node
		if not node:
			continue
		if node.is_in_group(&"exit_door") and node.has_signal("transition_requested"):
			var handler := Callable(self, "_on_transition_requested")
			if not node.is_connected("transition_requested", handler):
				node.connect("transition_requested", handler)

		for child in node.get_children():
			if child is Node:
				stack.append(child)

func _on_transition_requested(destination_scene: String, destination_spawn: StringName) -> void:
	change_room(destination_scene, destination_spawn)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause_menu()

func _show_menu() -> void:
	_close_pause_menu()
	if _menu and is_instance_valid(_menu):
		_menu.queue_free()
		_menu = null

	var packed := load(menu_scene) as PackedScene
	if not packed:
		push_error("Main: failed to load menu: %s" % menu_scene)
		return
	_menu = packed.instantiate() as Control
	add_child(_menu)

	if _menu.has_signal("mode_selected"):
		_menu.connect("mode_selected", Callable(self, "_on_menu_mode_selected"))
	if _menu.has_signal("quit_requested"):
		_menu.connect("quit_requested", Callable(self, "_on_menu_quit_requested"))

func _on_menu_mode_selected(mode: StringName) -> void:
	if _menu and is_instance_valid(_menu):
		_menu.queue_free()
		_menu = null
	hud.visible = true
	var scene := start_game_scene
	if mode == &"test1":
		scene = test_room_scene
	elif mode == &"test2":
		scene = test_room_2_scene
	change_room(scene, &"")

func _on_menu_quit_requested() -> void:
	get_tree().quit()

func _toggle_pause_menu() -> void:
	if _menu and is_instance_valid(_menu):
		return
	if _pause_menu and is_instance_valid(_pause_menu):
		_close_pause_menu()
		return
	_open_pause_menu()

func _open_pause_menu() -> void:
	_mouse_mode_before_pause = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not Pause.is_paused:
		Pause.toggle_pause()
	_pause_menu = PAUSE_MENU_SCENE.instantiate() as CanvasLayer
	_pause_menu.name = "PauseMenu"
	add_child(_pause_menu)
	if _pause_menu.has_signal("continue_requested"):
		_pause_menu.connect("continue_requested", Callable(self, "_close_pause_menu"))
	if _pause_menu.has_signal("main_menu_requested"):
		_pause_menu.connect("main_menu_requested", Callable(self, "return_to_main_menu"))
	if _pause_menu.has_signal("quit_requested"):
		_pause_menu.connect("quit_requested", Callable(self, "_on_menu_quit_requested"))

func _close_pause_menu() -> void:
	if _pause_menu and is_instance_valid(_pause_menu):
		_pause_menu.queue_free()
		_pause_menu = null
	Input.mouse_mode = _mouse_mode_before_pause
	Pause.unpause()

func return_to_main_menu() -> void:
	_close_pause_menu()
	hud.visible = false
	change_room("", &"")
	_show_menu()
