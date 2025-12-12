extends TileMap

@export var width_tiles: int = 200
@export var tile_source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i.ZERO

func _ready() -> void:
	for x in range(width_tiles):
		set_cell(0, Vector2i(x, 0), tile_source_id, atlas_coords)
