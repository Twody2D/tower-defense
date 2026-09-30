extends SceneTree
## Helper bonus motion per frame (checks for jerks and run/idle flicker): the
## hero runs right, stops, runs left past the helper, then up.
## "$G" --path . --fixed-fps 60 --resolution 960x540 -s res://dev/helper_trace.gd

const PLAN: Array[Vector3] = [  # joystick x, y, until frame
	Vector3(0, 0, 80), Vector3(1, 0, 200), Vector3(0, 0, 300), Vector3(-1, 0, 460),
	Vector3(0, -1, 560), Vector3(0, 0, 660)]

var _frame: int = 0
var _last: Vector2 = Vector2.INF
var _last_speed: float = 0.0
var _worst: float = 0.0
var _switches: int = 0
var _anim: StringName = &""


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 1:
		var game: Node = root.get_node("Game")
		game.set("current_level", 4)
		game.set("tutorial_done", true)
		for id: StringName in [&"goose", &"frog", &"fence", &"beetle", &"caterpillar", &"mole", &"fox"]:
			game.call("first_meet", id)
		change_scene_to_file("res://scenes/battle/battle.tscn")
		return false
	var battle: Node = current_scene
	if battle == null:
		return false
	var hero: Node2D = battle.get("hero")
	var helper: Node2D = battle.get("helper")
	var bonuses: Node = battle.get("bonuses")
	if _frame == 40:
		bonuses.call("apply", &"helper", 1)
	var joy: Vector2 = Vector2.ZERO
	for step: Vector3 in PLAN:
		if _frame < step.z:
			joy = Vector2(step.x, step.y)
			break
	hero.set("joystick", joy)
	if _frame > 45:
		var p: Vector2 = helper.global_position
		if _last != Vector2.INF:
			var speed: float = p.distance_to(_last)
			if _frame > 50:
				_worst = maxf(_worst, absf(speed - _last_speed))
			_last_speed = speed
		_last = p
		var sprite: AnimatedSprite2D = helper.get_node("Sprite")
		if sprite.animation != _anim and (sprite.animation == &"run" or _anim == &"run"):
			_switches += 1
		_anim = sprite.animation
		if _frame % 20 == 0:
			print("frame %d: hero %v helper %v %s flip %s" % [_frame, hero.global_position.round(), p.round(), _anim, sprite.flip_h])
	if _frame >= int(PLAN[PLAN.size() - 1].z):
		print("max speed change %.2f px/frame, run<->other switches %d" % [_worst, _switches])
		return true
	return false
