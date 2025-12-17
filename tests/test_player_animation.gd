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
	player._move_input_dir = 1.0
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "run")

func test_dash_animation_when_dashing():
	player._dash_timer = player.dash_time
	player.velocity.x = 0
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "dash")

func test_hurt_animation_when_invulnerable():
	player._invuln_timer = 0.5
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "hurt")

func test_jump_and_fall_animations():
	player.velocity.y = -50
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "jump")
	player.velocity.y = 50
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "fall")

func test_morph_animation():
	player._toggle_morph()
	player._update_animation()
	assert_eq(player.get_node("MorphSprite2D").animation, "roll")

func test_shoot_run_animation_when_moving_and_shooting():
	player._set_test_on_floor(true)
	player._shoot_timer = 0.1
	player._move_input_dir = 1.0
	player._ducking = false
	player._aiming_up = false
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "shoot_run")

func test_shoot_stand_animation_when_shooting_stationary():
	player._set_test_on_floor(true)
	player._shoot_timer = 0.1
	player._move_input_dir = 0.0
	player._ducking = false
	player._aiming_up = false
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "shoot_stand")

func test_shoot_up_animation_when_aiming_up():
	player._set_test_on_floor(true)
	player._shoot_timer = 0.1
	player._move_input_dir = 0.0
	player._ducking = false
	player._aiming_up = true
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "shoot_up")

func test_duck_animation_when_ducking():
	player._set_test_on_floor(true)
	player._shoot_timer = 0.1
	player._ducking = true
	player._aiming_up = false
	player._update_animation()
	assert_eq(player.get_node("Sprite2D").animation, "duck")
