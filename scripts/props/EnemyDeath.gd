extends Node2D

@export var animation_name: StringName = &"default"
@export var max_lifetime: float = 0.8

func _ready() -> void:
    add_to_group("enemy_death_fx")
    var sprite := $AnimatedSprite2D as AnimatedSprite2D
    sprite.animation_finished.connect(_on_animation_finished)
    sprite.frame = 0
    sprite.frame_progress = 0.0
    sprite.play(animation_name)
    get_tree().create_timer(max_lifetime).timeout.connect(_on_lifetime_expired)

func _on_animation_finished() -> void:
    queue_free()

func _on_lifetime_expired() -> void:
    if is_queued_for_deletion():
        return
    queue_free()
