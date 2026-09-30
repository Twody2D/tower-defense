extends SceneTree
## Store screenshots (Yandex: 1920×1080, at least 70% gameplay, battles
## first). Mid-game progress lives in memory; the real save file is put back
## at the end. In battles every plot already has a defender, a few waves are
## called at once, the fox comes early.
##
## Run (a window opens for ~1.5 min, do not touch it):
##   "$G" --path . --resolution 1920x1080 -s res://dev/store_shots.gd -- <out_dir> [ru|en]
## Output: <out_dir>/shot_*.png

## [name, kind, level, seconds to wait]
const SHOTS: Array[Array] = [
	["1_battle_farm", "battle", 5, 13.0],
	["2_battle_lake", "battle", 12, 13.0],
	["3_battle_wheat", "battle", 8, 13.0],
	["4_parcel", "parcel", 7, 9.0],
	["5_map", "map", 0, 1.5],
	["6_shop", "shop", 0, 1.5],
	["7_menu", "menu", 0, 1.5],
]
const SAVE_PATH := "user://save.json"
## Waves called at once at these battle seconds; the fox at FOX_AT.
const CALLS: Array[float] = [0.3, 2.5, 5.0]
const FOX_AT := 0.5

var _out: String = "user://store"
var _lang: String = "ru"
var _game: Node
var _backup: PackedByteArray = PackedByteArray()
var _had_save: bool = false
var _index: int = -1
var _t: float = 0.0
var _setup_done: bool = false
var _calls: int = 0
var _fox: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_lang = args[1]
	DirAccess.make_dir_recursive_absolute(_out)
	_had_save = FileAccess.file_exists(SAVE_PATH)
	if _had_save:
		_backup = FileAccess.get_file_as_bytes(SAVE_PATH)


func _process(delta: float) -> bool:
	AudioServer.set_bus_mute(0, true)
	if _game == null:
		_game = root.get_node(^"Game")
		_game.call(&"from_dict", {
			"level_stars": [3, 3, 3, 2, 3, 3, 2, 3, 2, 3, 2, 0],
			"grains": 1250, "grains_earned": 4800,
			"stat_levels": {"damage": 4, "attack_speed": 3, "run_speed": 3, "magnet": 2},
			"skins_owned": ["raccoon", "corgi", "pig"], "skin": "raccoon",
			"seen": ["goose", "frog", "beaver", "hive", "fence", "beetle", "caterpillar", "mole", "crow", "fox"],
			"tutorial_done": true, "sound_on": false, "music_on": false,
		})
		TranslationServer.set_locale(_lang)
		_start(0)
		return false
	_t += delta
	var shot: Array = SHOTS[_index]
	var battle: Node = current_scene
	if battle == null:
		return false
	var kind: String = shot[1]
	if kind == "battle" or kind == "parcel":
		_play(battle, kind)
	elif kind == "shop" and not _setup_done and _t > 0.2:
		_setup_done = true
		battle.call(&"_open", battle.get(&"shop_window"))
		# The skins tab: the characters sell the game better than the stats.
		var shop: Node = battle.get_child(battle.get_child_count() - 1)
		shop.call(&"_show_tab", true)
	var wait: float = shot[3]
	if _t >= wait:
		var path: String = _out.path_join("shot_%s.png" % shot[0])
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
		if _index + 1 >= SHOTS.size():
			_restore_save()
			return true
		_start(_index + 1)
	return false


func _start(index: int) -> void:
	_index = index
	_t = 0.0
	_setup_done = false
	_calls = 0
	_fox = false
	paused = false
	var shot: Array = SHOTS[index]
	var kind: String = shot[1]
	var number: int = shot[2]
	match kind:
		"battle", "parcel":
			_game.set(&"current_level", number)
			change_scene_to_file.call_deferred("res://scenes/battle/battle.tscn")
		"map":
			change_scene_to_file.call_deferred("res://scenes/map/map.tscn")
		_:
			change_scene_to_file.call_deferred("res://scenes/ui/main_menu.tscn")


## A busy fight: defenders on every plot, fences up, waves called early, the
## fox on the way; the hero stands among the plots.
func _play(battle: Node, kind: String) -> void:
	var level: Node = battle.get(&"level")
	if level == null:
		return
	if not _setup_done:
		_setup_done = true
		var hud: Node = battle.get(&"hud")
		(hud.get_node(^"DebugLabel") as CanvasItem).visible = false
		var k: int = 0
		for plot: Node2D in level.call(&"plots"):
			if plot.get(&"locked"):
				continue
			if plot.get(&"fence_plot"):
				plot.set(&"level", 2)
				var fence: Node = plot.get(&"fence")
				fence.call(&"set_level", 2)
				plot.call(&"_refresh")
				continue
			var options: Array = plot.get(&"options")
			plot.call(&"prebuild", options[k % options.size()], 2 + k % 2)
			k += 1
		var state: Object = battle.get(&"state")
		state.set(&"coins", 186)
		var hero: Node2D = battle.get(&"hero")
		var plots: Array = level.call(&"plots")
		var p: Node2D = plots[plots.size() / 2]
		hero.global_position = p.global_position + Vector2(0, 150)
	var waves: Node = battle.get(&"waves")
	if _calls < CALLS.size() and _t >= CALLS[_calls]:
		_calls += 1
		waves.call(&"call_now")
	if kind == "battle" and not _fox and _t >= FOX_AT:
		_fox = true
		var enemies: Node = battle.get(&"enemies")
		enemies.call(&"spawn", load("res://data/enemies/fox.tres"), 1.0, 0)
	if kind == "parcel" and _t >= 7.5 and not paused:
		battle.call(&"_on_parcel_picked")


func _restore_save() -> void:
	if _had_save:
		var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		f.store_buffer(_backup)
		f.close()
	elif FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("save restored")
