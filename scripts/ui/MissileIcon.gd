extends Control

@export var fill_color: Color = Color(0.95, 0.58, 0.2, 1)
@export var outline_color: Color = Color(0.65, 0.85, 1, 0.55)
@export var outline_width: float = 1.0

func _draw() -> void:
    var w: float = size.x
    var h: float = size.y
    if w <= 0.0 or h <= 0.0:
        return

    var body_h: float = maxf(4.0, h * 0.45)
    var body_y: float = (h - body_h) * 0.5
    var nose_w: float = maxf(4.0, w * 0.28)
    var body_w: float = maxf(0.0, w - nose_w)

    var body_rect: Rect2 = Rect2(Vector2(0.0, body_y), Vector2(body_w, body_h))
    draw_rect(body_rect, fill_color, true)

    var nose := PackedVector2Array([
        Vector2(body_w, body_y),
        Vector2(w, h * 0.5),
        Vector2(body_w, body_y + body_h),
    ])
    draw_colored_polygon(nose, fill_color)

    # Tail notch.
    var tail_w: float = maxf(2.0, body_w * 0.18)
    var tail_rect: Rect2 = Rect2(Vector2(0.0, body_y + body_h * 0.2), Vector2(tail_w, body_h * 0.6))
    draw_rect(tail_rect, Color(fill_color.r * 0.75, fill_color.g * 0.75, fill_color.b * 0.75, fill_color.a), true)

    if outline_width > 0.0:
        draw_rect(body_rect, outline_color, false, outline_width)
        draw_polyline(nose, outline_color, outline_width, true)

