extends "res://addons/gut/test.gd"

class EnemyBody:
    extends StaticBody2D
    var health: int = 10
    func take_damage(amount: int) -> void:
        health = max(health - amount, 0)

var world: Node2D
var player: CharacterBody2D

func before_each() -> void:
    world = Node2D.new()
    get_tree().root.add_child(world)
    get_tree().set_current_scene(world)

    player = preload("res://scenes/player/Player.tscn").instantiate()
    player.collision_layer = 1
    player.collision_mask = 1
    world.add_child(player)
    await get_tree().process_frame

func after_each() -> void:
    GameState.abilities["bombs"] = false
    if get_tree().current_scene == world:
        get_tree().set_current_scene(null)
    if is_instance_valid(world):
        world.queue_free()
        await get_tree().process_frame
        await get_tree().process_frame
    world = null
    player = null

func test_player_cannot_fire_bullets_while_morphed() -> void:
    player._toggle_morph()
    var before := world.get_child_count()
    player._fire_bullet(false)
    assert_eq(world.get_child_count(), before, "morph ball should prevent firing bullets")

func test_morph_bomb_damages_enemies_but_not_player() -> void:
    GameState.max_health = 99
    GameState.health = 20
    GameState.abilities["bombs"] = true

    player.global_position = Vector2.ZERO

    var enemy := EnemyBody.new()
    enemy.add_to_group("enemy")
    enemy.collision_layer = 1
    enemy.collision_mask = 1
    enemy.global_position = Vector2(0, -8)
    var enemy_shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 8.0
    enemy_shape.shape = circle
    enemy.add_child(enemy_shape)
    world.add_child(enemy)
    await get_tree().process_frame

    player._toggle_morph()
    var bomb: Node = player._plant_bomb(0.02)
    assert_not_null(bomb, "bomb should spawn when bombs ability is unlocked and player is morphed")
    bomb.set("explosion_radius", 80.0)
    bomb.set("damage", 5)
    await get_tree().process_frame
    await get_tree().create_timer(0.05).timeout

    assert_lt(enemy.health, 10, "bomb should damage enemies in radius")
    assert_eq(GameState.health, 20, "bomb should not damage the player")

func test_morph_state_ignores_jump_buffer_and_cannot_fire_after_jump() -> void:
    player._toggle_morph()

    player._jump_buffer = player.jump_buffer
    player._coyote_timer = player.coyote_time
    player._handle_input(1.0 / 60.0)

    assert_eq(player._state, player.PlayerState.MORPH, "morph should not transition to jump/fall states")

    var stand_sprite := player.get_node("Sprite2D") as AnimatedSprite2D
    var morph_sprite := player.get_node("MorphSprite2D") as AnimatedSprite2D
    assert_false(stand_sprite.visible, "standing sprite should stay hidden while morphed")
    assert_true(morph_sprite.visible, "morph sprite should stay visible while morphed")

    var before := world.get_child_count()
    player._fire_bullet(false)
    assert_eq(world.get_child_count(), before, "morph should prevent firing bullets even after jump attempts")
