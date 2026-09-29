@tool
class_name Counter
extends Control
## Counter plate from the UI kit: icon + number (grains, coins, carrots).

@export var icon: Texture2D:
	set(value):
		icon = value
		if is_node_ready():
			($Icon as TextureRect).texture = value
@export var value: int = 0:
	set(v):
		value = v
		if is_node_ready():
			($Label as Label).text = _format(v)


func _ready() -> void:
	($Icon as TextureRect).texture = icon
	($Label as Label).text = _format(value)


## "1 240": a space between thousands like the mockups.
static func _format(n: int) -> String:
	var s: String = str(absi(n))
	var out: String = ""
	while s.length() > 3:
		out = " " + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out
