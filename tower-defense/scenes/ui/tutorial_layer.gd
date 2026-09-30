class_name TutorialLayer
extends CanvasLayer
## Tutorial look (design I, screen 18): the screen dims around a round hole
## over the target, a bubble with the hint and its tail, an arrow above the
## target, a highlight ring, a hand (swipe by the joystick, tap on a slot).
## Taps go through to the game. Positions are screen pixels, updated by
## the Tutorial every frame.

## Gap between the target's hole and the arrow / bubble, px.
@export var arrow_gap: float = 30.0
@export var bubble_gap: float = 20.0
## Screen edge margin and the HUD band on top the bubble keeps out of, px.
@export var margin: float = 24.0
@export var top_band: float = 360.0
## Swipe hand place: this far from the bottom-left corner (the joystick side).
@export var swipe_at: Vector2 = Vector2(90, 330)

@onready var _dim: ColorRect = %Dim
@onready var _highlight: AnimatedSprite2D = %Highlight
@onready var _arrow: AnimatedSprite2D = %Arrow
@onready var _hand: AnimatedSprite2D = %Hand
@onready var _bubble: NinePatchRect = %Bubble
@onready var _text: Label = %Text
@onready var _tail: TextureRect = %Tail

var _material: ShaderMaterial
var _key: String = ""


func _ready() -> void:
	_material = _dim.material as ShaderMaterial
	clear()


func clear() -> void:
	_key = ""
	visible = false


## One hint: `text`, the target (screen) and the hole radius; `dim` darkens
## the rest; `pointer`: &"arrow", &"tap" (hand on the target), &"swipe"
## (hand by the joystick) or &"". Call every frame with the new target.
func point(text: String, target: Vector2, radius: float, dim: bool, pointer: StringName, ring: bool = false) -> void:
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var key: String = text + String(pointer)
	if key != _key:
		_key = key
		_text.text = text
		visible = true
		_bubble.reset_size()
		UiFx.pop(_bubble, 0.7, 0.2)
		_play(_arrow, &"tut_arrow", pointer == &"arrow")
		_play(_hand, &"tut_hand_tap" if pointer == &"tap" else &"tut_hand_swipe", pointer == &"tap" or pointer == &"swipe")
		_play(_highlight, &"tut_highlight", ring)
	# Target off screen: only the bubble, under the HUD, until it comes into view.
	var on_screen: bool = Rect2(Vector2.ZERO, screen).grow(-40.0).has_point(target)
	_arrow.visible = pointer == &"arrow" and on_screen
	_highlight.visible = ring and on_screen
	_hand.visible = pointer == &"swipe" or (pointer == &"tap" and on_screen)
	_dim.visible = dim and on_screen
	if not on_screen:
		_bubble.position = Vector2((screen.x - _bubble.size.x) * 0.5, top_band)
		_tail.visible = false
		return
	_tail.visible = true
	_material.set_shader_parameter(&"size", screen)
	_material.set_shader_parameter(&"centre", target)
	_material.set_shader_parameter(&"radius", radius)
	_highlight.position = target
	_highlight.scale = Vector2.ONE * (radius * 2.0 / 256.0)
	_arrow.position = target - Vector2(0, radius + arrow_gap + 48.0)
	if pointer == &"swipe":
		_hand.position = Vector2(swipe_at.x + 192.0, screen.y - swipe_at.y + 96.0)
	else:
		_hand.position = target + Vector2(50, 60)
	_place_bubble(target, radius, screen, pointer == &"arrow")


## Above the target (over the arrow) when there is room under the HUD,
## otherwise below it with the tail turned up.
func _place_bubble(target: Vector2, radius: float, screen: Vector2, arrow: bool) -> void:
	var s: Vector2 = _bubble.size
	var lift: float = radius + bubble_gap + (arrow_gap + 96.0 if arrow else 0.0)
	var above: bool = target.y - lift - s.y - 40.0 > top_band
	var y: float = target.y - lift - s.y - 40.0 if above else target.y + radius + bubble_gap + 40.0
	y = clampf(y, margin, screen.y - s.y - margin)
	var x: float = clampf(target.x - s.x * 0.5, margin, screen.x - s.x - margin)
	_bubble.position = Vector2(x, y)
	var tail_x: float = clampf(target.x - x - 24.0, 36.0, s.x - 84.0)
	_tail.flip_v = not above
	_tail.position = Vector2(tail_x, s.y - 5.0 if above else -35.0)


static func _play(sprite: AnimatedSprite2D, anim: StringName, on: bool) -> void:
	sprite.visible = on
	if on:
		sprite.play(anim)
	else:
		sprite.stop()
