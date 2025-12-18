extends Node

@export var player_path: NodePath = NodePath("../Player")

func _ready() -> void:
    _apply_pending_spawn()

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

