extends Area2D

@export var speed := 400.0
@export var blast_radius := 32.0
var direction := 1

func _physics_process(delta: float) -> void:
    position.x += speed * delta * direction
    if not get_viewport_rect().has_point(global_position):
        queue_free()

func _explode() -> void:
    for body in get_overlapping_bodies():
        if body.has_method("take_damage"):
            body.take_damage(20)
    queue_free()

func _on_Missile_body_entered(body: Node) -> void:
    _explode()
