class_name Butterfly
extends AnimatedSprite2D
## A butterfly over the menu yard (design L): flaps (map.tres "butterfly")
## along a figure-eight around `centre` — x by cos, y by sin of twice the angle.

@export var centre: Vector2 = Vector2.ZERO
@export var radius: Vector2 = Vector2(120, 40)
## Angle speed, rad/s, and start angle.
@export var speed: float = 0.8
@export var phase: float = 0.0

var _angle: float = 0.0


func _ready() -> void:
	_angle = phase
	play(&"butterfly")
	_process(0.0)


func _process(delta: float) -> void:
	var before: Vector2 = position
	_angle += speed * delta
	position = centre + Vector2(cos(_angle) * radius.x, sin(_angle * 2.0) * radius.y)
	if absf(position.x - before.x) > 0.01:
		flip_h = position.x < before.x
