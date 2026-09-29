class_name UiFx
extends RefCounted
## Small code tweens for the interface (CODE_PROMPT: tweens, not frames):
## pop-in of windows and messages, button press spring, counter bump.


## Grows from `from` to full size with a little overshoot.
static func pop(c: Control, from: float = 0.6, time: float = 0.25) -> void:
	c.pivot_offset = c.size * 0.5
	c.scale = Vector2(from, from)
	var tw: Tween = c.create_tween()
	tw.tween_property(c, ^"scale", Vector2.ONE, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## A quick swell and back (a counter that changed).
static func bump(c: Control, amount: float = 1.25, time: float = 0.2) -> void:
	c.pivot_offset = c.size * 0.5
	var tw: Tween = c.create_tween()
	tw.tween_property(c, ^"scale", Vector2(amount, amount), time * 0.4)
	tw.tween_property(c, ^"scale", Vector2.ONE, time * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Button squeezes while held and springs back on release.
static func press_spring(b: BaseButton, squeeze: float = 0.9) -> void:
	b.button_down.connect(func() -> void: _scale_to(b, squeeze, 0.06))
	b.button_up.connect(func() -> void: _scale_to(b, 1.0, 0.18))


static func _scale_to(c: Control, value: float, time: float) -> void:
	c.pivot_offset = c.size * 0.5
	var tw: Tween = c.create_tween()
	tw.tween_property(c, ^"scale", Vector2(value, value), time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
