extends "res://addons/gut/test.gd"

var room: Node2D

func _get_ground() -> Node:
	if room.has_node("TileMapLayer"):
		return room.get_node("TileMapLayer")
	if room.has_node("GroundTiles"):
		return room.get_node("GroundTiles")
	return null

func before_each():
	room = load("res://scenes/TestRoom.tscn").instantiate()
	add_child_autofree(room)
	await get_tree().process_frame
	await get_tree().physics_frame

func test_tilemap_floor_has_physics_collision():
	var ground := _get_ground()
	assert_not_null(ground, "TestRoom should have a TileMapLayer (preferred) or GroundTiles TileMap")

	var space := room.get_world_2d().direct_space_state
	var from := Vector2(64, 100)
	var to := Vector2(64, 600)
	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 1
	var result := space.intersect_ray(query)
	assert_true(result.size() > 0, "Ray should hit the TileMap floor collision")
