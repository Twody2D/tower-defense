extends SceneTree
## Whole level from above, one shot per level, to check roads, plots, decor.
## "$G" --path . --resolution 960x960 -s res://dev/level_overview.gd -- <out_dir> [2,3,...]

var _out: String = "user://levels"
var _levels: Array[int] = []
var _i: int = 0
var _frame: int = 0
var _level: Node2D


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		for s: String in args[1].split(","):
			_levels.append(s.to_int())
	else:
		for n: int in range(1, 13):
			_levels.append(n)
	DirAccess.make_dir_recursive_absolute(_out)


func _process(_delta: float) -> bool:
	if _level == null:
		if _i >= _levels.size():
			return true
		var packed: PackedScene = load("res://scenes/levels/level_%02d.tscn" % _levels[_i]) as PackedScene
		_level = packed.instantiate() as Node2D
		root.add_child(_level)
		var cam: Camera2D = Camera2D.new()
		var b: Rect2 = _level.call("bounds")
		cam.position = b.get_center()
		var z: float = minf(root.get_visible_rect().size.x / b.size.x, root.get_visible_rect().size.y / b.size.y)
		cam.zoom = Vector2(z, z)
		_level.add_child(cam)
		cam.make_current()
		_frame = 0
		return false
	_frame += 1
	if _frame == 10:
		var path: String = _out.path_join("level_%02d.png" % _levels[_i])
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
		_level.queue_free()
		_level = null
		_i += 1
	return false
