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
	assert_true(ground_tiles.collision_layer == 1 and ground_tiles.collision_mask == 1, "Ground tiles should use collision layer/mask 1")
	assert_gt(ground_tiles.get_used_cells(0).size(), 0, "Ground tiles should populate cells")
	var tileset: TileSet = ground_tiles.tile_set
	var source_id := tileset.get_source_id(0)
	var source := tileset.get_source(source_id)
	var tile_ids: PackedInt32Array = source.get_tiles_ids()
	assert_gt(tile_ids.size(), 0, "Tile set should contain at least one tile")
	var shape: Shape2D = source.get_tile_shape(tile_ids[0], 0, 0)
	assert_not_null(shape, "Tile should have a collision shape")

func test_player_collision_layer_matches_ground():
	var player: CharacterBody2D = room.get_node("Player")
	assert_eq(player.collision_layer, 1, "Player collision_layer should match ground")
	assert_eq(player.collision_mask, 1, "Player collision_mask should match ground")
