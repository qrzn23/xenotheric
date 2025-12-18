extends Node

@export_file("*.tscn") var start_room_scene: String = "res://scenes/TestRoom.tscn"

@onready var world: Node = $World

var _current_room: Node = null

func _ready() -> void:
	add_to_group("scene_router")
	if start_room_scene != "":
		change_room(start_room_scene, &"")

func change_room(destination_scene: String, destination_spawn: StringName = &"") -> void:
	call_deferred("_change_room_impl", destination_scene, destination_spawn)

func _change_room_impl(destination_scene: String, destination_spawn: StringName) -> void:
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
