extends CharacterBody2D

signal fired(normal)
signal missile_fired(normal)
signal took_damage(amount)
signal died

@export var move_speed := 220.0
@export var accel := 12.0
@export var jump_force := 420.0
@export var gravity := 1300.0
@export var max_fall_speed := 900.0
@export var coyote_time := 0.12
@export var jump_buffer := 0.15
@export var wall_jump_force := Vector2(320, 420)
@export var dash_speed := 520.0
@export var dash_time := 0.2
@export var morph_height := 24.0
@export var stand_height := 48.0

var _coyote_timer := 0.0
var _jump_buffer := 0.0
var _dash_timer := 0.0
var _invuln_timer := 0.0
var _morph := false
var _facing := 1
var _invuln_flash_phase := 0.0

const BULLET_SCENE := preload("res://scenes/props/Bullet.tscn")
const MISSILE_SCENE := preload("res://scenes/props/Missile.tscn")

func _ready() -> void:
    set_physics_process(true)

func _physics_process(delta: float) -> void:
    _update_timers(delta)
    _update_invuln_flash(delta)
    _handle_input(delta)
    _apply_gravity(delta)
    _move_and_slide()
    _update_facing()

func _update_timers(delta: float) -> void:
    _coyote_timer = max(_coyote_timer - delta, 0)
    _jump_buffer = max(_jump_buffer - delta, 0)
    _dash_timer = max(_dash_timer - delta, 0)
    _invuln_timer = max(_invuln_timer - delta, 0)
    if _invuln_timer <= 0:
        _reset_invuln_flash()

func _update_invuln_flash(delta: float) -> void:
    if _invuln_timer <= 0:
        return
    _invuln_flash_phase += delta * 14.0
    var alpha := 0.35 + 0.35 * sin(_invuln_flash_phase * PI)
    _set_sprite_modulate(Color(1, 1, 1, clamp(alpha, 0.2, 0.7)))

func _handle_input(delta: float) -> void:
    var dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    var desired := dir * move_speed

    if _dash_timer > 0:
        velocity.x = lerp(velocity.x, _facing * dash_speed, 0.3)
    else:
        velocity.x = lerp(velocity.x, desired, accel * delta)

    if is_on_floor():
        _coyote_timer = coyote_time
    if Input.is_action_just_pressed("jump"):
        _jump_buffer = jump_buffer
    if _jump_buffer > 0 and (_coyote_timer > 0 or _is_touching_wall()):
        _perform_jump()

    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= 0.5

    if Input.is_action_just_pressed("dash") and GameState.has_ability("dash"):
        _dash_timer = dash_time

    if Input.is_action_just_pressed("morph"):
        _toggle_morph()

    if Input.is_action_just_pressed("fire"):
        _fire_bullet()
    if Input.is_action_just_pressed("missile") and GameState.has_ability("missile"):
        _fire_missile()

func _perform_jump() -> void:
    if _is_touching_wall() and GameState.has_ability("wall_jump"):
        var normal := _get_wall_normal()
        velocity = Vector2(normal.x * wall_jump_force.x, -wall_jump_force.y)
    else:
        velocity.y = -jump_force
    _jump_buffer = 0
    _coyote_timer = 0

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
    else:
        velocity.y = 0 if velocity.y < 0 else velocity.y

func _move_and_slide() -> void:
    move_and_slide()

func _update_facing() -> void:
    if abs(velocity.x) > 1:
        _facing = sign(velocity.x)

func _is_touching_wall() -> bool:
    return is_on_wall()

func _get_wall_normal() -> Vector2:
    for i in get_slide_collision_count():
        var col := get_slide_collision(i)
        if abs(col.normal.x) > 0.5:
            return col.normal
    return Vector2.ZERO

func _toggle_morph() -> void:
    _morph = !_morph
    var collider := $CollisionShape2D
    if collider and collider.shape is CapsuleShape2D:
        var shape := collider.shape as CapsuleShape2D
        shape.height = morph_height if _morph else stand_height
    $Sprite2D.visible = not _morph or not $MorphSprite2D # fallback
    if has_node("MorphSprite2D"):
        $MorphSprite2D.visible = _morph
    _set_sprite_modulate(Color.WHITE)

func _fire_bullet() -> void:
    var bullet := BULLET_SCENE.instantiate()
    bullet.global_position = global_position + Vector2(12 * _facing, -6)
    bullet.direction = _facing
    get_tree().current_scene.add_child(bullet)
    fired.emit(Vector2(_facing, 0))

func _fire_missile() -> void:
    if not GameState.spend_missile():
        return
    var missile := MISSILE_SCENE.instantiate()
    missile.global_position = global_position + Vector2(12 * _facing, -6)
    missile.direction = _facing
    get_tree().current_scene.add_child(missile)
    missile_fired.emit(Vector2(_facing, 0))

func take_damage(amount: int) -> void:
    if _invuln_timer > 0:
        return
    _invuln_timer = 1.0
    _invuln_flash_phase = 0.0
    _set_sprite_modulate(Color(1, 0.8, 0.8, 0.9))
    velocity.y = -180
    GameState.take_damage(amount)
    took_damage.emit(amount)
    if GameState.health <= 0:
        died.emit()

func _set_sprite_modulate(color: Color) -> void:
    if has_node("Sprite2D"):
        $Sprite2D.modulate = color
    if has_node("MorphSprite2D"):
        $MorphSprite2D.modulate = color

func _reset_invuln_flash() -> void:
    _invuln_flash_phase = 0.0
    _set_sprite_modulate(Color.WHITE)
