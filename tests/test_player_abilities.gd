extends "res://addons/gut/test.gd"

class WallJumpPlayer:
    extends "res://scripts/player/Player.gd"
    func _is_touching_wall() -> bool:
        return true
    func _get_wall_normal() -> Vector2:
        return Vector2(-1, 0)

var world: Node2D
var player: CharacterBody2D

func before_each():
    GameState.max_health = 99
    GameState.health = 50
    GameState.max_missiles = 5
    GameState.missiles = 2
    GameState.abilities["dash"] = false
    GameState.abilities["wall_jump"] = true
    GameState.abilities["missile"] = true

    world = Node2D.new()
    get_tree().root.add_child(world)
    get_tree().set_current_scene(world)

    player = preload("res://scenes/player/Player.tscn").instantiate()
    world.add_child(player)

func after_each():
    Input.action_release("dash")
    Input.action_release("missile")
    if get_tree().current_scene == world:
        get_tree().set_current_scene(null)
    if is_instance_valid(world):
        world.queue_free()
        await get_tree().process_frame
        await get_tree().process_frame
    world = null
    player = null

func test_dash_sets_timer_when_unlocked():
    GameState.abilities["dash"] = true
    Input.action_press("dash")
    player._handle_input(0.016)
    Input.action_release("dash")
    assert_almost_eq(player._dash_timer, player.dash_time, 0.0001, "dash timer should start when dash is unlocked")

func test_dash_does_not_start_when_locked():
    GameState.abilities["dash"] = false
    Input.action_press("dash")
    player._handle_input(0.016)
    Input.action_release("dash")
    assert_eq(player._dash_timer, 0.0, "dash timer should remain zero when dash is locked")

func test_wall_jump_requires_ability_to_push_off():
    GameState.abilities["wall_jump"] = true
    var wall_player := WallJumpPlayer.new()
    add_child_autofree(wall_player)
    wall_player._perform_jump()
    assert_eq(wall_player.velocity.x, -wall_player.wall_jump_force.x, "wall jump should push away from wall when unlocked")

    GameState.abilities["wall_jump"] = false
    wall_player.velocity = Vector2.ZERO
    wall_player._perform_jump()
    assert_eq(wall_player.velocity.x, 0.0, "no wall push when wall jump is locked")

func test_missile_fire_respects_ability_and_ammo():
    var initial_count := world.get_child_count()

    GameState.abilities["missile"] = false
    GameState.missiles = 1
    Input.action_press("missile")
    player._handle_input(0.016)
    Input.action_release("missile")
    assert_eq(GameState.missiles, 1, "missiles should not spend when ability locked")
    assert_eq(world.get_child_count(), initial_count, "no missile spawned when ability locked")

    GameState.abilities["missile"] = true
    Input.action_press("missile")
    player._handle_input(0.016)
    Input.action_release("missile")
    assert_eq(GameState.missiles, 0, "missile spend reduces ammo")
    assert_eq(world.get_child_count(), initial_count + 1, "missile instance spawned into world")

func test_invulnerability_prevents_repeated_damage():
    GameState.health = 50
    player.take_damage(10)
    player.take_damage(10)
    assert_eq(GameState.health, 40, "second damage while invulnerable should be ignored")
