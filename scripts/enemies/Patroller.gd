extends "res://scripts/enemies/Enemy.gd"

enum State {
    PATROL,
    DEAD,
}

@export var speed: float = 80.0
@export var contact_damage: int = 10

var direction: int = -1
var _state: int = State.PATROL

func _ready() -> void:
    super._ready()
    add_to_group("enemy")
    _set_state(State.PATROL)

func _physics_process(delta: float) -> void:
    if _state == State.DEAD:
        return
    velocity.y = min(velocity.y + gravity * delta, 900.0)
    velocity.x = direction * speed
    move_and_slide()
    if is_on_wall():
        _flip_direction()

func take_damage(amount: int) -> void:
    super.take_damage(amount)

func _die() -> void:
    _set_state(State.DEAD)
    super._die()

func _flip_direction() -> void:
    direction *= -1

func _set_state(new_state: int) -> void:
    if _state == new_state:
        return
    _state = new_state
