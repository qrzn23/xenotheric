extends Node

@export var player_path: NodePath = NodePath("../Player")
@export var ground_tiles_path: NodePath = NodePath("")

var _f1_was_down := false

func _ready() -> void:
	call_deferred("_print_room_summary")

func _print_room_summary() -> void:
	var ground := _find_ground()
	if not ground:
		print("TestRoom: no TileMapLayer/TileMap found")
		return

	var used_cells: Array[Vector2i] = []
	var tile_data_null := true
	var tile_set_null := ground.get("tile_set") == null

	if ground is TileMapLayer:
		used_cells = (ground as TileMapLayer).get_used_cells()
		if used_cells.size() > 0:
			tile_data_null = (ground as TileMapLayer).get_cell_tile_data(used_cells[0]) == null
	elif ground is TileMap:
		used_cells = (ground as TileMap).get_used_cells(0)
		if used_cells.size() > 0:
			tile_data_null = (ground as TileMap).get_cell_tile_data(0, used_cells[0]) == null

	print("TestRoom: ground_cells=", used_cells.size(), " tile_set_null=", tile_set_null, " first_tile_data_null=", tile_data_null)

func _find_ground() -> Node:
	if ground_tiles_path != NodePath("") and has_node(ground_tiles_path):
		return get_node(ground_tiles_path)

	var root := get_parent()
	if not root:
		return null

	if root.has_node("TileMapLayer"):
		return root.get_node("TileMapLayer")
	if root.has_node("GroundTiles"):
		return root.get_node("GroundTiles")

	for child in root.get_children():
		if child is TileMapLayer or child is TileMap:
			return child
	return null

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
