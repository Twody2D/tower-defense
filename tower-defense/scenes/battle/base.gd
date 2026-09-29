class_name CarrotBase
extends Node2D
## Carrot bed at the road end (design: bed 256 with 20 slots). Carrots are
## animated sprites under Carrots (idle sway); a taken carrot is pulled out
## and leaves an empty hole.

var carrots: int = 20

@onready var _carrots: Node2D = $Carrots


func slots() -> int:
	return _carrots.get_child_count()


## Carrots above `n` are pulled out (base_carrot_pull), then gone; a
## raised count (tests, new battle) shows them again at once.
func set_carrots(n: int) -> void:
	carrots = n
	var i: int = 0
	for node: Node in _carrots.get_children():
		var c: AnimatedSprite2D = node as AnimatedSprite2D
		if i < n:
			if not c.visible or c.animation != &"base_carrot_idle":
				if c.animation_finished.is_connected(c.hide):
					c.animation_finished.disconnect(c.hide)
				c.visible = true
				c.play(&"base_carrot_idle")
		elif c.visible and c.animation != &"base_carrot_pull":
			c.play(&"base_carrot_pull")
			c.animation_finished.connect(c.hide, CONNECT_ONE_SHOT)
		i += 1
