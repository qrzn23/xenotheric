extends Node

const _DEFAULT_KEYS: Dictionary = {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"jump": [KEY_SPACE],
	"fire": [KEY_F],
	"missile": [KEY_R],
	"dash": [KEY_SHIFT],
	"morph": [KEY_C],
	"pause": [KEY_ESCAPE],
}

func _ready() -> void:
	ensure_defaults()

func ensure_defaults() -> void:
	for action_name in _DEFAULT_KEYS.keys():
		_ensure_action(StringName(action_name))
		var keys: Array = _DEFAULT_KEYS[action_name]
		for key in keys:
			_ensure_key(StringName(action_name), int(key))

func _ensure_action(action_name: StringName) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

func _ensure_key(action_name: StringName, key: int) -> void:
	if _has_key(action_name, key):
		return
	var event := InputEventKey.new()
	var key_enum := key as Key
	event.physical_keycode = key_enum
	event.keycode = key_enum
	InputMap.action_add_event(action_name, event)

func _has_key(action_name: StringName, key: int) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is not InputEventKey:
			continue
		var key_event := event as InputEventKey
		if key_event.physical_keycode == key or key_event.keycode == key:
			return true
	return false
