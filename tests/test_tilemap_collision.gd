extends "res://addons/gut/test.gd"

var room: Node2D

func before_each():
	room = load("res://scenes/TestRoom.tscn").instantiate()
	add_child_autofree(room)
	await get_tree().process_frame
	await get_tree().physics_frame

func test_tilemap_floor_has_physics_collision():
	var ground_tiles: TileMap = room.get_node("GroundTiles")
	var space := room.get_world_2d().direct_space_state
	var from := Vector2(64, 100)
	var to := Vector2(64, 600)
	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 1
	var result := space.intersect_ray(query)
	assert_true(result.size() > 0, "Ray should hit the TileMap floor collision")
	var collider := result.get("collider")
	if collider is TileMap:
		assert_eq(collider, ground_tiles, "Ray should hit GroundTiles (TileMap)")
