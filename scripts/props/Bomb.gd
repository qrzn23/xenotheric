extends Node2D

@export var fuse_time: float = 3.0
@export var explosion_radius: float = 56.0
@export var damage: int = 8

var source: Node = null

const EXPLOSION_SCENE := preload("res://scenes/props/EnemyDeath.tscn")

var _timer: Timer

func _ready() -> void:
    add_to_group("player_projectile")
    add_to_group("bomb")

    _timer = Timer.new()
    _timer.one_shot = true
    _timer.wait_time = fuse_time
    add_child(_timer)
    _timer.timeout.connect(_explode)
    _timer.start()

func _explode() -> void:
    if not is_inside_tree():
        queue_free()
        return

    for node in get_tree().get_nodes_in_group(&"enemy"):
        var enemy := node as Node2D
        if enemy == null:
            continue
        if enemy.global_position.distance_to(global_position) > explosion_radius:
            continue
        if _should_ignore_hit(enemy):
            continue
        if enemy.has_method("take_damage"):
            enemy.call("take_damage", damage)

    _spawn_explosion_fx()
    queue_free()

func _should_ignore_hit(hit: Node) -> bool:
    if hit.is_in_group("player"):
        return true
    if source and _is_descendant_or_self(hit, source):
        return true
    if _has_ancestor_in_group(hit, &"player"):
        return true
    return false

func _is_descendant_or_self(node: Node, ancestor: Node) -> bool:
    var current: Node = node
    while current:
        if current == ancestor:
            return true
        current = current.get_parent()
    return false

func _has_ancestor_in_group(node: Node, group_name: StringName) -> bool:
    var current: Node = node
    while current:
        if current.is_in_group(group_name):
            return true
        current = current.get_parent()
    return false

func _spawn_explosion_fx() -> void:
    var parent := get_parent()
    if not parent:
        return
    var fx := EXPLOSION_SCENE.instantiate() as Node2D
    fx.global_position = global_position
    parent.add_child(fx)
