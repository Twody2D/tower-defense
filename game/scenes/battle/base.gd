class_name CarrotBase
extends Node2D
## Carrot bed at the road end (design: bed 256 with 20 slots). Shows how many
## carrots are left; the battle keeps the number in BattleState.

@export var slots: int = 20
@export var bed_size: Vector2 = Vector2(220, 150)

var carrots: int = 20


func set_carrots(n: int) -> void:
	carrots = n
	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = Rect2(-bed_size * 0.5, bed_size)
	draw_rect(Rect2(rect.position + Vector2(6, 10), rect.size), Color(0, 0, 0, 0.18))
	draw_rect(rect, Color("8d5a3b"))
	draw_rect(rect.grow(-12), Color("6b4128"))
	draw_rect(rect, Color("2b2b3a"), false, 4.0)
	var cols: int = 5
	var rows: int = ceili(float(slots) / cols)
	var cell: Vector2 = (bed_size - Vector2(40, 36)) / Vector2(cols - 1, rows - 1)
	for i: int in slots:
		var p: Vector2 = rect.position + Vector2(20, 18) + cell * Vector2(i % cols, floorf(float(i) / cols))
		if i < carrots:
			draw_colored_polygon(PackedVector2Array([p + Vector2(-7, -4), p + Vector2(7, -4), p + Vector2(0, 14)]), Color("ff8a3d"))
			draw_line(p + Vector2(0, -4), p + Vector2(-4, -14), Color("4caf50"), 3.0)
			draw_line(p + Vector2(0, -4), p + Vector2(4, -14), Color("4caf50"), 3.0)
		else:
			draw_circle(p, 5.0, Color("4a2c1a"))
