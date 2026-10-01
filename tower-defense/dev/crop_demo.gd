extends SceneTree
## The hero at a battle crop (its harvest pose, the shake, fruits, coins).
## Shots at the given frames of level <n> (default 1) with the hero next to
## crop 1; `skin`: the hero skin set (raccoon, corgi, pig, rabbit, chicken).
## The real save file is put back at the end.
## "$G" --path . --resolution 1280x720 -s res://dev/crop_demo.gd -- <out_prefix> [level] [frame,...] [skin]

const SAVE_PATH := "user://save.json"

var _out: String = "user://crop"
var _level: int = 1
var _shots: Array[int] = [60]
var _skin: String = ""
var _frame: int = 0
var _battle: Node
var _backup: PackedByteArray = PackedByteArray()
var _had_save: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_level = args[1].to_int()
	if args.size() > 2:
		_shots.clear()
		for f: String in args[2].split(","):
			_shots.append(f.to_int())
	if args.size() > 3:
		_skin = args[3]
	_had_save = FileAccess.file_exists(SAVE_PATH)
	if _had_save:
		_backup = FileAccess.get_file_as_bytes(SAVE_PATH)


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 1:
		var game: Node = root.get_node("Game")
		game.set("current_level", _level)
		# No "new defender / pest" windows over the shots.
		for id: StringName in [&"goose", &"frog", &"hive", &"beaver", &"fence",
				&"beetle", &"caterpillar", &"mole", &"crow", &"fox"]:
			game.call("first_meet", id)
		change_scene_to_file("res://scenes/battle/battle.tscn")
		return false
	if _battle == null:
		_battle = current_scene
		return false
	var hero: Node2D = _battle.get("hero")
	if _frame == 3 and _skin != "":
		var frames: SpriteFrames = load("res://art/frames/hero_%s.tres" % _skin)
		hero.call("set_skin", frames, hero.get("projectile_texture"))
	var level: Node = _battle.get("level")
	var crops: Array = level.call("crops")
	var crop: Node2D = crops[0]
	# Next to the crop 40 frames before the first shot (after the camera tour).
	if _frame >= _shots[0] - 40:
		hero.global_position = crop.global_position + Vector2(-70, 6)
	if _frame in _shots:
		var path: String = "%s_%d.png" % [_out, _frame]
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
	if _frame >= _shots[_shots.size() - 1]:
		_restore()
		return true
	return false


func _restore() -> void:
	if _had_save:
		var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		f.store_buffer(_backup)
		f.close()
	elif FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
