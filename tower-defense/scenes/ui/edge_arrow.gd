class_name EdgeArrow
extends Control
## Pointer at the screen edge (design H): a round badge with who is there
## (the boss, a pest) and an arrow turned towards it.

## Distance from the screen edge to the badge centre, px; from the top more:
## the counters, the wave line and the boss bar live there.
@export var margin: float = 110.0
@export var top_margin: float = 300.0

@onready var _icon: TextureRect = %Icon
@onready var _arrow: AnimatedSprite2D = %Arrow


## `target` and `screen` are in HUD (screen) coordinates.
func point(target: Vector2, screen: Rect2, icon: Texture2D) -> void:
	_icon.texture = icon
	var inner: Rect2 = screen.grow_individual(-margin, -top_margin, -margin, -margin)
	var centre: Vector2 = inner.get_center()
	var dir: Vector2 = (target - centre).normalized()
	# From the centre towards the target until the inner rectangle's edge.
	var tx: float = INF if is_zero_approx(dir.x) else (inner.size.x * 0.5) / absf(dir.x)
	var ty: float = INF if is_zero_approx(dir.y) else (inner.size.y * 0.5) / absf(dir.y)
	var at: Vector2 = centre + dir * minf(tx, ty)
	position = at - size * 0.5
	_arrow.rotation = dir.angle()
	visible = true
