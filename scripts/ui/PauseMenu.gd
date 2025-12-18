extends CanvasLayer

signal continue_requested()
signal main_menu_requested()
signal quit_requested()

@onready var _continue_button: Button = $Overlay/Panel/VBox/ContinueButton
@onready var _main_menu_button: Button = $Overlay/Panel/VBox/MainMenuButton
@onready var _quit_button: Button = $Overlay/Panel/VBox/QuitButton

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    _continue_button.pressed.connect(_on_continue_pressed)
    _main_menu_button.pressed.connect(_on_main_menu_pressed)
    _quit_button.pressed.connect(_on_quit_pressed)
    _continue_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        _on_continue_pressed()

func _on_continue_pressed() -> void:
    continue_requested.emit()

func _on_main_menu_pressed() -> void:
    main_menu_requested.emit()

func _on_quit_pressed() -> void:
    quit_requested.emit()

