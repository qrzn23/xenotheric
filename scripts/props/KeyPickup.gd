extends Area2D

@export var key_id: StringName = &""

func _ready() -> void:
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body or not body.is_in_group("player"):
        return
    GameState.collect_key(key_id)
    queue_free()

