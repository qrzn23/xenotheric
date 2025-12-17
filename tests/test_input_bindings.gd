extends "res://addons/gut/test.gd"

const _REQUIRED_ACTIONS: Dictionary = {
	"move_left": KEY_A,
	"move_right": KEY_D,
	"jump": KEY_SPACE,
	"fire": KEY_F,
	"missile": KEY_R,
	"dash": KEY_SHIFT,
	"morph": KEY_S,
	"pause": KEY_ESCAPE,
}

func test_actions_exist_and_have_keyboard_defaults():
	for action_name in _REQUIRED_ACTIONS.keys():
		assert_true(InputMap.has_action(action_name), "Missing action: %s" % action_name)
		var required_key: int = _REQUIRED_ACTIONS[action_name]
		var has_key := false
		for event in InputMap.action_get_events(action_name):
			if event is not InputEventKey:
				continue
			var key_event := event as InputEventKey
			if key_event.physical_keycode == required_key or key_event.keycode == required_key:
				has_key = true
				break
		assert_true(has_key, "Action %s missing key %s" % [action_name, required_key])

