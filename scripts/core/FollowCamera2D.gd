extends Camera2D

@export var target_path: NodePath
@export var look_ahead: Vector2 = Vector2(96, 32)
@export var smoothing: float = 6.0

func _ready() -> void:
    make_current()

func _process(delta: float) -> void:
    var target := get_node_or_null(target_path) as Node2D
    if not target:
        return
    var desired := target.global_position
    if target is CharacterBody2D:
        var v := (target as CharacterBody2D).velocity
        desired += Vector2(sign(v.x) * look_ahead.x, sign(v.y) * look_ahead.y)
    global_position = global_position.lerp(desired, clamp(delta * smoothing, 0, 1))
