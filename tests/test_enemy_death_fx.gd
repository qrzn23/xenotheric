extends "res://addons/gut/test.gd"

func test_enemy_spawns_death_fx_on_death() -> void:
    var before := get_tree().get_nodes_in_group("enemy_death_fx").size()

    var world := Node2D.new()
    add_child_autofree(world)

    var enemy: CharacterBody2D = load("res://scripts/enemies/Enemy.gd").new()
    enemy.max_health = 1
    world.add_child(enemy)

    enemy.take_damage(1)

    var after := get_tree().get_nodes_in_group("enemy_death_fx").size()
    assert_eq(after, before + 1, "killing an enemy should spawn a death FX node")

