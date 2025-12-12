extends "res://addons/gut/test.gd"

var player

func before_each():
    player = preload("res://scenes/player/Player.tscn").instantiate()
    add_child(player)

func after_each():
    player.queue_free()

func test_coyote_buffer_defaults():
    assert_gt(player.coyote_time, 0, "coyote time should be positive")
    assert_gt(player.jump_buffer, 0, "jump buffer should be positive")
