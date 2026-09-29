extends SceneTree
## Map after a won level 1 (3 stars), for a visual check.
## "$G" --path . --resolution 1280x720 -s res://dev/map_demo.gd -- <out.png>

var _out: String = "user://map.png"
var _frames: int = 60
var _started: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		var game: Node = root.get_node("Game")
		game.call("reset")
		game.call("finish_level", 1, 3)
		print("open 2: ", game.call("is_level_open", 2), " last: ", game.call("last_open_level"))
		change_scene_to_file("res://scenes/map/map.tscn")
		return false
	_frames -= 1
	if _frames > 0:
		return false
	root.get_texture().get_image().save_png(_out)
	print("saved ", _out)
	return true
