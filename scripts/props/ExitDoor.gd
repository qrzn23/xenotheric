extends Area2D

signal transition_requested(destination_scene: String, destination_spawn: StringName)
signal locked(required_weapon: StringName)
signal opened(required_weapon: StringName)

@export_file("*.tscn") var destination_scene: String = ""
@export var destination_spawn: StringName = &"PlayerSpawn"
@export_enum("bullet", "missile", "any") var required_weapon: String = "bullet"
@export var auto_transition: bool = true
@export var open_time: float = 1.2

var _is_open: bool = false

func _ready() -> void:
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)
    if not area_entered.is_connected(_on_area_entered):
        area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node) -> void:
    if not body or not body.is_in_group("player"):
        return
    if not _is_open:
        locked.emit(StringName(required_weapon))
        return

    GameState.pending_spawn = destination_spawn
    transition_requested.emit(destination_scene, destination_spawn)
    if auto_transition and destination_scene != "":
        get_tree().change_scene_to_file(destination_scene)

func _on_area_entered(area: Area2D) -> void:
    if not area:
        return
    if _is_open:
        return
    if not _matches_required_weapon(area):
        return
    _open()

func _matches_required_weapon(projectile: Area2D) -> bool:
    if required_weapon == "any":
        return projectile.is_in_group("player_projectile")
    if required_weapon == "bullet":
        return projectile.is_in_group("bullet")
    if required_weapon == "missile":
        return projectile.is_in_group("missile")
    return false

func _open() -> void:
    _is_open = true
    opened.emit(StringName(required_weapon))
    if open_time > 0.0:
        get_tree().create_timer(open_time).timeout.connect(_close)

func _close() -> void:
    _is_open = false
