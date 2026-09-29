extends SceneTree
## All effects of art/frames/fx.tres in a grid on grass, each paused on its
## middle frame, with its name. Checks sizes against the battle scale.
## "$G" --path . --resolution 1280x720 -s res://dev/fx_demo.gd -- <out.png>

var _out: String = "user://fx_demo.png"
var _frame: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	var frames: SpriteFrames = load("res://art/frames/fx.tres")
	var bg: ColorRect = ColorRect.new()
	bg.color = Color("5cae4a")
	bg.size = Vector2(1280, 720)
	root.add_child(bg)
	var names: PackedStringArray = frames.get_animation_names()
	var cols: int = 6
	var cell: Vector2 = Vector2(1280.0 / cols, 720.0 / ceilf(names.size() / float(cols)))
	for i: int in names.size():
		var at: Vector2 = cell * Vector2(i % cols, i / cols) + cell * 0.5
		var s: AnimatedSprite2D = AnimatedSprite2D.new()
		s.sprite_frames = frames
		s.animation = names[i]
		s.frame = frames.get_frame_count(names[i]) / 2
		s.position = at
		# Battle camera: 1080 world px on the 720 short side.
		s.scale = Vector2.ONE * (720.0 / 1080.0)
		root.add_child(s)
		var l: Label = Label.new()
		l.text = names[i]
		l.position = at + Vector2(-60, cell.y * 0.5 - 22)
		root.add_child(l)


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 5:
		root.get_texture().get_image().save_png(_out)
		print("saved ", _out)
		return true
	return false
