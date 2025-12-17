extends "res://addons/gut/test.gd"

class DummyBody:
    extends Node
    var damage_taken: Array = []
    func take_damage(amount: int) -> void:
        damage_taken.append(amount)

class MissileDouble:
    extends "res://scripts/props/Missile.gd"
    var overlaps: Array[Node] = []
    func _explode() -> void:
        for body in overlaps:
            if body.has_method("take_damage"):
                body.take_damage(20)
        queue_free()

func before_each():
    GameState.max_health = 99
    GameState.health = 50
    GameState.max_missiles = 10
    GameState.missiles = 1
    GameState.abilities["dash"] = false
    GameState.abilities["missile"] = true

func _make_pickup(pickup_type: String, amount: int = 10, ability_name: String = "dash") -> Area2D:
    var pickup: Area2D = load("res://scripts/props/Pickup.gd").new()
    pickup.pickup_type = pickup_type
    pickup.amount = amount
    pickup.ability_name = ability_name
    add_child_autofree(pickup)
    return pickup

func test_health_pickup_heals_and_queues_free():
    var pickup := _make_pickup("health", 20)
    var collector := DummyBody.new()
    add_child_autofree(collector)
    pickup._on_body_entered(collector)
    assert_eq(GameState.health, 70, "health pickup should heal the player")
    assert_true(pickup.is_queued_for_deletion(), "pickup queues free after collection")

func test_missile_pickup_adds_ammo():
    GameState.missiles = 0
    var pickup := _make_pickup("missile", 3)
    var collector := DummyBody.new()
    add_child_autofree(collector)
    pickup._on_body_entered(collector)
    assert_eq(GameState.missiles, 3, "missile pickup increments ammo")

func test_ability_pickup_unlocks():
    GameState.abilities["dash"] = false
    var pickup := _make_pickup("ability", 0, "dash")
    var collector := DummyBody.new()
    add_child_autofree(collector)
    pickup._on_body_entered(collector)
    assert_true(GameState.has_ability("dash"), "ability pickup unlocks ability")

func test_bullet_deals_damage_and_frees_on_hit():
    var bullet: Area2D = load("res://scripts/props/Bullet.gd").new()
    var target := DummyBody.new()
    add_child_autofree(target)
    add_child_autofree(bullet)
    # Bullet now spawns an impact Node2D on hit; ensure it has a parent.
    await get_tree().process_frame
    bullet._on_Bullet_body_entered(target)
    assert_eq(target.damage_taken, [5], "bullet should deal 5 damage on hit")
    assert_true(bullet.is_queued_for_deletion(), "bullet queues free after impact")
    await get_tree().process_frame
    var impacts := get_tree().get_nodes_in_group("impact_fx")
    assert_eq(impacts.size(), 1, "impact FX should be spawned on bullet hit")
    impacts[0].queue_free()

func test_missile_explodes_and_damages_overlaps():
    var missile := MissileDouble.new()
    var target := DummyBody.new()
    add_child_autofree(target)
    missile.overlaps = [target]
    add_child_autofree(missile)
    missile._on_Missile_body_entered(target)
    assert_eq(target.damage_taken, [20], "missile explosion damages overlapping bodies")
    assert_true(missile.is_queued_for_deletion(), "missile queues free after exploding")
