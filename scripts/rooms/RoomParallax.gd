extends ParallaxBackground
class_name RoomParallax

@export var texture: Texture2D
@export var middleground_texture: Texture2D

@export var background_motion_scale: Vector2 = Vector2(0.10, 0.06)
@export var middleground_motion_scale: Vector2 = Vector2(0.20, 0.12)

@export var overscan_px: Vector2 = Vector2(256, 256)

@onready var _background_layer: ParallaxLayer = $BackgroundLayer
@onready var _background_sprite: Sprite2D = $BackgroundLayer/Sprite2D
@onready var _middleground_layer: ParallaxLayer = $MidLayer
@onready var _middleground_sprite: Sprite2D = $MidLayer/Sprite2D

func _ready() -> void:
    add_to_group(&"room_parallax")
    if texture:
        _background_sprite.texture = texture
    if middleground_texture:
        _middleground_sprite.texture = middleground_texture
    else:
        _middleground_layer.visible = false

    _apply_layer_settings()

    var viewport := get_viewport()
    if viewport and not viewport.size_changed.is_connected(_update_fill):
        viewport.size_changed.connect(_update_fill)
    _update_fill()

func _update_fill() -> void:
    if not is_inside_tree():
        return

    var viewport := get_viewport()
    if not viewport:
        return

    var viewport_size: Vector2 = viewport.get_visible_rect().size
    _fit_sprite_to_viewport(_background_sprite, viewport_size)
    _fit_sprite_to_viewport(_middleground_sprite, viewport_size)

func _apply_layer_settings() -> void:
    _configure_layer(_background_layer, _background_sprite, background_motion_scale, -100)
    _configure_layer(_middleground_layer, _middleground_sprite, middleground_motion_scale, -50)

func _configure_layer(layer: ParallaxLayer, sprite: Sprite2D, motion: Vector2, z: int) -> void:
    if not layer or not sprite:
        return

    layer.motion_scale = motion
    sprite.z_index = z
    sprite.centered = false
    sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

    if sprite.texture:
        layer.motion_mirroring = Vector2(sprite.texture.get_width(), sprite.texture.get_height())
    else:
        layer.motion_mirroring = Vector2.ZERO

func _fit_sprite_to_viewport(sprite: Sprite2D, viewport_size: Vector2) -> void:
    if not sprite or not sprite.texture:
        return

    var margin: Vector2 = overscan_px
    margin = Vector2(sprite.texture.get_width(), sprite.texture.get_height())
    sprite.position = -margin
    sprite.region_enabled = true
    sprite.region_rect = Rect2(Vector2.ZERO, viewport_size + margin * 2.0)
