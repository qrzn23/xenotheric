extends "res://addons/gut/test.gd"

var game_state: Node

func before_each():
	game_state = load("res://scripts/core/GameState.gd").new()
	add_child_autofree(game_state)

func test_health_signal_and_clamp():
	var events: Array = []
	game_state.health_changed.connect(func(current: int, max_value: int): events.append([current, max_value]))
	game_state.take_damage(150)
	assert_eq(game_state.health, 0, "health should clamp at 0")
	assert_eq(events.size(), 1, "health_changed emitted once")
	assert_eq(events[0], [0, game_state.max_health], "health_changed payload matches clamped health")

func test_missile_signal_and_spend():
	game_state.missiles = 1
	var events: Array = []
	game_state.missiles_changed.connect(func(current: int, max_value: int): events.append([current, max_value]))
	var spent: bool = game_state.spend_missile()
	assert_true(spent, "first missile spend should succeed")
	assert_eq(game_state.missiles, 0, "missiles decremented")
	assert_eq(events.size(), 1, "missiles_changed emitted once")
	assert_eq(events[0], [0, game_state.max_missiles], "missiles_changed payload matches new count")
	assert_false(game_state.spend_missile(), "cannot spend when empty")

func test_ability_unlock_and_query():
	game_state.abilities["dash"] = false
	game_state.unlock("dash")
	assert_true(game_state.has_ability("dash"), "dash should be unlocked")
