extends SceneTree
## Boss on the field for HUD screenshots: banner, HP bar, edge pointer, +N.
## "$G" --path . --resolution 540x960 -s res://dev/boss_demo.gd -- <out_prefix> <frame,frame,...>

var _out: String = "user://boss"
var _shots: Array[int] = []
var _frame: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		for f: String in args[1].split(","):
			_shots.append(f.to_int())
	change_scene_to_file("res://scenes/battle/battle.tscn")


func _process(_delta: float) -> bool:
	_frame += 1
	var battle: Node = current_scene
	if battle == null:
		return false
	AudioServer.set_bus_mute(0, false)
	if _frame == 2:
		for id: StringName in [&"goose", &"beetle", &"fox"]:
			root.get_node("Game").call("first_meet", id)
	if _frame == 240:
		var enemies: Node = battle.get("enemies")
		var id: int = enemies.call("spawn", load("res://data/enemies/fox.tres"), 0.12, 0)
		var i: int = enemies.call("index_of", id)
		enemies.call("damage", i, 60.0)
		var coins: Node = battle.get("coins")
		coins.emit_signal("collected", 3)
	if _frame in _shots:
		var path: String = "%s_%d.png" % [_out, _frame]
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
	return _frame >= _shots[_shots.size() - 1]
