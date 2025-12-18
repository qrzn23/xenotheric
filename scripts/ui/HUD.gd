extends CanvasLayer

@onready var energy_value: Label = $TopBar/MarginContainer/Row/EnergyBox/EnergyRow/EnergyValue
@onready var missiles_value: Label = $TopBar/MarginContainer/Row/MissileBox/MissileRow/MissileValue

@onready var energy_gauge: Control = $TopBar/MarginContainer/Row/EnergyBox/EnergyRow/EnergyGauge
@onready var missiles_gauge: Control = $TopBar/MarginContainer/Row/MissileBox/MissileRow/MissileGauge

func _ready() -> void:
    add_to_group(&"hud")
    GameState.health_changed.connect(_on_health_changed)
    GameState.missiles_changed.connect(_on_missiles_changed)
    _on_health_changed(GameState.health, GameState.max_health)
    _on_missiles_changed(GameState.missiles, GameState.max_missiles)

func _on_health_changed(current: int, max_value: int) -> void:
    energy_value.text = "%d/%d" % [current, max_value]
    if energy_gauge and energy_gauge.has_method("set_value"):
        energy_gauge.call("set_max_value", max_value)
        energy_gauge.call("set_value", current)

func _on_missiles_changed(current: int, max_value: int) -> void:
    missiles_value.text = "%d/%d" % [current, max_value]
    if missiles_gauge and missiles_gauge.has_method("set_segments"):
        missiles_gauge.call("set_segments", max(max_value, 1))
        missiles_gauge.call("set_max_value", max_value)
        missiles_gauge.call("set_value", current)
