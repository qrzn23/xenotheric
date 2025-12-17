extends "res://addons/gut/test.gd"

var world: Node2D
var player: CharacterBody2D

func before_each() -> void:
	world = Node2D.new()
	add_child_autofree(world)

	var ground := StaticBody2D.new()
	var ground_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(2000, 40)
	ground_shape.shape = rect
	ground.add_child(ground_shape)
	ground.position = Vector2(0, 260)
	world.add_child(ground)

	player = preload("res://scenes/player/Player.tscn").instantiate()
	player.position = Vector2(0, 120)
	world.add_child(player)

	# Let physics settle so the player is standing on the ground.
	for _i in range(6):
		await get_tree().physics_frame

func after_each() -> void:
	Input.action_release("jump")
	await get_tree().process_frame

func test_jump_sets_upward_velocity_and_animation() -> void:
	assert_true(player.is_on_floor(), "Player should be on the ground before jumping")

	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")

	assert_lt(player.velocity.y, 0.0, "Jump should set an upward velocity")

	var sprite := player.get_node("Sprite2D") as AnimatedSprite2D
	assert_eq(sprite.animation, "jump", "Jump should trigger the jump animation")

