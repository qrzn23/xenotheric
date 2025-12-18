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
	var parent := get_parent()
	var drop_pos := _get_drop_global_position()
	# Death is often triggered from physics/collision callbacks (e.g. bullets).
	# Spawning new physics objects during query flush can error, so defer.
	_spawn_deferred(parent, ENEMY_DEATH_SCENE, drop_pos)
	_spawn_deferred(parent, POWER_UP_SCENE, drop_pos)
	died.emit()
	queue_free()

func _get_drop_global_position() -> Vector2:
	var drop_point := get_node_or_null("DropPoint") as Node2D
	if drop_point:
		return drop_point.global_position
	var collider := get_node_or_null("CollisionShape2D") as Node2D
	if collider:
		return collider.global_position
	return global_position

func _spawn_deferred(parent: Node, scene: PackedScene, pos: Vector2) -> void:
	if not parent or not is_instance_valid(parent):
		return
	var node := scene.instantiate() as Node2D
	node.global_position = pos
	parent.call_deferred("add_child", node)
