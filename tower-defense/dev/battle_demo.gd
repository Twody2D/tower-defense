extends SceneTree
## Scripted battle for screenshots: the hero builds on the plot, then stands by
## the road while waves come. Saves <out>_N.png at the given frames.
## "$G" --path . --resolution 1280x720 -s res://dev/battle_demo.gd -- <out_prefix> <frame,frame,...>

var _out: String = "user://demo"
var _shots: PackedInt32Array = PackedInt32Array([600])
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
	change_scene_to_file("res://scenes/battle/battle.tscn")


func _process(_delta: float) -> bool:
	_frame += 1
	if _battle == null:
		_battle = current_scene
		_start = _frame
		if _battle == null:
			return false
	var hero: Node2D = _battle.get("hero")
	var level: Node = _battle.get("level")
	var state: RefCounted = _battle.get("state")
	var plots: Array = level.call("plots")
	var plot: Node2D = plots[0]
	if _frame == _start:
		state.call("add_coins", 25)
		hero.global_position = plot.global_position
	# The radial menu is open now: pick the first defender in it.
	if _frame == _start + 40:
		var hud: Node = _battle.get("hud")
		var menu: Node = hud.get("radial_menu")
		var catalog: Array = _battle.get("defender_catalog")
		menu.call("_on_slot_picked", catalog[0])
	if _frame == 200:
		var road: Curve2D = level.call("road_curve")
		hero.global_position = road.sample_baked(road.get_baked_length() * 0.12) + Vector2(-90, 0)
	if _frame in _shots:
		var img: Image = root.get_texture().get_image()
		var path: String = "%s_%d.png" % [_out, _frame]
		img.save_png(path)
		print("saved ", path)
	return _frame >= _shots[_shots.size() - 1]
