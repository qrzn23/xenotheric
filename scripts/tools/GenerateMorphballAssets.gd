extends SceneTree

const OUT_DIR_RES := "res://assets/sprites/player/morphball"
const FRAME_COUNT := 4
const SIZE := Vector2i(80, 80)

func _init() -> void:
	var out_dir_abs := ProjectSettings.globalize_path(OUT_DIR_RES)
	DirAccess.make_dir_recursive_absolute(out_dir_abs)

	for i in range(FRAME_COUNT):
		var frame_index := i + 1
		var img := _make_frame(i, FRAME_COUNT)
		var out_path_res := "%s/morphball-%d.png" % [OUT_DIR_RES, frame_index]
		var out_path_abs := ProjectSettings.globalize_path(out_path_res)
		var err := img.save_png(out_path_abs)
		if err != OK:
			push_error("GenerateMorphballAssets: failed writing %s (%s)" % [out_path_res, err])
		else:
			print("GenerateMorphballAssets: wrote ", out_path_res)

	quit()

func _make_frame(frame: int, total: int) -> Image:
	var img := Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var center := Vector2(SIZE.x * 0.5, SIZE.y * 0.5)
	var radius := 18.0
	var outline := 2.0

	var base := Color(0.2, 0.7, 1.0, 1.0)
	var rim := Color(0.75, 0.95, 1.0, 1.0)
	var hi := Color(1.0, 1.0, 1.0, 0.9)

	var hi_angle: float = (float(frame) / float(total)) * TAU

	for y in range(SIZE.y):
		for x in range(SIZE.x):
			var p := Vector2(x + 0.5, y + 0.5) - center
			var dist := p.length()
			if dist > radius:
				continue

			var col := base
			if dist >= radius - outline:
				col = rim
			else:
				var ang: float = atan2(p.y, p.x)
				var wrapped: float = wrapf(ang - hi_angle, -PI, PI)
				var delta: float = abs(wrapped)
				if delta < 0.35 and dist > radius * 0.55:
					col = hi

			img.set_pixel(x, y, col)

	return img
