extends "res://addons/gut/test.gd"

var room: Node

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
	var ground_tiles: TileMap = room.get_node("GroundTiles")
	assert_gt(ground_tiles.get_used_cells(0).size(), 0, "Ground tiles should populate cells")
	assert_not_null(ground_tiles.tile_set, "Ground tiles should have a TileSet assigned")

	var cells := ground_tiles.get_used_cells(0)
	var first := cells[0] as Vector2i
	assert_eq(ground_tiles.get_cell_source_id(0, first), 0, "Ground tiles should use the expected source id")
	assert_eq(ground_tiles.get_cell_atlas_coords(0, first), Vector2i.ZERO, "Ground tiles should use the expected atlas coords")
	assert_not_null(ground_tiles.get_cell_tile_data(0, first), "Ground tiles should reference a valid tile in the TileSet")

func test_player_collision_layer_matches_ground():
	var player: CharacterBody2D = room.get_node("Player")
	assert_eq(player.collision_layer, 1, "Player collision_layer should match ground")
	assert_eq(player.collision_mask, 1, "Player collision_mask should match ground")
