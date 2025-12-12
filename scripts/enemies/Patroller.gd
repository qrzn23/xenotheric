extends CharacterBody2D

@export var speed := 80.0
@export var damage := 10
@export var gravity := 1300.0
var direction := -1

func _physics_process(delta: float) -> void:
    velocity.y += gravity * delta
    velocity.x = direction * speed
    move_and_slide()
    if is_on_wall():
        _flip_direction()

func take_damage(amount: int) -> void:
    queue_free()

func _flip_direction() -> void:
    direction *= -1
