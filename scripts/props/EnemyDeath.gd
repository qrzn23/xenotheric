extends Node2D

@export var animation_name: StringName = &"default"

func _ready() -> void:
    add_to_group("enemy_death_fx")
    var sprite := $AnimatedSprite2D as AnimatedSprite2D
    sprite.animation_finished.connect(_on_animation_finished)
    sprite.play(animation_name)

func _on_animation_finished() -> void:
    queue_free()

