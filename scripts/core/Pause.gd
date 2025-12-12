extends Node

signal paused_changed(active)

var is_paused := false

func toggle_pause() -> void:
    is_paused = !is_paused
    get_tree().paused = is_paused
    paused_changed.emit(is_paused)

func unpause() -> void:
    if is_paused:
        toggle_pause()
