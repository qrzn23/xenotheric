extends Area2D

signal transition_requested(destination_scene: String, destination_spawn: StringName)
signal locked(required_key_id: StringName)

@export_file("*.tscn") var destination_scene: String = ""
@export var destination_spawn: StringName = &"PlayerSpawn"
@export var required_key_id: StringName = &""
@export var consume_key: bool = true
@export var auto_transition: bool = true

func _ready() -> void:
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body or not body.is_in_group("player"):
        return
    if required_key_id != &"" and not GameState.has_key(required_key_id):
        locked.emit(required_key_id)
        return

    if consume_key and required_key_id != &"":
        GameState.consume_key(required_key_id)

    GameState.pending_spawn = destination_spawn
    transition_requested.emit(destination_scene, destination_spawn)
    if auto_transition and destination_scene != "":
        get_tree().change_scene_to_file(destination_scene)

