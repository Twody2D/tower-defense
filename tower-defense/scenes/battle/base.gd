class_name CarrotBase
extends Node2D
## Carrot bed at the road end (design: bed 256 with 20 slots). Carrots are
## child sprites under Carrots; a taken carrot leaves an empty hole.

var carrots: int = 20

@onready var _carrots: Node2D = $Carrots


func slots() -> int:
	return _carrots.get_child_count()


func set_carrots(n: int) -> void:
	carrots = n
	var i: int = 0
	for c: Node in _carrots.get_children():
		(c as CanvasItem).visible = i < n
		i += 1
