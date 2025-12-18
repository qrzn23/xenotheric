extends Control

signal mode_selected(mode: StringName)
signal quit_requested()

@onready var _main_panel: Control = $MainPanel
@onready var _mode_panel: Control = $ModePanel

@onready var _new_game_button: Button = $MainPanel/VBox/NewGameButton
@onready var _quit_button: Button = $MainPanel/VBox/QuitButton

@onready var _start_button: Button = $ModePanel/VBox/StartButton
@onready var _test_button: Button = $ModePanel/VBox/TestButton
@onready var _back_button: Button = $ModePanel/VBox/BackButton

func _ready() -> void:
    _show_main()
    _new_game_button.pressed.connect(_on_new_game_pressed)
    _quit_button.pressed.connect(_on_quit_pressed)
    _start_button.pressed.connect(_on_start_pressed)
    _test_button.pressed.connect(_on_test_pressed)
    _back_button.pressed.connect(_on_back_pressed)

func _show_main() -> void:
    _main_panel.visible = true
    _mode_panel.visible = false
    _new_game_button.grab_focus()

func _show_mode_select() -> void:
    _main_panel.visible = false
    _mode_panel.visible = true
    _start_button.grab_focus()

func _on_new_game_pressed() -> void:
    _show_mode_select()

func _on_quit_pressed() -> void:
    quit_requested.emit()

func _on_start_pressed() -> void:
    mode_selected.emit(&"start")

func _on_test_pressed() -> void:
    mode_selected.emit(&"test")

func _on_back_pressed() -> void:
    _show_main()

