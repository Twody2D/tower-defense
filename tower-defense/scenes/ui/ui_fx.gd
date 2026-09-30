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


## Icons fly from `from` to `to` (global points) in a small arc and turn from
## `first` into `then` half way (a product becomes grains); `done` runs when
## the last one lands. Made in menus only, never in battle.
static func fly_icons(layer: Control, from: Vector2, to: Vector2, first: Texture2D, then: Texture2D,
		count: int, icon_size: float = 72.0, done: Callable = Callable()) -> void:
	for i: int in count:
		var r: TextureRect = TextureRect.new()
		r.texture = first
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.top_level = true
		r.size = Vector2(icon_size, icon_size)
		layer.add_child(r)
		var half: Vector2 = r.size * 0.5
		var start: Vector2 = from + Vector2(randf_range(-40.0, 40.0), randf_range(-30.0, 30.0)) - half
		var end: Vector2 = to - half
		r.global_position = start
		var mid: Vector2 = start.lerp(end, 0.4) + Vector2(0, -90)
		var tw: Tween = r.create_tween()
		tw.tween_interval(i * 0.07)
		tw.tween_property(r, ^"global_position", mid, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func() -> void: r.texture = then)
		tw.tween_property(r, ^"global_position", end, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(r.queue_free)
		if i == count - 1 and done.is_valid():
			tw.tween_callback(done)
