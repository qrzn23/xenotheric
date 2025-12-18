extends CharacterBody2D

signal died
signal took_damage(amount: int)

@export var max_health: int = 1
@export var gravity: float = 1300.0

var health: int

const ENEMY_DEATH_SCENE := preload("res://scenes/props/EnemyDeath.tscn")
const POWER_UP_SCENE := preload("res://scenes/props/PowerUp.tscn")

func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	took_damage.emit(amount)
	if health <= 0:
		_die()

func _die() -> void:
	_spawn_death_fx()
	_spawn_power_up()
	died.emit()
	queue_free()

func _spawn_death_fx() -> void:
	if not is_inside_tree():
		return
	var parent := get_parent()
	if not parent:
		return
	var fx := ENEMY_DEATH_SCENE.instantiate() as Node2D
	fx.global_position = global_position
	parent.add_child(fx)

func _spawn_power_up() -> void:
	if not is_inside_tree():
		return
	var parent := get_parent()
	if not parent:
		return
	var power_up := POWER_UP_SCENE.instantiate() as Node2D
	power_up.global_position = global_position
	parent.add_child(power_up)
