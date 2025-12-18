extends "res://addons/gut/test.gd"

class DummyPlayer:
    extends Node
    func take_damage(_amount: int) -> void:
        pass

func test_enemy_drops_power_up_and_replenishes_energy() -> void:
    GameState.max_health = 99
    GameState.health = 40

    var world := Node2D.new()
    add_child_autofree(world)

    var enemy: CharacterBody2D = load("res://scripts/enemies/Enemy.gd").new()
    enemy.max_health = 1
    world.add_child(enemy)

    enemy.take_damage(1)
    await get_tree().process_frame

    var powerups := get_tree().get_nodes_in_group("power_up")
    assert_eq(powerups.size(), 1, "enemy should spawn exactly one power-up on death")

    var pickup := powerups[0] as Area2D
    var player := DummyPlayer.new()
    world.add_child(player)

    pickup._on_body_entered(player)
    assert_eq(GameState.health, 65, "power-up should add 25 energy")

