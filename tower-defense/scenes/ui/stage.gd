@tool
class_name Stage
extends Control
## Screen area in design mockup coordinates (design I: 1920×1080 landscape,
## 1080×1920 portrait, 1:1). Centred in the viewport and shrunk when the
## screen is narrower than the mockup (4:3 and the like).
## Children are laid out for landscape in the scene. A node with the
## metadata "portrait" moves there in portrait: Rect2 (position, size) for a
## Control, Vector2 for a Node2D; optionally "portrait_scale": Vector2.
## Their landscape values are remembered at start. A node with the metadata
## "only" = "portrait" / "landscape" is shown in that orientation only
## (decor that differs between the two mockups).

signal orientation_changed(portrait: bool)

const LANDSCAPE: Vector2 = Vector2(1920, 1080)
const PORTRAIT: Vector2 = Vector2(1080, 1920)

var portrait: bool = false

## node -> [landscape value, landscape scale]
var _landscape: Dictionary[Node, Array] = {}
var _only: Array[CanvasItem] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_remember(self)
	get_viewport().size_changed.connect(_apply)
	_apply()


func _remember(root: Node) -> void:
	for n: Node in root.get_children():
		if n.has_meta(&"only") and n is CanvasItem:
			_only.append(n as CanvasItem)
		if n.has_meta(&"portrait"):
			var c: Control = n as Control
			var n2: Node2D = n as Node2D
			if c != null:
				_landscape[n] = [Rect2(c.position, c.size), c.scale]
			elif n2 != null:
				_landscape[n] = [n2.position, n2.scale]
		_remember(n)


func _apply() -> void:
	var screen: Vector2 = get_viewport_rect().size
	portrait = screen.y > screen.x
	var design: Vector2 = PORTRAIT if portrait else LANDSCAPE
	var k: float = minf(1.0, minf(screen.x / design.x, screen.y / design.y))
	size = design
	scale = Vector2(k, k)
	position = ((screen - design * k) * 0.5).floor()
	for n: Node in _landscape:
		_place(n)
	for c: CanvasItem in _only:
		var only: String = c.get_meta(&"only")
		c.visible = (only == "portrait") == portrait
	orientation_changed.emit(portrait)


func _place(n: Node) -> void:
	var saved: Array = _landscape[n]
	var value: Variant = n.get_meta(&"portrait") if portrait else saved[0]
	var sc: Vector2 = saved[1]
	if portrait and n.has_meta(&"portrait_scale"):
		var ps: Variant = n.get_meta(&"portrait_scale")
		if ps is Vector2:
			sc = ps
	var c: Control = n as Control
	var n2: Node2D = n as Node2D
	if c != null and value is Rect2:
		var r: Rect2 = value
		c.position = r.position
		c.size = r.size
		c.scale = sc
	elif n2 != null and value is Vector2:
		var p: Vector2 = value
		n2.position = p
		n2.scale = sc
