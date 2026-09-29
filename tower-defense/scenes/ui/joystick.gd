class_name Joystick
extends Control
## Floating joystick (design H: base 256, stick 128, stick travel 64 at 1080 →
## ×2/3 in our 720 base). Appears under the finger anywhere on the screen
## except over HUD buttons (group "hud_blocker"), half transparent.
## Mouse works too (emulate_touch_from_mouse).

signal changed(dir: Vector2)

## Stick travel, px (64 × 2/3).
@export var travel: float = 43.0
@export var idle_alpha: float = 0.55

var dir: Vector2 = Vector2.ZERO

var _touch: int = -1
var _center: Vector2 = Vector2.ZERO

@onready var _base: TextureRect = $Base
@onready var _stick: TextureRect = $Base/Stick


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base.visible = false
	_base.modulate.a = idle_alpha


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		if touch.pressed and _touch == -1 and not _blocked(touch.position):
			_touch = touch.index
			_center = touch.position
			_base.visible = true
			_base.position = _center - _base.size * 0.5
			_set_stick(Vector2.ZERO)
		elif not touch.pressed and touch.index == _touch:
			release()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event
		if drag.index == _touch:
			_set_stick(drag.position - _center)


## Lets go of the stick (also on pause and scene change).
func release() -> void:
	_touch = -1
	_base.visible = false
	_set_stick(Vector2.ZERO)


func _set_stick(offset: Vector2) -> void:
	var o: Vector2 = offset.limit_length(travel)
	_stick.position = _base.size * 0.5 - _stick.size * 0.5 + o
	var d: Vector2 = o / travel
	if d.length() < 0.15:
		d = Vector2.ZERO
	if d != dir:
		dir = d
		changed.emit(dir)


func _blocked(pos: Vector2) -> bool:
	for node: Node in get_tree().get_nodes_in_group(&"hud_blocker"):
		var c: Control = node as Control
		if c != null and c.is_visible_in_tree() and c.get_global_rect().has_point(pos):
			return true
	return false
