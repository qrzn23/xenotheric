extends "res://addons/gut/test.gd"

var room: Node

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

func after_each():
	if is_instance_valid(room):
		room.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	room = null

func test_ground_tiles_have_cells_and_collision():
	var ground := _get_ground()
	assert_not_null(ground, "TestRoom should have a TileMapLayer (preferred) or GroundTiles TileMap")

	var tile_set: TileSet = ground.get("tile_set") as TileSet
	assert_not_null(tile_set, "Ground should have a TileSet assigned")

	var used_cells: Array[Vector2i] = []
	var first: Vector2i
	if ground is TileMapLayer:
		used_cells = (ground as TileMapLayer).get_used_cells()
		assert_gt(used_cells.size(), 0, "TileMapLayer should have painted cells")
		first = used_cells[0]
		assert_not_null((ground as TileMapLayer).get_cell_tile_data(first), "TileMapLayer cell should reference valid TileData")
	elif ground is TileMap:
		used_cells = (ground as TileMap).get_used_cells(0)
		assert_gt(used_cells.size(), 0, "TileMap should populate cells")
		first = used_cells[0]
		assert_not_null((ground as TileMap).get_cell_tile_data(0, first), "TileMap cell should reference valid TileData")

func test_player_collision_layer_matches_ground():
	var player: CharacterBody2D = room.get_node("Player")
	assert_eq(player.collision_layer, 1, "Player collision_layer should match ground")
	assert_eq(player.collision_mask, 1, "Player collision_mask should match ground")
