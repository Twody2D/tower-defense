class_name FxPool
extends Node2D
## Pool of frame effects (design F, art/frames/fx.tres): hit flashes, poofs,
## splashes, build flash, upgrade sparks, dust, coins flying into a plot,
## confetti. Sprites are made once at start (no instantiate() in battle); a
## once effect goes back to the pool when its animation ends, a flying one
## when it arrives. A full pool skips the effect.

@export var frames: SpriteFrames
@export var capacity: int = 64

var _free: Array[AnimatedSprite2D] = []


func _ready() -> void:
	for i: int in capacity:
		var s: AnimatedSprite2D = AnimatedSprite2D.new()
		s.visible = false
		s.sprite_frames = frames
		s.animation_finished.connect(_release.bind(s))
		add_child(s)
		_free.append(s)


func free_count() -> int:
	return _free.size()


## Plays a once effect at a world point. `always`: keeps playing while the
## game is paused (victory confetti).
func play(anim: StringName, at: Vector2, size: float = 1.0, always: bool = false) -> AnimatedSprite2D:
	if _free.is_empty() or not frames.has_animation(anim):
		return null
	var s: AnimatedSprite2D = _free.pop_back()
	s.global_position = at
	s.scale = Vector2(size, size)
	s.process_mode = Node.PROCESS_MODE_ALWAYS if always else Node.PROCESS_MODE_INHERIT
	s.visible = true
	s.play(anim)
	s.frame = 0
	return s


## A looping effect that flies from `from` to `to` in `time` s, then is gone
## (coins into a plot). Returns its tween (null if the pool is full) to chain
## more after the arrival.
func fly(anim: StringName, from: Vector2, to: Vector2, time: float, size: float = 1.0) -> Tween:
	var s: AnimatedSprite2D = play(anim, from, size)
	if s == null:
		return null
	var tw: Tween = s.create_tween()
	tw.tween_property(s, ^"global_position", to, time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(_release.bind(s))
	return tw


func _release(s: AnimatedSprite2D) -> void:
	if not s.visible:
		return
	s.stop()
	s.visible = false
	_free.append(s)
