extends "res://addons/gut/test.gd"

var player: CharacterBody2D

func before_each() -> void:
    player = preload("res://scenes/player/Player.tscn").instantiate()
    add_child_autofree(player)

func test_double_jump_consumes_air_jump_when_unlocked() -> void:
    GameState.abilities["double_jump"] = true

    player._air_jumps_remaining = 1
    player._coyote_timer = 0.0
    player.velocity = Vector2.ZERO
    player._set_state(player.PlayerState.FALL)

    var jumped: bool = player._try_consume_jump()
    assert_true(jumped, "player should be able to air-jump when double jump is unlocked")
    assert_lt(player.velocity.y, 0.0, "air-jump should apply upward velocity")
    assert_eq(player._air_jumps_remaining, 0, "air-jump should consume remaining air jumps")

func test_double_jump_does_not_work_when_locked() -> void:
    GameState.abilities["double_jump"] = false

    player._air_jumps_remaining = 0
    player._coyote_timer = 0.0
    player.velocity = Vector2.ZERO
    player._set_state(player.PlayerState.FALL)

    var jumped: bool = player._try_consume_jump()
    assert_false(jumped, "player should not be able to air-jump when double jump is locked")
    assert_eq(player.velocity.y, 0.0, "velocity should not change without an air-jump")

func test_air_jumps_reset_when_grounded() -> void:
    GameState.abilities["double_jump"] = true

    player._air_jumps_remaining = 0
    player._set_test_on_floor(true)
    player._handle_input(0.016)
    assert_eq(player._air_jumps_remaining, 1, "air jumps should reset when grounded")
