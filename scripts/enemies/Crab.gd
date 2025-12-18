extends "res://scripts/enemies/Enemy.gd"

enum State {
    PATROL,
    IDLE,
    CHASE,
    DEAD,
}

@export var speed: float = 70.0
@export var chase_speed: float = 130.0
@export var max_fall_speed: float = 900.0
@export var lose_aggro_distance: float = 180.0
@export var idle_time: float = 0.35

var direction: int = -1
var _state: int = State.PATROL
var _idle_timer: float = 0.0

var _sprite: AnimatedSprite2D
var _aggro_area: Area2D
var _chase_target: Node2D

func _ready() -> void:
    super._ready()
    add_to_group("enemy")
    _sprite = get_node_or_null("Sprite2D") as AnimatedSprite2D
    _aggro_area = get_node_or_null("AggroArea") as Area2D
    if _aggro_area:
        if not _aggro_area.body_entered.is_connected(_on_aggro_body_entered):
            _aggro_area.body_entered.connect(_on_aggro_body_entered)
        if not _aggro_area.body_exited.is_connected(_on_aggro_body_exited):
            _aggro_area.body_exited.connect(_on_aggro_body_exited)
    _apply_state_visuals()

func _physics_process(delta: float) -> void:
    if _state == State.DEAD:
        return

    _sync_ai_state()
    _update_idle_timer(delta)

    velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
    if _state == State.IDLE:
        velocity.x = 0.0
    elif _state == State.CHASE:
        direction = _get_chase_direction()
        velocity.x = direction * chase_speed
    else:
        velocity.x = direction * speed
    move_and_slide()

    if _state == State.PATROL and is_on_wall():
        _idle_timer = idle_time
        _set_state(State.IDLE)

    _apply_facing()

func take_damage(amount: int) -> void:
    super.take_damage(amount)

func _die() -> void:
    _set_state(State.DEAD)
    super._die()

func _flip_direction() -> void:
    direction *= -1

func set_chase_target(target: Node2D) -> void:
    _chase_target = target
    _sync_ai_state()

func clear_chase_target() -> void:
    _chase_target = null
    _sync_ai_state()

func get_state() -> int:
    return _state

func _set_state(new_state: int) -> void:
    if _state == new_state:
        return
    _state = new_state
    _apply_state_visuals()

func _apply_state_visuals() -> void:
    if not _sprite:
        return
    match _state:
        State.PATROL:
            _sprite.play("walk")
        State.IDLE:
            _sprite.play("idle")
        State.CHASE:
            _sprite.play("walk")
        State.DEAD:
            _sprite.stop()

func _apply_facing() -> void:
    if not _sprite:
        return
    _sprite.flip_h = direction > 0

func _sync_ai_state() -> void:
    if _state == State.DEAD:
        return

    if _chase_target and is_instance_valid(_chase_target):
        if global_position.distance_to(_chase_target.global_position) <= lose_aggro_distance:
            _set_state(State.CHASE)
            return
        _chase_target = null

    if _state == State.CHASE:
        _set_state(State.PATROL)

func _update_idle_timer(delta: float) -> void:
    if _state != State.IDLE:
        return
    _idle_timer = max(_idle_timer - delta, 0.0)
    if _idle_timer <= 0.0:
        _flip_direction()
        _set_state(State.PATROL)

func _get_chase_direction() -> int:
    if not _chase_target or not is_instance_valid(_chase_target):
        return direction
    var dx := _chase_target.global_position.x - global_position.x
    if abs(dx) < 1.0:
        return direction
    return 1 if dx > 0 else -1

func _on_aggro_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        _chase_target = body as Node2D
        _sync_ai_state()

func _on_aggro_body_exited(body: Node) -> void:
    if _chase_target == body:
        _chase_target = null
        _sync_ai_state()
