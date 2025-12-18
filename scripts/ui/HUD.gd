extends CanvasLayer

@onready var health_label: Label = $MarginContainer/VBoxContainer/Health
@onready var missile_label: Label = $MarginContainer/VBoxContainer/Missiles

func _ready() -> void:
    GameState.health_changed.connect(_on_health_changed)
    GameState.missiles_changed.connect(_on_missiles_changed)
    _on_health_changed(GameState.health, GameState.max_health)
    _on_missiles_changed(GameState.missiles, GameState.max_missiles)

func _on_health_changed(current: int, max_value: int) -> void:
    health_label.text = "Energy: %d/%d" % [current, max_value]

func _on_missiles_changed(current: int, max_value: int) -> void:
    missile_label.text = "Missiles: %d/%d" % [current, max_value]
