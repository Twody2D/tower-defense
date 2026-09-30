extends SceneTree
## Camera speed during the start tour, per frame (checks for jerks).
## "$G" --path . --fixed-fps 60 --resolution 960x540 -s res://dev/tour_speed.gd -- <level>

var _frame: int = 0
var _last: Vector2 = Vector2.INF
var _speeds: PackedFloat32Array = PackedFloat32Array()


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 1:
		var game: Node = root.get_node("Game")
		game.set("current_level", OS.get_cmdline_user_args()[0].to_int())
		game.set("tutorial_done", true)
		for id: StringName in [&"goose", &"frog", &"fence", &"beetle", &"caterpillar", &"mole", &"fox"]:
			game.call("first_meet", id)
		change_scene_to_file("res://scenes/battle/battle.tscn")
		return false
	var battle: Node = current_scene
	if battle == null:
		return false
	var cam: Camera2D = battle.get("camera")
	var p: Vector2 = cam.get_screen_center_position()
	if _last != Vector2.INF:
		_speeds.append(p.distance_to(_last))
	_last = p
	var runner: Node = battle.get("waves")
	if _frame % 30 == 0 and _frame <= 900:
		print("frame %d: view %v, waves wait %s" % [_frame, p.round(), runner.get("wait")])
	if _frame >= 1500:
		var worst: float = 0.0
		var at: int = 0
		for i: int in range(1, _speeds.size()):
			var jump: float = absf(_speeds[i] - _speeds[i - 1])
			if jump > worst:
				worst = jump
				at = i
		var line: PackedStringArray = PackedStringArray()
		for i: int in range(0, _speeds.size(), 6):
			line.append("%d" % roundi(_speeds[i]))
		print("px/frame every 15: ", " ".join(line))
		print("max speed change between frames: %.1f px at frame %d, max speed %.1f" % [worst, at, Array(_speeds).max()])
		return true
	return false
