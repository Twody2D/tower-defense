extends SceneTree
## Main menu with today's gift already taken (no window over it), for a
## visual check: "$G" --path . --resolution 1280x720 -s res://dev/menu_demo.gd -- <out.png>

var _out: String = "user://menu.png"
var _frames: int = 60
var _started: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		root.get_node("Game").set("gift_date", Time.get_date_string_from_system())
		change_scene_to_file("res://scenes/ui/main_menu.tscn")
		return false
	_frames -= 1
	if _frames > 0:
		return false
	root.get_texture().get_image().save_png(_out)
	return true
