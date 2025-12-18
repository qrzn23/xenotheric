extends "res://addons/gut/test.gd"

class DummyPlayer:
    extends Node
    func take_damage(_amount: int) -> void:
        pass

func test_bombs_pickup_unlocks_ability() -> void:
    GameState.abilities["bombs"] = false

    var pickup := preload("res://scenes/props/BombsPickup.tscn").instantiate()
    add_child_autofree(pickup)

    var player := DummyPlayer.new()
    add_child_autofree(player)

    pickup._on_body_entered(player)
    assert_true(GameState.has_ability("bombs"), "bombs pickup should unlock the ability")

