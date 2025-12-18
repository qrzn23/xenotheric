extends Node2D

@export var animation_name: StringName = &"default"
@export var max_lifetime: float = 0.8

func _ready() -> void:
    add_to_group("enemy_death_fx")
    var sprite := $AnimatedSprite2D as AnimatedSprite2D
    sprite.animation_finished.connect(_on_animation_finished)
    sprite.play(animation_name)
    var lifetime := max_lifetime
    if OS.has_feature("headless"):
        lifetime = 0.0
    get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_expired)

func _on_animation_finished() -> void:
    queue_free()

func _on_lifetime_expired() -> void:
    if is_queued_for_deletion():
        return
    queue_free()
