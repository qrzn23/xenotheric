extends "res://addons/gut/test.gd"

class SignalCatcher:
    extends Node
    var locked_weapon: StringName = &""
    var opened_weapon: StringName = &""
    var transition_requested: bool = false
    func on_locked(weapon: StringName) -> void:
        locked_weapon = weapon
    func on_opened(weapon: StringName) -> void:
        opened_weapon = weapon
    func on_transition_requested(_scene: String, _spawn: StringName) -> void:
        transition_requested = true

func test_weapon_door_requires_open_before_transition() -> void:
    var door := load("res://scripts/props/ExitDoor.gd").new() as Area2D
    add_child_autofree(door)
    door.required_weapon = "bullet"
    door.auto_transition = false

    var catcher := SignalCatcher.new()
    add_child_autofree(catcher)
    door.locked.connect(catcher.on_locked)
    door.opened.connect(catcher.on_opened)
    door.transition_requested.connect(catcher.on_transition_requested)

    var player := Node2D.new()
    player.add_to_group("player")
    add_child_autofree(player)

    door._on_body_entered(player)
    assert_eq(catcher.locked_weapon, &"bullet", "door should be locked until opened by a bullet")
    assert_false(catcher.transition_requested, "door should not transition while locked")

    var bullet := load("res://scripts/props/Bullet.gd").new() as Area2D
    add_child_autofree(bullet)
    if bullet.has_method("_ready"):
        bullet.call("_ready")
    door._on_area_entered(bullet)
    assert_eq(catcher.opened_weapon, &"bullet", "door should open when hit by the required projectile")

    door._on_body_entered(player)
    assert_true(catcher.transition_requested, "door should allow transition after being opened")
