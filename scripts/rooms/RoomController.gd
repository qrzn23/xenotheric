extends Node

@export var player_path: NodePath = NodePath("../Player")

const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const PARALLAX_SCENE := preload("res://scenes/rooms/RoomParallax.tscn")

func _ready() -> void:
    _apply_pending_spawn()
    _ensure_standalone_hud()
    _ensure_room_parallax()

func _apply_pending_spawn() -> void:
    var spawn_name := GameState.pending_spawn
    if spawn_name == &"":
        return

    var root := get_parent()
    if not root:
        GameState.clear_pending_spawn()
        return

    var player := root.get_node_or_null(player_path) as Node2D
    if not player:
        GameState.clear_pending_spawn()
        return

    var spawn := root.find_child(String(spawn_name), true, false) as Node2D
    if spawn:
        player.global_position = spawn.global_position
    GameState.clear_pending_spawn()

func _ensure_standalone_hud() -> void:
    if get_tree().get_first_node_in_group(&"scene_router"):
        return
    if get_tree().get_first_node_in_group(&"hud"):
        return
    var hud := HUD_SCENE.instantiate()
    call_deferred("_add_child_to_root", hud)

func _ensure_room_parallax() -> void:
    var root := get_parent()
    if not root:
        return
    for node in get_tree().get_nodes_in_group(&"room_parallax"):
        if node is Node and _is_descendant_of(node as Node, root):
            return
    var parallax := PARALLAX_SCENE.instantiate()
    call_deferred("_add_parallax_to_room", root, parallax)

func _add_child_to_root(child: Node) -> void:
    if not is_instance_valid(child):
        return
    get_tree().root.add_child(child)

func _add_parallax_to_room(room: Node, parallax: Node) -> void:
    if not is_instance_valid(room) or not is_instance_valid(parallax):
        return
    room.add_child(parallax)
    room.move_child(parallax, 0)

func _is_descendant_of(node: Node, ancestor: Node) -> bool:
    var current: Node = node
    while current:
        if current == ancestor:
            return true
        current = current.get_parent()
    return false
