extends "res://addons/gut/test.gd"

var player

func before_each():
    player = preload("res://scenes/player/Player.tscn").instantiate()
    add_child_autofree(player)

func test_coyote_buffer_defaults():
    assert_gt(player.coyote_time, 0.0, "coyote time should be positive")
    assert_gt(player.jump_buffer, 0.0, "jump buffer should be positive")

func test_morph_toggle_adjusts_collider_and_sprites():
    var collider: CollisionShape2D = player.get_node("CollisionShape2D")
    var shape := collider.shape as CapsuleShape2D
    player._toggle_morph()
    assert_eq(shape.height, player.morph_height, "height shrinks in morph ball")
    assert_false(player.get_node("Sprite2D").visible, "stand sprite hides in morph")
    assert_true(player.get_node("MorphSprite2D").visible, "morph sprite shows")
    player._toggle_morph()
    assert_eq(shape.height, player.stand_height, "height returns on unmorph")
    assert_true(player.get_node("Sprite2D").visible, "stand sprite shows after unmorph")
