extends TileMap

@export var width_tiles: int = 200
@export var tile_source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var debug_print: bool = false

func _ready() -> void:
	if get_used_cells(0).size() > 0:
		if debug_print:
			_debug_dump("ready: pre-painted cells present")
		return
	_generate_floor()
	call_deferred("_post_generate")

func _generate_floor() -> void:
	for x in range(width_tiles):
		set_cell(0, Vector2i(x, 0), tile_source_id, atlas_coords)
	if debug_print:
		_debug_dump("generated")

func _post_generate() -> void:
	if has_method("notify_runtime_tile_data_update"):
		call("notify_runtime_tile_data_update")
	if has_method("update_internals"):
		call("update_internals")
	if debug_print:
		_debug_dump("post_generate")

func _debug_dump(prefix: String) -> void:
	var used := get_used_cells(0)
	var count := used.size()
	var tile_data_null := true
	if count > 0:
		tile_data_null = (get_cell_tile_data(0, used[0]) == null)
	print("TestRoomGround:", prefix, "tiles=", count, "tile_set_null=", tile_set == null, "first_tile_data_null=", tile_data_null)
