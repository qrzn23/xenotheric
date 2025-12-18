extends "res://addons/gut/test.gd"

var player: Node2D

func before_each() -> void:
    player = preload("res://scenes/player/Player.tscn").instantiate() as Node2D
    add_child_autofree(player)
    player.global_position = Vector2.ZERO

func test_duck_shot_spawns_lower_than_stand() -> void:
    var stand_pos: Vector2 = player.call("_get_bullet_spawn_position", Vector2.RIGHT) as Vector2

    var duck_state: int = 2
    var script: Script = player.get_script() as Script
    if script:
        var constants: Dictionary = script.get_script_constant_map()
        var player_state_variant: Variant = constants.get("PlayerState", null)
        if typeof(player_state_variant) == TYPE_DICTIONARY:
            var player_state: Dictionary = player_state_variant
            duck_state = int(player_state.get("DUCK", duck_state))
    player.call("_set_state", duck_state)

    var duck_pos: Vector2 = player.call("_get_bullet_spawn_position", Vector2.RIGHT) as Vector2
    assert_gt(duck_pos.y, stand_pos.y, "Duck shots should spawn lower than standing shots")
