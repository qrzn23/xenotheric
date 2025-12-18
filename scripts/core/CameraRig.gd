extends Node2D

@export var target_path: NodePath
@export var look_ahead: Vector2 = Vector2(96, 32)
@export var smoothing: float = 6.0

func _process(delta: float) -> void:
	if not is_instance_valid(get_node_or_null(target_path)):
		return
	var target: Node2D = get_node(target_path)
	var desired := target.global_position
	# Simple look-ahead based on target velocity if available
	if target.has_method("get_velocity"):
		var v: Vector2 = target.get_velocity()
		desired += Vector2(sign(v.x) * look_ahead.x, sign(v.y) * look_ahead.y)
	global_position = global_position.lerp(desired, clamp(delta * smoothing, 0, 1))
