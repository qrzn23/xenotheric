extends "res://addons/gut/test.gd"

class DummyPlayer:
    extends Node
    func take_damage(_amount: int) -> void:
        pass

func test_double_jump_pickup_unlocks_ability() -> void:
    GameState.abilities["double_jump"] = false

    var pickup := preload("res://scenes/props/DoubleJumpPickup.tscn").instantiate()
    add_child_autofree(pickup)

    var player := DummyPlayer.new()
    add_child_autofree(player)

    pickup._on_body_entered(player)
    assert_true(GameState.has_ability("double_jump"), "double jump pickup should unlock the ability")

