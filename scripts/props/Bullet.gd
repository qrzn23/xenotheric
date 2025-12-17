extends Area2D

@export var speed := 520.0
var direction: Vector2 = Vector2.RIGHT

const IMPACT_SCENE := preload("res://scenes/props/Impact.tscn")

func _ready() -> void:
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)
    if not area_entered.is_connected(_on_area_entered):
        area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
    var dir := direction
    if dir == Vector2.ZERO:
        dir = Vector2.RIGHT
    position += dir.normalized() * speed * delta

func _on_screen_exited() -> void:
    queue_free()

func _on_body_entered(body: Node) -> void:
    _handle_hit(body)

func _on_area_entered(area: Area2D) -> void:
    _handle_hit(area)

func _on_Bullet_body_entered(body: Node) -> void:
    _handle_hit(body)

func _handle_hit(hit: Node) -> void:
    if hit.is_in_group("player"):
        return

    if hit.has_method("take_damage"):
        hit.call("take_damage", 5)
    elif hit.get_parent() and hit.get_parent().has_method("take_damage"):
        hit.get_parent().call("take_damage", 5)

    _spawn_impact()
    queue_free()

func _spawn_impact() -> void:
    if not is_inside_tree():
        return
    var parent := get_parent()
    if not parent:
        return
    var impact := IMPACT_SCENE.instantiate() as Node2D
    impact.global_position = global_position
    parent.add_child(impact)
