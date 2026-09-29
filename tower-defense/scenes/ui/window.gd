class_name UiWindow
extends Control
## Window from the UI kit (design G/I): dimmed screen, main panel, orange
## ribbon with the title over the top edge, close button on the corner.
## Windows are inherited scenes of window.tscn: they put their content into
## Panel/Content. The panel is `portrait_width` / `landscape_width` wide and
## as tall as its content; the ribbon and the close button follow it.
## Runs while the game is paused.

signal closed

@export var title_key: String = ""
@export var closable: bool = true
## Panel width in portrait and landscape (1080 base), px.
@export var portrait_width: float = 900.0
@export var landscape_width: float = 1300.0
## Ribbon: as wide as the title plus its ends (slice 104), at least this.
@export var ribbon_min_width: float = 520.0
## Another ribbon colour (design I: blue for defeat, purple for a new pest).
@export var ribbon_texture: Texture2D

@onready var panel: PanelContainer = $Panel
@onready var content: VBoxContainer = $Panel/Content
@onready var _ribbon: NinePatchRect = $Ribbon
@onready var _title: Label = $Ribbon/Title
@onready var _close: TextureButton = $Close
@onready var _dim: Control = $Dim


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_close.visible = closable
	if ribbon_texture != null:
		_ribbon.texture = ribbon_texture
	_close.pressed.connect(close)
	UiFx.press_spring(_close)
	if title_key != "":
		set_title(tr(title_key))
	get_viewport().size_changed.connect(_layout)
	panel.resized.connect(_place_decor)
	_layout()


func set_title(text: String) -> void:
	_title.text = text
	_ribbon.visible = text != ""
	_place_decor()


func is_portrait() -> bool:
	var s: Vector2 = get_viewport_rect().size
	return s.y > s.x


## Shows the window: the panel, its ribbon and close button pop together
## from the panel centre, the dim fades in.
func open() -> void:
	visible = true
	_layout()
	var centre: Vector2 = panel.position + panel.size * 0.5
	for c: Control in [panel, _ribbon, _close]:
		c.pivot_offset = centre - c.position
		c.scale = Vector2(0.7, 0.7)
		var tw: Tween = c.create_tween()
		tw.tween_property(c, ^"scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_dim.modulate.a = 0.0
	_dim.create_tween().tween_property(_dim, ^"modulate:a", 1.0, 0.15)


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


## Width by orientation; subclasses also re-flow their content here.
func _layout() -> void:
	var screen: Vector2 = get_viewport_rect().size
	var w: float = minf(portrait_width if is_portrait() else landscape_width, screen.x - 40.0)
	panel.custom_minimum_size.x = w
	panel.size = Vector2(w, 0.0)
	_on_layout(is_portrait())
	panel.reset_size()
	_place_decor()


## Content arrangement for the orientation: a BoxContainer with the metadata
## "portrait_vertical" (bool) is vertical in portrait when it is true, in
## landscape when it is false (columns ⇄ stack like the mockups). Override
## for more, calling super().
func _on_layout(portrait: bool) -> void:
	_flip(content, portrait)


func _flip(root: Node, portrait: bool) -> void:
	for n: Node in root.get_children():
		var box: BoxContainer = n as BoxContainer
		if box != null and box.has_meta(&"portrait_vertical"):
			var pv: bool = box.get_meta(&"portrait_vertical")
			box.vertical = portrait == pv
		_flip(n, portrait)


func _place_decor() -> void:
	if not is_node_ready():
		return
	var screen: Vector2 = get_viewport_rect().size
	panel.position = ((screen - panel.size) * 0.5).floor()
	# Room for the ribbon above the panel.
	if _ribbon.visible:
		panel.position.y = maxf(panel.position.y, 70.0)
	var font: Font = _title.get_theme_font(&"font")
	var fs: int = _title.get_theme_font_size(&"font_size")
	var rw: float = maxf(ribbon_min_width, font.get_string_size(_title.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 230.0)
	_ribbon.size = Vector2(rw, _ribbon.size.y)
	_ribbon.position = Vector2(panel.position.x + (panel.size.x - rw) * 0.5, panel.position.y - _ribbon.size.y * 0.5)
	_close.position = panel.position + Vector2(panel.size.x - _close.size.x * 0.6, -_close.size.y * 0.4)
