extends Area2D

@export_enum("health", "missile", "ability") var pickup_type := "health"
@export var amount := 10
@export var ability_name := "dash"

func _ready() -> void:
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body or not body.has_method("take_damage"):
        return
    match pickup_type:
        "health":
            GameState.add_health(amount)
        "missile":
            GameState.add_missiles(amount)
        "ability":
            GameState.unlock(ability_name)
    queue_free()
