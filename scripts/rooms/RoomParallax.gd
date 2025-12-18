extends ParallaxBackground
class_name RoomParallax

@export var texture: Texture2D
@export var motion_scale: Vector2 = Vector2(0.15, 0.1)

@onready var _layer: ParallaxLayer = $ParallaxLayer
@onready var _sprite: Sprite2D = $ParallaxLayer/Sprite2D

func _ready() -> void:
    add_to_group(&"room_parallax")
    if texture:
        _sprite.texture = texture
    if _sprite.texture:
        _layer.motion_mirroring = Vector2(_sprite.texture.get_width(), _sprite.texture.get_height())
    _layer.motion_scale = motion_scale

