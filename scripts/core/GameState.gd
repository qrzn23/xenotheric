extends Node

# Global state for health, ammo, and unlocked abilities.
# Emits signals for HUD updates and pickups.
signal health_changed(current, max)
signal missiles_changed(current, max)
signal ability_unlocked(ability_id)

@export var max_health: int = 99
@export var max_missiles: int = 10

var health: int
var missiles: int
var abilities: Dictionary = {
	"morph": true,
	"wall_jump": true,
	"missile": true,
	"dash": false,
	"double_jump": false,
	"bombs": false,
	"charge": false,
	"grapple": false,
}

var pending_spawn: StringName = &""

func _ready() -> void:
	health = max_health
	missiles = int(max_missiles / 2.0)
	emit_signal("health_changed", health, max_health)
	emit_signal("missiles_changed", missiles, max_missiles)

func add_health(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	emit_signal("health_changed", health, max_health)

func take_damage(amount: int) -> void:
	add_health(-amount)

func add_missiles(amount: int) -> void:
	missiles = clamp(missiles + amount, 0, max_missiles)
	emit_signal("missiles_changed", missiles, max_missiles)

func spend_missile() -> bool:
	if missiles <= 0:
		return false
	missiles -= 1
	emit_signal("missiles_changed", missiles, max_missiles)
	return true

func unlock(ability_id: String) -> void:
	if abilities.has(ability_id):
		abilities[ability_id] = true
		ability_unlocked.emit(ability_id)

func has_ability(ability_id: String) -> bool:
	return abilities.get(ability_id, false)

func clear_pending_spawn() -> void:
	pending_spawn = &""
