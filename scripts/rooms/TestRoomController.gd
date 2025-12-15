extends Node

@export var player_path: NodePath = NodePath("../Player")
@export var ground_tiles_path: NodePath = NodePath("../GroundTiles")

var _f1_was_down := false

func _ready() -> void:
	var ground_tiles := get_node_or_null(ground_tiles_path) as TileMap
	if ground_tiles:
		var used := ground_tiles.get_used_cells(0)
		var count := used.size()
		var tile_data_null := true
		if count > 0:
			tile_data_null = (ground_tiles.get_cell_tile_data(0, used[0]) == null)
		print("TestRoom:", "ground_tiles=", count, "tile_set_null=", ground_tiles.tile_set == null, "first_tile_data_null=", tile_data_null)

func _process(_delta: float) -> void:
	var f1_down := Input.is_key_pressed(KEY_F1)
	if f1_down == _f1_was_down:
		return
	_f1_was_down = f1_down
	if not f1_down:
		return
	var player := get_node_or_null(player_path)
	if not player:
		return
	if not player.has_method("set"):
		return
	var current := bool(player.get("debug_logs_enabled"))
	player.set("debug_logs_enabled", not current)
	print("debug_logs_enabled:", not current)
