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
var _last_anim_logged := ""
var _test_force_on_floor := false
var _move_input_dir := 0.0

@export var debug_logs_enabled := false

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
    _update_animation()

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
    var dir := _get_move_dir()
    _move_input_dir = dir
    var desired := dir * move_speed
    _log_inputs()

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

func _get_move_dir() -> float:
    var left_has := _action_has_events(&"move_left")
    var right_has := _action_has_events(&"move_right")
    if left_has or right_has:
        return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

    var dir := 0.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        dir -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        dir += 1.0
    return dir

func _action_has_events(action_name: StringName) -> bool:
    return InputMap.has_action(action_name) and InputMap.action_get_events(action_name).size() > 0

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
        if velocity.y > 0:
            velocity.y = 0

func _move_and_slide() -> void:
    move_and_slide()

func _update_facing() -> void:
    if abs(velocity.x) > 1:
        _facing = sign(velocity.x)
    _apply_facing_to_sprites()

func _apply_facing_to_sprites() -> void:
    if has_node("Sprite2D"):
        $Sprite2D.flip_h = _facing < 0
    if has_node("MorphSprite2D"):
        $MorphSprite2D.flip_h = _facing < 0

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
    _update_animation()

func _fire_bullet() -> void:
    var bullet := BULLET_SCENE.instantiate()
    bullet.global_position = global_position + Vector2(12 * _facing, -6)
    bullet.direction = _facing
    var parent := get_parent()
    if not parent:
        parent = get_tree().current_scene
    if not parent:
        parent = get_tree().root
    parent.add_child(bullet)
    fired.emit(Vector2(_facing, 0))

func _fire_missile() -> void:
    if not GameState.spend_missile():
        return
    var missile := MISSILE_SCENE.instantiate()
    missile.global_position = global_position + Vector2(12 * _facing, -6)
    missile.direction = _facing
    var parent := get_parent()
    if not parent:
        parent = get_tree().current_scene
    if not parent:
        parent = get_tree().root
    parent.add_child(missile)
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

func _update_animation() -> void:
    if _morph:
        _play_anim($MorphSprite2D, "roll")
        return

    var anim := "idle"
    if _invuln_timer > 0:
        anim = "hurt"
    elif _dash_timer > 0:
        anim = "dash"
    elif not _is_considered_on_floor():
        anim = "jump" if velocity.y < 0 else "fall"
    elif abs(_move_input_dir) > 0.01:
        anim = "run"

    _play_anim($Sprite2D, anim)

func _play_anim(sprite: AnimatedSprite2D, name: String) -> void:
    if not sprite:
        return
    if sprite.animation != name:
        sprite.play(name)
        _log_anim(name)
    elif not sprite.is_playing():
        sprite.play()
        _log_anim(name)

func _is_considered_on_floor() -> bool:
    return _test_force_on_floor or is_on_floor()

func _set_test_on_floor(value: bool) -> void:
    _test_force_on_floor = value

func _log_inputs() -> void:
    if not debug_logs_enabled:
        return
    if Input.is_action_just_pressed("move_left"):
        print("input: move_left pressed")
    if Input.is_action_just_pressed("move_right"):
        print("input: move_right pressed")
    if Input.is_action_just_pressed("jump"):
        print("input: jump pressed")
    if Input.is_action_just_pressed("dash"):
        print("input: dash pressed")
    if Input.is_action_just_pressed("fire"):
        print("input: fire pressed")
    if Input.is_action_just_pressed("missile"):
        print("input: missile pressed")
    if Input.is_action_just_pressed("morph"):
        print("input: morph pressed")

func _log_anim(name: String) -> void:
    if not debug_logs_enabled:
        return
    if name != _last_anim_logged:
        print("anim:", name)
        _last_anim_logged = name
