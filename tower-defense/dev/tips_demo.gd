extends SceneTree
## Level 2 tips (fence, then upgrade) for screenshots.
## "$G" --path . --resolution 1280x720 -s res://dev/tips_demo.gd -- <out_prefix>

var _out: String = "user://tips"
var _frame: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if OS.get_environment("DEMO_LOCALE") != "":
		TranslationServer.set_locale(OS.get_environment("DEMO_LOCALE"))


func _shot(name: String) -> void:
	var path: String = "%s_%s.png" % [_out, name]
	root.get_texture().get_image().save_png(path)
	print("saved ", path)


func _process(_delta: float) -> bool:
	_frame += 1
	AudioServer.set_bus_mute(0, false)
	if _frame == 1:
		# Autoloads exist only now: pick level 2, then load the battle.
		var game: Node = root.get_node("Game")
		game.set("current_level", 2)
		game.set("tutorial_done", true)
		for id: StringName in [&"goose", &"fence", &"beetle", &"caterpillar", &"fox"]:
			game.call("first_meet", id)
		change_scene_to_file("res://scenes/battle/battle.tscn")
		return false
	var battle: Node = current_scene
	if battle == null:
		return false
	if _frame == 430:
		_shot("fence")
		# Skip the fence tip; a goose with coins for level 2 shows the upgrade tip.
		var tut: Node = battle.get("tutorial")
		tut.set("_left", 0.0)
		var level: Node = battle.get("level")
		var plots: Array = level.call("plots")
		for p: Node in plots:
			if not p.get("fence_plot"):
				p.call("prebuild", load("res://data/defenders/goose.tres"), 1)
				break
		var state: Object = battle.get("state")
		state.call("add_coins", 30)
	if _frame == 470:
		_shot("upgrade")
	return _frame >= 470
