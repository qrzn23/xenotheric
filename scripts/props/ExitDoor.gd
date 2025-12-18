extends Node2D

signal transition_requested(destination_scene: String, destination_spawn: StringName)
signal locked(required_weapon: StringName)
signal opened(required_weapon: StringName)

@export_file("*.tscn") var destination_scene: String = ""
@export var destination_spawn: StringName = &"PlayerSpawn"
@export_enum("bullet", "missile", "any") var required_weapon: String = "bullet"
@export var auto_transition: bool = true
@export var open_time: float = 3.0

var _is_open: bool = false

var _trigger_area: Area2D
var _hit_area: Area2D
var _blocker_shape: CollisionShape2D
var _close_timer: Timer
var _sprite: AnimatedSprite2D

func _ready() -> void:
    add_to_group("exit_door")
    _sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
    _trigger_area = get_node_or_null("TriggerArea") as Area2D
    _hit_area = get_node_or_null("HitArea") as Area2D
    _blocker_shape = get_node_or_null("Blocker/CollisionShape2D") as CollisionShape2D
    _close_timer = get_node_or_null("CloseTimer") as Timer

    if _sprite:
        _sprite.animation = &"closed"
        _sprite.frame = 0

    if _close_timer:
        _close_timer.one_shot = true
        if not _close_timer.timeout.is_connected(_close):
            _close_timer.timeout.connect(_close)

    if _trigger_area and not _trigger_area.body_entered.is_connected(_on_body_entered):
        _trigger_area.body_entered.connect(_on_body_entered)

    if _hit_area and not _hit_area.area_entered.is_connected(_on_area_entered):
        _hit_area.area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node) -> void:
    if not body or not body.is_in_group("player"):
        return
    if not _is_open:
        locked.emit(StringName(required_weapon))
        return

    GameState.pending_spawn = destination_spawn
    transition_requested.emit(destination_scene, destination_spawn)
    if auto_transition and destination_scene != "":
        var router := get_tree().get_first_node_in_group("scene_router")
        if router and router.has_method("change_room"):
            router.call_deferred("change_room", destination_scene, destination_spawn)
        else:
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
    if _blocker_shape:
        _blocker_shape.set_deferred("disabled", true)
    if _sprite:
        _sprite.play(&"open")
    if _close_timer and open_time > 0.0:
        _close_timer.start(open_time)

func _close() -> void:
    _is_open = false
    if _blocker_shape:
        _blocker_shape.set_deferred("disabled", false)
    if _sprite:
        _sprite.play(&"close")
