extends Area2D

@export var speed := 520.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
    var dir := direction
    if dir == Vector2.ZERO:
        dir = Vector2.RIGHT
    position += dir.normalized() * speed * delta

    if not get_viewport_rect().has_point(global_position):
        queue_free()

func _on_Bullet_body_entered(body: Node) -> void:
    if body.has_method("take_damage"):
        body.take_damage(5)
    queue_free()
