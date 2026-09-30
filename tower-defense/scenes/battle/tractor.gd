class_name Tractor
extends Node2D
## Tractor bonus: the body (design F, fx_tractor_4f) and its two wheels on
## top of the drawn ones, turned by the distance driven (Twody: the wheels
## turn). Faces right; mirrored when it drives left.

## Wheel radius in the picture, px: a wheel turns once per 2πr driven.
@export var big_radius: float = 29.0
@export var small_radius: float = 20.0
## A wheel turns at most this much per frame, rad: past half a lug step per
## frame (8 lugs on the big one, 6 on the small) it would seem to turn back.
@export var max_turn: float = 0.25

@onready var _body: AnimatedSprite2D = $Body
@onready var _big: Sprite2D = $WheelBig
@onready var _small: Sprite2D = $WheelSmall


func start() -> void:
	visible = true
	modulate.a = 1.0
	_body.play()


## Moves to `to` (global), turning the wheels by the distance and facing
## the way it goes.
func drive_to(to: Vector2) -> void:
	var step: Vector2 = to - global_position
	global_position = to
	if absf(step.x) > 0.5:
		scale.x = -absf(scale.x) if step.x < 0.0 else absf(scale.x)
	# The mirrored parent turns the wheels the other way on screen by itself.
	var d: float = step.length() / absf(scale.y)
	_big.rotation = wrapf(_big.rotation + minf(d / big_radius, max_turn), 0.0, TAU)
	_small.rotation = wrapf(_small.rotation + minf(d / small_radius, max_turn), 0.0, TAU)


func stop() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(self, ^"modulate:a", 0.0, 0.4)
	tw.tween_callback(hide)
	_body.stop()
