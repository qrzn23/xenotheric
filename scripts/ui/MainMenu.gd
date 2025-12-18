extends Control

signal mode_selected(mode: StringName)
signal quit_requested()

@onready var _background: TextureRect = $Background
@onready var _panel_background: TextureRect = $MenuContainer/PanelBackground
@onready var _main_buttons: Control = $MenuContainer/MainButtons
@onready var _new_game_panel: Control = $MenuContainer/NewGamePanel
@onready var _level_select_panel: Control = $MenuContainer/LevelSelectPanel
@onready var _options_panel: Control = $MenuContainer/OptionsPanel

@onready var _new_game_button: Button = $MenuContainer/MainButtons/NewGameButton
@onready var _continue_button: Button = $MenuContainer/MainButtons/ContinueButton
@onready var _options_button: Button = $MenuContainer/MainButtons/OptionsButton
@onready var _exit_button: Button = $MenuContainer/MainButtons/ExitButton

@onready var _start_new_game_button: Button = $MenuContainer/NewGamePanel/StartNewGameButton
@onready var _level_select_button: Button = $MenuContainer/NewGamePanel/LevelSelectButton
@onready var _new_game_back_button: Button = $MenuContainer/NewGamePanel/BackFromNewGameButton

@onready var _test_floor_1_button: Button = $MenuContainer/LevelSelectPanel/TestFloor1Button
@onready var _test_floor_2_button: Button = $MenuContainer/LevelSelectPanel/TestFloor2Button
@onready var _level_select_back_button: Button = $MenuContainer/LevelSelectPanel/BackFromLevelSelectButton
@onready var _options_back_button: Button = $MenuContainer/OptionsPanel/BackFromOptionsButton

func _ready() -> void:
    _configure_background()
    _show_main()

    _new_game_button.pressed.connect(_on_new_game_pressed)
    _options_button.pressed.connect(_on_options_pressed)
    _exit_button.pressed.connect(_on_quit_pressed)

    _start_new_game_button.pressed.connect(_on_start_new_game_pressed)
    _level_select_button.pressed.connect(_on_level_select_pressed)
    _new_game_back_button.pressed.connect(_on_main_back_pressed)

    _test_floor_1_button.pressed.connect(_on_test_floor_1_pressed)
    _test_floor_2_button.pressed.connect(_on_test_floor_2_pressed)
    _level_select_back_button.pressed.connect(_on_new_game_back_pressed)
    _options_back_button.pressed.connect(_on_main_back_pressed)

func _show_main() -> void:
    _main_buttons.visible = true
    _new_game_panel.visible = false
    _level_select_panel.visible = false
    _options_panel.visible = false
    _panel_background.visible = false
    _new_game_button.grab_focus()

func _show_new_game() -> void:
    _main_buttons.visible = false
    _new_game_panel.visible = true
    _level_select_panel.visible = false
    _options_panel.visible = false
    _panel_background.visible = true
    _start_new_game_button.grab_focus()

func _show_level_select() -> void:
    _main_buttons.visible = false
    _new_game_panel.visible = false
    _level_select_panel.visible = true
    _options_panel.visible = false
    _panel_background.visible = true
    _test_floor_1_button.grab_focus()

func _show_options() -> void:
    _main_buttons.visible = false
    _new_game_panel.visible = false
    _level_select_panel.visible = false
    _options_panel.visible = true
    _panel_background.visible = true
    _options_back_button.grab_focus()

func _on_new_game_pressed() -> void:
    _show_new_game()

func _on_options_pressed() -> void:
    _show_options()

func _on_quit_pressed() -> void:
    quit_requested.emit()

func _on_start_new_game_pressed() -> void:
    mode_selected.emit(&"start")

func _on_level_select_pressed() -> void:
    _show_level_select()

func _on_main_back_pressed() -> void:
    _show_main()

func _on_new_game_back_pressed() -> void:
    _show_new_game()

func _on_test_floor_1_pressed() -> void:
    mode_selected.emit(&"test1")

func _on_test_floor_2_pressed() -> void:
    mode_selected.emit(&"test2")

func _configure_background() -> void:
    if not _background:
        return
    _background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    _background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
