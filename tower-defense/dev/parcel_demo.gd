extends SceneTree
## Parcel and bonuses for screenshots: the fall, the pick window, then all
## bonuses at once (rings, auras, clouds, helper, gold rain) and the tractor.
## "$G" --path . --resolution 540x960 -s res://dev/parcel_demo.gd -- <out_prefix> <frame,frame,...>
## Useful frames: 380 falling, 460 landed, 500 window, 560 / 640 bonuses, 690 / 740 tractor.

var _out: String = "user://parcel"
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
	var game: Node = root.get_node("Game")
	if _frame == 2:
		for id: StringName in [&"goose", &"beetle", &"caterpillar", &"fox"]:
			game.call("first_meet", id)
		# A goose to raise with the free upgrade.
		var level: Node = battle.get("level")
		var plots: Array = level.call("plots")
		for p: Node in plots:
			if not p.get("fence_plot") and not p.get("locked"):
				p.call("prebuild", load("res://data/defenders/goose.tres"), 1)
				break
	var parcel: Node2D = battle.get("parcel")
	var hero: Node2D = battle.get("hero")
	if _frame == 360:
		battle.call("_drop_parcel")
		battle.call("_drop_gift")
	if _frame == 470:
		hero.global_position = parcel.global_position
	if _frame == 510:
		var window: Node = battle.get("parcel_window")
		window.call("_on_taken", &"rage")
	if _frame == 520:
		var bonuses: Node = battle.get("bonuses")
		for id: StringName in [&"super_magnet", &"sleepy_rain", &"helper", &"gold_rain", &"upgrade"]:
			bonuses.call("apply", id, 3)
		var enemies: Node = battle.get("enemies")
		for k: int in 12:
			enemies.call("spawn", load("res://data/enemies/beetle.tres"), 1.0, 0)
	if _frame == 650:
		var b: Node = battle.get("bonuses")
		b.call("apply", &"tractor", 3)
	if _frame in _shots:
		var path: String = "%s_%d.png" % [_out, _frame]
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
	return _frame >= _shots[_shots.size() - 1]
