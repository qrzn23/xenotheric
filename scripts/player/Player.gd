extends CharacterBody2D
class_name Player

signal fired(normal)
signal missile_fired(normal)
signal took_damage(amount)
signal died

enum PlayerState {
	IDLE,
	RUN,
	DUCK,
	AIM_UP,
	SHOOT_STAND,
	SHOOT_RUN,
	DASH,
	JUMP,
	FALL,
	MORPH,
}

@export var move_speed := 220.0
@export var accel := 12.0
@export var jump_force := 560.0
@export var gravity := 1300.0
@export var max_fall_speed := 900.0
@export var coyote_time := 0.12
@export var jump_buffer := 0.15
@export var wall_jump_force := Vector2(320, 560)
@export var dash_speed := 520.0
@export var dash_time := 0.2
@export var shoot_hold_time := 0.12
@export var morph_height := 24.0
@export var stand_height := 48.0

var _coyote_timer := 0.0
var _jump_buffer := 0.0
var _dash_timer := 0.0
var _shoot_timer := 0.0
var _invuln_timer := 0.0
var _facing := 1
var _invuln_flash_phase := 0.0
var _last_anim_logged := ""
var _test_force_on_floor := false
var _state: int = PlayerState.IDLE
var _air_jumps_remaining: int = 0

var _sprite: AnimatedSprite2D
var _morph_sprite: AnimatedSprite2D
var _collider: CollisionShape2D
var _weapon_spawn: Marker2D
var _nozzle_up: Marker2D
var _nozzle_duck: Marker2D

var _use_action_move := true

@export var debug_logs_enabled := false

const BULLET_SCENE := preload("res://scenes/props/Bullet.tscn")
const MISSILE_SCENE := preload("res://scenes/props/Missile.tscn")

func _ready() -> void:
	add_to_group("player")
	_sprite = get_node_or_null("Sprite2D") as AnimatedSprite2D
	_morph_sprite = get_node_or_null("MorphSprite2D") as AnimatedSprite2D
	_collider = get_node_or_null("CollisionShape2D") as CollisionShape2D
	_weapon_spawn = get_node_or_null("WeaponSpawn") as Marker2D
	_nozzle_up = get_node_or_null("NozzleUp") as Marker2D
	_nozzle_duck = get_node_or_null("NozzleDuck") as Marker2D
	_use_action_move = _action_has_events(&"move_left") and _action_has_events(&"move_right")
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_update_invuln_flash(delta)
	_handle_input(delta)
	_apply_gravity(delta)
	_move_and_slide()
	_sync_state_after_move()
	_update_facing()
	_update_animation()

func _update_timers(delta: float) -> void:
	_coyote_timer = max(_coyote_timer - delta, 0)
	_jump_buffer = max(_jump_buffer - delta, 0)
	_dash_timer = max(_dash_timer - delta, 0)
	_shoot_timer = max(_shoot_timer - delta, 0)
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
	var move_dir := _get_move_dir()
	var on_floor := _is_considered_on_floor()
	if on_floor:
		_coyote_timer = coyote_time
		_air_jumps_remaining = _get_air_jump_capacity()

	var duck_input := _can_duck() and on_floor and Input.is_action_pressed("move_down")
	var aim_up_input := _can_aim() and not duck_input and Input.is_action_pressed("move_up")
	var desired := move_dir * move_speed
	_log_inputs()

	if duck_input:
		desired = 0.0

	if _state == PlayerState.DASH and _dash_timer > 0:
		velocity.x = lerp(velocity.x, _facing * dash_speed, 0.3)
	else:
		velocity.x = lerp(velocity.x, desired, accel * delta)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer = jump_buffer
	if _jump_buffer > 0 and _try_consume_jump():
		_set_state(PlayerState.JUMP)

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	if Input.is_action_just_pressed("dash") and GameState.has_ability("dash"):
		_dash_timer = dash_time
		_set_state(PlayerState.DASH)

	if Input.is_action_just_pressed("morph"):
		_toggle_morph()

	if Input.is_action_pressed("fire"):
		_shoot_timer = max(_shoot_timer, shoot_hold_time)

	if Input.is_action_just_pressed("fire"):
		# Ensure the current pose state is applied before computing the bullet
		# spawn position. Ducking shots should use the duck nozzle even if the
		# player was previously idle/run this frame.
		if duck_input:
			_set_state(PlayerState.DUCK)
		_fire_bullet(_can_aim() and Input.is_action_pressed("move_up") and not duck_input)
	if Input.is_action_just_pressed("missile") and GameState.has_ability("missile"):
		_fire_missile()

	_sync_ground_state(move_dir, duck_input, aim_up_input)

func _sync_ground_state(move_dir: float, duck_input: bool, aim_up_input: bool) -> void:
	if _state == PlayerState.MORPH:
		return
	if _dash_timer > 0:
		_set_state(PlayerState.DASH)
		return
	if not _is_considered_on_floor():
		_set_state(PlayerState.JUMP if velocity.y < 0 else PlayerState.FALL)
		return

	if duck_input:
		_set_state(PlayerState.DUCK)
	elif aim_up_input:
		_set_state(PlayerState.AIM_UP)
	elif _shoot_timer > 0:
		_set_state(PlayerState.SHOOT_RUN if abs(move_dir) > 0.01 else PlayerState.SHOOT_STAND)
	elif abs(move_dir) > 0.01:
		_set_state(PlayerState.RUN)
	else:
		_set_state(PlayerState.IDLE)

func _sync_state_after_move() -> void:
	if _state == PlayerState.MORPH:
		return

	if _dash_timer <= 0 and _state == PlayerState.DASH:
		_set_state(PlayerState.JUMP if velocity.y < 0 else PlayerState.FALL)

	if _is_considered_on_floor():
		if _state == PlayerState.JUMP or _state == PlayerState.FALL:
			# Use current input to pick a sensible grounded state after landing.
			var move_dir := _get_move_dir()
			var duck_input := _can_duck() and Input.is_action_pressed("move_down")
			var aim_up_input := _can_aim() and not duck_input and Input.is_action_pressed("move_up")
			_sync_ground_state(move_dir, duck_input, aim_up_input)
	else:
		if (
			_state == PlayerState.IDLE
			or _state == PlayerState.RUN
			or _state == PlayerState.DUCK
			or _state == PlayerState.AIM_UP
			or _state == PlayerState.SHOOT_STAND
			or _state == PlayerState.SHOOT_RUN
		):
			_set_state(PlayerState.JUMP if velocity.y < 0 else PlayerState.FALL)

func _set_state(new_state: int) -> void:
	if _state == new_state:
		return
	_state = new_state

func _can_duck() -> bool:
	return _state != PlayerState.MORPH

func _can_aim() -> bool:
	return _state != PlayerState.MORPH

func _get_move_dir() -> float:
	if _use_action_move:
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

func _try_consume_jump() -> bool:
	if _coyote_timer > 0 or _is_touching_wall():
		_perform_jump()
		return true

	if _air_jumps_remaining > 0:
		_air_jumps_remaining -= 1
		_perform_jump()
		return true

	return false

func _get_air_jump_capacity() -> int:
	return 1 if GameState.has_ability("double_jump") else 0

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
	if _sprite:
		_sprite.flip_h = _facing < 0
	if _morph_sprite:
		_morph_sprite.flip_h = _facing < 0

func _is_touching_wall() -> bool:
	return is_on_wall()

func _get_wall_normal() -> Vector2:
	var collision_count := get_slide_collision_count()
	for i in range(collision_count):
		var col := get_slide_collision(i)
		if col == null:
			continue
		var normal := col.get_normal()
		if abs(normal.x) > 0.5:
			return normal
	return Vector2.ZERO

func _toggle_morph() -> void:
	if _state == PlayerState.MORPH:
		_set_state(PlayerState.IDLE)
	else:
		_set_state(PlayerState.MORPH)

	if _collider and _collider.shape is CapsuleShape2D:
		var shape := _collider.shape as CapsuleShape2D
		shape.height = morph_height if _state == PlayerState.MORPH else stand_height

	if _sprite:
		_sprite.visible = _state != PlayerState.MORPH
	if _morph_sprite:
		_morph_sprite.visible = _state == PlayerState.MORPH
	_set_sprite_modulate(Color.WHITE)
	_update_animation()

func _fire_bullet(aim_up: bool) -> void:
	var bullet := BULLET_SCENE.instantiate()
	var dir := Vector2.UP if aim_up else Vector2(_facing, 0)
	bullet.global_position = _get_bullet_spawn_position(dir)
	bullet.direction = dir
	bullet.source = self
	var parent := get_parent()
	if not parent:
		parent = get_tree().current_scene
	if not parent:
		parent = get_tree().root
	parent.add_child(bullet)
	fired.emit(dir)

func _get_bullet_spawn_position(dir: Vector2) -> Vector2:
	var base_offset := Vector2(20, -24)
	if dir.y < -0.5 and _nozzle_up:
		base_offset = _nozzle_up.position
	elif _state == PlayerState.DUCK and _nozzle_duck:
		base_offset = _nozzle_duck.position
	elif _weapon_spawn:
		base_offset = _weapon_spawn.position

	# Mirror around the sprite pivot when facing left. The sprite is flipped via
	# `flip_h`, which mirrors visuals around the sprite node position (not the
	# player origin).
	var x := base_offset.x
	if _facing < 0:
		if _sprite:
			x = 2.0 * _sprite.position.x - x
		else:
			x *= _facing
	return global_position + Vector2(x, base_offset.y)

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
	if _sprite:
		_sprite.modulate = color
	if _morph_sprite:
		_morph_sprite.modulate = color

func _reset_invuln_flash() -> void:
	_invuln_flash_phase = 0.0
	_set_sprite_modulate(Color.WHITE)

func _update_animation() -> void:
	if _state == PlayerState.MORPH:
		_play_anim(_morph_sprite, "roll")
		return

	var anim := "idle"
	if _invuln_timer > 0:
		anim = "hurt"
	elif _state == PlayerState.DASH:
		anim = "dash"
	elif _state == PlayerState.JUMP or _state == PlayerState.FALL:
		anim = "jump" if velocity.y < 0 else "fall"
	elif _state == PlayerState.DUCK:
		anim = "duck"
	elif _state == PlayerState.AIM_UP:
		anim = "shoot_up"
	elif _state == PlayerState.SHOOT_RUN:
		anim = "shoot_run"
	elif _state == PlayerState.SHOOT_STAND:
		anim = "shoot_stand"
	elif _state == PlayerState.RUN:
		anim = "run"

	_play_anim(_sprite, anim)

func _play_anim(sprite: AnimatedSprite2D, anim_name: String) -> void:
	if not sprite:
		return
	if sprite.animation != anim_name:
		sprite.play(anim_name)
		_log_anim(anim_name)
	elif not sprite.is_playing():
		sprite.play()
		_log_anim(anim_name)

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

func _log_anim(anim_name: String) -> void:
	if not debug_logs_enabled:
		return
	if anim_name != _last_anim_logged:
		print("anim:", anim_name)
		_last_anim_logged = anim_name
