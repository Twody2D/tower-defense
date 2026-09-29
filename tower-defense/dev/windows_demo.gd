extends SceneTree
## Screenshots of every window over the battle, for a visual check.
## "$G" --path . --resolution 1280x720 -s res://dev/windows_demo.gd -- <out_dir> [names]
## `names`: comma-separated subset of NAMES (default: all).
## Class names that touch autoloads are not used here (see godot-web-game):
## windows are driven through call().

const NAMES: PackedStringArray = ["pause", "win", "lose", "new_defender", "new_enemy", "level_start", "settings",
		"shop", "shop_skins", "confirm"]
const EXTRA: Dictionary = {
	"level_start": "res://scenes/ui/windows/level_start_window.tscn",
	"settings": "res://scenes/ui/windows/settings_window.tscn",
	"shop": "res://scenes/ui/windows/shop_window.tscn",
	"shop_skins": "res://scenes/ui/windows/shop_window.tscn",
}
const WAIT: int = 120

var _out: String = "user://windows"
var _step: int = -1
var _wait: int = 30
var _battle: Node
var _layer: CanvasLayer
var _shown: Node
var _names: PackedStringArray = NAMES


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_names = args[1].split(",")
	DirAccess.make_dir_recursive_absolute(_out)
	change_scene_to_file("res://scenes/battle/battle.tscn")


func _process(_delta: float) -> bool:
	# Focus loss pauses and mutes the game; the shots need neither.
	AudioServer.set_bus_mute(0, false)
	if _wait > 0:
		_wait -= 1
		return false
	if _step >= 0:
		_save(_name(_step))
		_hide()
	_step += 1
	if _step >= _names.size():
		return true
	_show(_step)
	_wait = WAIT
	return false


func _name(step: int) -> String:
	return _names[step]


func _show(step: int) -> void:
	if _battle == null:
		_battle = current_scene
		_layer = CanvasLayer.new()
		_layer.layer = 50
		root.add_child(_layer)
		# The battle opens with newcomer windows (a fresh save): close them.
		var intros: Array = _battle.get("_intros")
		intros.clear()
		(_battle.get_node("Windows/NewDefender") as CanvasItem).visible = false
		(_battle.get_node("Windows/NewEnemy") as CanvasItem).visible = false
		# Shop like the mockup: grains, some upgrades, a bought skin, ad views.
		var game: Node = root.get_node("Game")
		game.set("grains", 1240)
		var levels: Dictionary = game.get("stat_levels")
		levels[&"damage"] = 4
		levels[&"attack_speed"] = 2
		levels[&"run_speed"] = 6
		var owned: Array = game.get("skins_owned")
		owned.append(&"corgi")
		var ads: Dictionary = game.get("skin_ads")
		ads[&"rabbit"] = 3
	var name: String = _name(step)
	match name:
		"pause":
			_shown = _battle.get_node("Windows/PauseWindow")
			_shown.call("open")
		"win":
			_shown = _battle.get_node("Windows/WinWindow")
			_shown.call("show_result", 2, 50)
		"lose":
			_shown = _battle.get_node("Windows/LoseWindow")
			_shown.call("show_result", true)
		"new_defender":
			_shown = _battle.get_node("Windows/NewDefender")
			var catalog: Array = _battle.get("defender_catalog")
			_shown.call("show_defender", catalog[0])
		"confirm":
			var ui: Node = root.get_node("Ui")
			_shown = ui.get("_confirm")
			ui.call("ask", "Выйти на карту? Прогресс уровня пропадёт.")
		"new_enemy":
			_shown = _battle.get_node("Windows/NewEnemy")
			_shown.call("show_enemy", load("res://data/enemies/beetle.tres"))
		_:
			var path: String = EXTRA[name]
			var scene: PackedScene = load(path) as PackedScene
			_shown = scene.instantiate()
			_layer.add_child(_shown)
			_shown.call("open")
			if name == "shop_skins":
				_shown.call("_show_tab", true)
				_shown.call("_preview_skin", &"rabbit")


func _hide() -> void:
	if _shown == null:
		return
	if _shown.get_parent() == _layer:
		_shown.queue_free()
	else:
		(_shown as CanvasItem).visible = false
	_shown = null


func _save(name: String) -> void:
	var img: Image = root.get_texture().get_image()
	var path: String = _out.path_join(name + ".png")
	img.save_png(path)
	print("saved ", path, " ", img.get_size())
