extends "res://scripts/props/Pickup.gd"

func _ready() -> void:
    add_to_group("power_up")
    pickup_type = "health"
    amount = 25

