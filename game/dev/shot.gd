extends SceneTree
## Screenshot of the running game for a visual check.
## "$G" --path . --resolution 1280x720 -s res://dev/shot.gd -- <out.png> [frames] [scene]
## Starts the scene (default: main scene), waits, saves the viewport.

var _out: String = "user://shot.png"
var _frames: int = 90


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	if args.size() > 1:
		_frames = args[1].to_int()
	var scene: String = ProjectSettings.get_setting("application/run/main_scene")
	if args.size() > 2:
		scene = args[2]
	change_scene_to_file(scene)


func _process(_delta: float) -> bool:
	_frames -= 1
	if _frames > 0:
		return false
	var img: Image = root.get_texture().get_image()
	img.save_png(_out)
	print("saved ", _out, " ", img.get_size())
	return true
