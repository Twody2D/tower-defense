extends SceneTree
## Level 1 tutorial steps for screenshots (a fresh save).
## "$G" --path . --resolution 540x960 -s res://dev/tutorial_demo.gd -- <out_prefix>
## Shots: move, plot, pick, build, coins.

var _out: String = "user://tut"
var _frame: int = 0
var _plot: Node2D


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if OS.get_environment("DEMO_LOCALE") != "":
		TranslationServer.set_locale(OS.get_environment("DEMO_LOCALE"))
	change_scene_to_file("res://scenes/battle/battle.tscn")


func _shot(name: String) -> void:
	var path: String = "%s_%s.png" % [_out, name]
	root.get_texture().get_image().save_png(path)
	print("saved ", path)


func _process(_delta: float) -> bool:
	_frame += 1
	var battle: Node = current_scene
	if battle == null:
		return false
	AudioServer.set_bus_mute(0, false)
	var game: Node = root.get_node("Game")
	var hero: Node2D = battle.get("hero")
	if _frame == 2:
		game.set("tutorial_done", false)
		for id: StringName in [&"goose", &"beetle", &"fox"]:
			game.call("first_meet", id)
	if _frame == 420:
		_shot("1_move")
		hero.set("joystick", Vector2(1, 0))
	if _frame == 470:
		hero.set("joystick", Vector2.ZERO)
	if _frame == 500:
		_shot("2_plot")
		var tut: Node = battle.get("tutorial")
		_plot = tut.call("_free_plot")
		hero.global_position = _plot.global_position
	if _frame == 530:
		_shot("3_pick")
		var hud: Node = battle.get("hud")
		var menu: Node = hud.get("radial_menu")
		var level: Node = battle.get("level")
		var data: Resource = level.get("data")
		var defenders: Array = data.get("defenders")
		menu.call("_on_slot_picked", defenders[0])
		battle.call("_on_defender_picked", _plot, defenders[0])
	if _frame == 545:
		_shot("4_build")
	if _frame == 640:
		var coins: Node = battle.get("coins")
		coins.call("drop", hero.global_position + Vector2(260, 120), 5)
	if _frame == 660:
		_shot("5_coins")
	return _frame >= 660
