extends "res://addons/gut/test.gd"

func test_patroller_flips_when_hitting_wall():
	var patroller: CharacterBody2D = load("res://scripts/enemies/Patroller.gd").new()
	add_child_autofree(patroller)
	patroller.direction = -1
	patroller._flip_direction()
	assert_eq(patroller.direction, 1, "patroller should flip direction when on wall")

func test_patroller_dies_on_damage():
	var patroller: CharacterBody2D = load("res://scripts/enemies/Patroller.gd").new()
	add_child_autofree(patroller)
	patroller.take_damage(5)
	assert_true(patroller.is_queued_for_deletion(), "patroller should queue free when damaged")
