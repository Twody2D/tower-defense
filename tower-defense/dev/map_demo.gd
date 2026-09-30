extends SceneTree
## Map for a visual check: <passed> levels won (3 stars; default 1), the open
## crops ripe. Shots at the given frames (scroll with the level at the start).
## The real save file is put back at the end.
## "$G" --path . --resolution 1280x720 -s res://dev/map_demo.gd -- <out_prefix> [passed] [frame,frame,...] [window]
## `window`: a map window export to open at frame 10 (e.g. shop_window).

const SAVE_PATH := "user://save.json"

var _out: String = "user://map"
var _passed: int = 1
var _shots: Array[int] = [60]
var _window: String = ""
var _frame: int = 0
var _backup: PackedByteArray = PackedByteArray()
var _had_save: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_passed = args[1].to_int()
	if args.size() > 2:
		_shots.clear()
		for f: String in args[2].split(","):
			_shots.append(f.to_int())
	if args.size() > 3:
		_window = args[3]
	_had_save = FileAccess.file_exists(SAVE_PATH)
	if _had_save:
		_backup = FileAccess.get_file_as_bytes(SAVE_PATH)


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 1:
		var game: Node = root.get_node("Game")
		game.call("reset")
		for n: int in range(1, _passed + 1):
			game.call("finish_level", n, 3 if n % 3 else 2)
		# Every open crop planted long ago: ripe.
		game.call("start_harvest", int(Time.get_unix_time_from_system()) - 6 * 3600)
		change_scene_to_file("res://scenes/map/map.tscn")
		return false
	if _frame == 10 and _window != "":
		var map: Node = current_scene
		map.call("_open", map.get(_window))
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
