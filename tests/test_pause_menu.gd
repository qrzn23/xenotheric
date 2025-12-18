extends "res://addons/gut/test.gd"

var main: Node

func before_each() -> void:
    Pause.unpause()
    main = preload("res://scenes/Main.tscn").instantiate()
    main.set("start_in_menu", false)
    main.set("start_room_scene", "")
    add_child_autofree(main)
    await get_tree().process_frame

func after_each() -> void:
    Pause.unpause()
    await get_tree().process_frame

func test_pause_menu_toggles_tree_pause_and_visibility() -> void:
    assert_false(get_tree().paused, "tree should start unpaused")

    main.call("_toggle_pause_menu")
    await get_tree().process_frame
    assert_true(get_tree().paused, "toggling pause should pause the tree")

    var pause_menu := main.get_node_or_null("PauseMenu")
    assert_not_null(pause_menu, "pause menu scene should be instanced under Main")

    main.call("_toggle_pause_menu")
    await get_tree().process_frame
    assert_false(get_tree().paused, "toggling pause again should unpause the tree")

func test_pausing_stops_player_movement() -> void:
    main.set("start_room_scene", "res://scenes/TestRoom.tscn")
    main.call("change_room", "res://scenes/TestRoom.tscn", &"")
    await get_tree().process_frame
    await get_tree().physics_frame

    var player := get_tree().get_first_node_in_group("player") as Node2D
    assert_not_null(player, "player should exist in the loaded room")
    var start_x: float = player.global_position.x

    main.call("_toggle_pause_menu")
    await get_tree().process_frame
    assert_true(get_tree().paused, "tree should be paused")

    Input.action_press("move_right")
    await get_tree().physics_frame
    await get_tree().physics_frame
    Input.action_release("move_right")

    assert_eq(player.global_position.x, start_x, "player should not move while paused")
