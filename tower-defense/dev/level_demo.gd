extends SceneTree
## Any campaign level in battle for screenshots: DEMO_LEVEL=<n> (default 1).
## Calls the first waves at once. "$G" --path . --resolution 1280x720 -s res://dev/level_demo.gd -- <out_prefix> <frame,...>

var _out: String = "user://level"
var _shots: Array[int] = [600]
var _frame: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_shots.clear()
		for f: String in args[1].split(","):
			_shots.append(f.to_int())


func _process(_delta: float) -> bool:
	_frame += 1
	AudioServer.set_bus_mute(0, false)
	if _frame == 1:
		var game: Node = root.get_node("Game")
		var n: int = OS.get_environment("DEMO_LEVEL").to_int()
		game.set("current_level", maxi(n, 1))
		game.set("tutorial_done", true)
		for id: StringName in [&"goose", &"frog", &"beaver", &"hive", &"fence", &"beetle", &"caterpillar", &"mole", &"crow", &"fox"]:
			game.call("first_meet", id)
		change_scene_to_file("res://scenes/battle/battle.tscn")
		return false
	var battle: Node = current_scene
	if battle == null:
		return false
	var waves: Node = battle.get("waves")
	if _frame > 60 and waves.call("in_break"):
		waves.call("call_now")
	if _frame in _shots:
		var path: String = "%s_%d.png" % [_out, _frame]
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
	return _frame >= _shots[_shots.size() - 1]
