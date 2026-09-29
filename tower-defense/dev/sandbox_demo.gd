extends SceneTree
## Sandbox screenshots: every defender built on its own plot (levels 1–3),
## the fence on the road, caterpillar waves. Saves <out>_N.png at given frames.
## "$G" --path . --resolution 1280x720 -s res://dev/sandbox_demo.gd -- <out_prefix> <frame,frame,...>

var _out: String = "user://sandbox"
var _shots: PackedInt32Array = PackedInt32Array([900])
var _frame: int = 0
var _battle: Node
var _start: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_shots = PackedInt32Array()
		for s: String in args[1].split(","):
			_shots.append(s.to_int())
	Engine.time_scale = 2.0
	change_scene_to_file("res://dev/battle_sandbox.tscn")


func _process(_delta: float) -> bool:
	_frame += 1
	if _battle == null:
		_battle = current_scene
		_start = _frame
		if _battle == null:
			return false
	if _frame == _start:
		_build_all()
	if _frame in _shots:
		var img: Image = root.get_texture().get_image()
		var path: String = "%s_%d.png" % [_out, _frame]
		img.save_png(path)
		print("saved ", path)
	return _frame >= _shots[_shots.size() - 1]


func _build_all() -> void:
	var level: Node = _battle.get("level")
	var catalog: Array = _battle.get("defender_catalog")
	var plots: Array = level.call("plots")
	var hero: Node2D = _battle.get("hero")
	var n: int = 0
	for p: Variant in plots:
		var plot: Node2D = p
		var fence_plot: bool = plot.get("fence_plot")
		var lv: int = 1 + n % 3
		if fence_plot:
			plot.set("level", 1)
			var fence: Node = plot.get("fence")
			fence.call("set_level", 1)
		else:
			plot.call("choose", catalog[n % catalog.size()])
			plot.set("level", lv)
			var defender: Node = plot.get("defender")
			defender.call("set_level", lv)
			n += 1
		plot.call("_refresh")
	hero.global_position = Vector2(1150, 700)
