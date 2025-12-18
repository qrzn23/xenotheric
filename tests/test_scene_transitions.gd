extends "res://addons/gut/test.gd"

class SignalCatcher:
    extends Node
    var locked_id: StringName = &""
    var transition_requested: bool = false
    func on_locked(id: StringName) -> void:
        locked_id = id
    func on_transition_requested(_scene: String, _spawn: StringName) -> void:
        transition_requested = true

func before_each() -> void:
    if typeof(GameState.keys) == TYPE_DICTIONARY:
        GameState.keys.clear()
    GameState.pending_spawn = &""

func test_exit_door_blocks_without_key() -> void:
    var door := load("res://scripts/props/ExitDoor.gd").new() as Area2D
    add_child_autofree(door)
    door.required_key_id = &"test_key"
    door.auto_transition = false

    var catcher := SignalCatcher.new()
    add_child_autofree(catcher)
    door.locked.connect(catcher.on_locked)

    var player := Node2D.new()
    add_child_autofree(player)
    player.add_to_group("player")
    assert_true(player.is_in_group("player"), "test precondition: player should be in player group")
    assert_eq(door.required_key_id, &"test_key", "test precondition: required key should be set")

    door._on_body_entered(player)
    assert_eq(catcher.locked_id, &"test_key", "door should emit locked when key is missing")
    assert_eq(GameState.pending_spawn, &"", "door should not set pending spawn when locked")

func test_exit_door_requests_transition_with_key() -> void:
    GameState.collect_key(&"test_key")

    var door := load("res://scripts/props/ExitDoor.gd").new() as Area2D
    add_child_autofree(door)
    door.required_key_id = &"test_key"
    door.consume_key = true
    door.destination_scene = "res://scenes/TestRoom.tscn"
    door.destination_spawn = &"PlayerSpawn"
    door.auto_transition = false

    var catcher := SignalCatcher.new()
    add_child_autofree(catcher)
    door.transition_requested.connect(catcher.on_transition_requested)

    var player := Node2D.new()
    add_child_autofree(player)
    player.add_to_group("player")
    assert_true(player.is_in_group("player"), "test precondition: player should be in player group")

    door._on_body_entered(player)
    assert_true(catcher.transition_requested, "door should emit transition_requested when key is present")
    assert_eq(GameState.pending_spawn, &"PlayerSpawn", "door should set pending spawn for next room")
    assert_false(GameState.has_key(&"test_key"), "door should consume key when consume_key is true")

func test_key_pickup_sets_key() -> void:
    var pickup := load("res://scripts/props/KeyPickup.gd").new() as Area2D
    add_child_autofree(pickup)
    pickup.key_id = &"hidden_key"

    var player := Node2D.new()
    add_child_autofree(player)
    player.add_to_group("player")
    assert_true(player.is_in_group("player"), "test precondition: player should be in player group")

    pickup._on_body_entered(player)
    assert_true(GameState.has_key(&"hidden_key"), "key pickup should set key in GameState")
