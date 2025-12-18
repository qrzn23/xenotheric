extends Control

@export var segments: int = 10
@export var value: int = 0
@export var max_value: int = 10

@export var fill_color: Color = Color(0.28, 0.95, 0.35)
@export var empty_color: Color = Color(0.12, 0.18, 0.22, 0.9)
@export var outline_color: Color = Color(0.65, 0.85, 1.0, 0.65)

@export var segment_gap: float = 2.0
@export var outline_width: float = 1.0

func set_value(new_value: int) -> void:
    value = max(new_value, 0)
    queue_redraw()

func set_max_value(new_max: int) -> void:
    max_value = max(new_max, 0)
    queue_redraw()

func set_segments(new_segments: int) -> void:
    segments = max(new_segments, 1)
    queue_redraw()

func _draw() -> void:
    var seg_count := max(segments, 1)
    var w := size.x
    var h := size.y
    if w <= 0.0 or h <= 0.0:
        return

    var gap := max(segment_gap, 0.0)
    var total_gap := gap * float(seg_count - 1)
    var seg_w := (w - total_gap) / float(seg_count)
    if seg_w <= 0.0:
        return

    var max_val := max(max_value, 1)
    var filled := clamp(float(value) / float(max_val), 0.0, 1.0) * float(seg_count)
    var filled_full := int(floor(filled))
    var partial := filled - float(filled_full)

    var x := 0.0
    for i in range(seg_count):
        var rect := Rect2(Vector2(x, 0.0), Vector2(seg_w, h))
        draw_rect(rect, empty_color, true)

        if i < filled_full:
            draw_rect(rect, fill_color, true)
        elif i == filled_full and partial > 0.0:
            var partial_rect := Rect2(rect.position, Vector2(rect.size.x * partial, rect.size.y))
            draw_rect(partial_rect, fill_color, true)

        if outline_width > 0.0:
            draw_rect(rect, outline_color, false, outline_width)
        x += seg_w + gap

