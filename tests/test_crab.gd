extends "res://addons/gut/test.gd"

func test_crab_flips_direction() -> void:
    var crab: CharacterBody2D = load("res://scripts/enemies/Crab.gd").new()
    add_child_autofree(crab)
    crab.direction = -1
    crab._flip_direction()
    assert_eq(crab.direction, 1, "crab should flip direction")

func test_crab_dies_on_damage() -> void:
    var crab: CharacterBody2D = load("res://scripts/enemies/Crab.gd").new()
    crab.max_health = 2
    add_child_autofree(crab)
    crab.take_damage(2)
    assert_true(crab.is_queued_for_deletion(), "crab should queue free when health reaches 0")

func test_crab_enters_and_exits_chase_state() -> void:
    var world := Node2D.new()
    add_child_autofree(world)

    var crab: CharacterBody2D = load("res://scripts/enemies/Crab.gd").new()
    world.add_child(crab)

    var target := Node2D.new()
    target.add_to_group("player")
    world.add_child(target)

    crab.global_position = Vector2.ZERO
    target.global_position = Vector2(40, 0)

    var script: Script = crab.get_script() as Script
    var chase_state: int = _state_value(script, "CHASE")
    var patrol_state: int = _state_value(script, "PATROL")

    crab.set_chase_target(target)
    crab._physics_process(0.016)
    assert_eq(crab.get_state(), chase_state, "crab should enter chase when target is set nearby")

    target.global_position = Vector2(9999, 0)
    crab._physics_process(0.016)
    assert_eq(crab.get_state(), patrol_state, "crab should return to patrol when target is too far away")

func test_crab_aggro_area_is_not_monitorable() -> void:
    var crab_scene := preload("res://scenes/enemies/Crab.tscn")
    var crab := crab_scene.instantiate() as Node
    add_child_autofree(crab)

    var aggro := crab.get_node("AggroArea") as Area2D
    assert_false(aggro.monitorable, "aggro area should not be monitorable (prevents bullets from damaging via area overlap)")

func _state_value(script: Script, name: String) -> int:
    if not script:
        return -1
    var constants: Dictionary = script.get_script_constant_map()
    var state_variant: Variant = constants.get("State", null)
    if typeof(state_variant) != TYPE_DICTIONARY:
        return -1
    var state_dict: Dictionary = state_variant
    return int(state_dict.get(name, -1))
