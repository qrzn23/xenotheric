extends "res://addons/gut/test.gd"

func test_player_cannot_be_hurt_by_own_bullet() -> void:
    GameState.max_health = 10
    GameState.health = 10

    var player := preload("res://scenes/player/Player.tscn").instantiate()
    add_child_autofree(player)

    # Simulate a non-player child area being hit (previously this would forward
    # damage to the parent via `get_parent().take_damage()`).
    var sensor := Area2D.new()
    player.add_child(sensor)

    var bullet: Area2D = load("res://scripts/props/Bullet.gd").new()
    add_child_autofree(bullet)
    bullet.source = player

    bullet._handle_hit(sensor)

    assert_eq(GameState.health, 10, "player should not take damage from their own bullet")
    assert_false(bullet.is_queued_for_deletion(), "bullet should not be consumed when hitting the player")
