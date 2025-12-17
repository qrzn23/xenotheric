extends "res://addons/gut/test.gd"

var player: CharacterBody2D
class RunPlayer:
	extends "res://scripts/player/Player.gd"
	func is_on_floor() -> bool:
		return true

func before_each():
	player = preload("res://scenes/player/Player.tscn").instantiate()
	add_child_autofree(player)

func test_run_animation_when_moving():
	player._set_test_on_floor(true)
	player._set_state(player.PlayerState.RUN)
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "run")

func test_dash_animation_when_dashing():
	player._set_state(player.PlayerState.DASH)
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "dash")

func test_hurt_animation_when_invulnerable():
	player._invuln_timer = 0.5
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "hurt")

func test_jump_and_fall_animations():
	player._set_state(player.PlayerState.JUMP)
	player.velocity.y = -50
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "jump")
	player._set_state(player.PlayerState.FALL)
	player.velocity.y = 50
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "fall")

func test_morph_animation():
	player._toggle_morph()
	player._update_animation()
	assert_eq(player.get_node("MorphSprite2D").animation, "roll")

func test_shoot_run_animation_when_moving_and_shooting():
	player._set_test_on_floor(true)
	player._set_state(player.PlayerState.SHOOT_RUN)
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "shoot_run")

func test_shoot_stand_animation_when_shooting_stationary():
	player._set_test_on_floor(true)
	player._set_state(player.PlayerState.SHOOT_STAND)
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "shoot_stand")

func test_shoot_up_animation_when_aiming_up():
	player._set_test_on_floor(true)
	player._set_state(player.PlayerState.AIM_UP)
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "shoot_up")

func test_duck_animation_when_ducking():
	player._set_test_on_floor(true)
	player._set_state(player.PlayerState.DUCK)
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "duck")
