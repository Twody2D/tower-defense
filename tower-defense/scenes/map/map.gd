class_name FarmMap
extends Control
## Farm map (design I, screen 4): three biomes along a 5760 px strip, a dotted
## path through 12 level points, decor, the offline harvest bed. The world is
## authored in portrait mockup coordinates (1080 × 5760, level 1 at the
## bottom); in landscape every piece moves by the mockup rule
## (x, y) → (5760 − y, x), so level 1 is on the left.
## Drag (finger or mouse) or the wheel scrolls with inertia. A level point
## opens the level start window; a drag never presses a point.

const LENGTH: float = 5760.0
const WIDTH: float = 1080.0
const GROUPS: Array[StringName] = [&"World", &"Bands", &"Path", &"Decor", &"Nodes"]

@export var level_start_window: PackedScene
@export var shop_window: PackedScene
@export var settings_window: PackedScene
@export var gift_window: PackedScene
@export var harvest_window: PackedScene
@export_file("*.tscn") var battle_scene: String = "res://scenes/battle/battle.tscn"
## Movement after which a touch is a drag, not a tap, px.
@export var drag_threshold: float = 14.0
## Inertia fade, 1/s.
@export var friction: float = 5.0

var portrait: bool = true
var scroll: float = 0.0

## Authored (portrait) centre of every world piece.
var _home: Dictionary[CanvasItem, Vector2] = {}
var _bands: Dictionary[TextureRect, Rect2] = {}
var _velocity: float = 0.0
var _touch: int = -1
var _touch_start: Vector2 = Vector2.ZERO
var _dragged: bool = false

@onready var _world: Node2D = $World
@onready var _nodes: Node2D = $World/Nodes
@onready var _grains: Counter = %Grains
@onready var _shop: RoundButton = %Shop
@onready var _settings: RoundButton = %Settings
@onready var _gift: RoundButton = %Gift
@onready var _harvest: RoundButton = %Harvest
@onready var _harvest_bed: Node2D = $World/HarvestBed


func _ready() -> void:
	_remember(_world)
	Audio.music(&"menu")
	for n: Node in _nodes.get_children():
		var node: MapNode = n as MapNode
		if node != null:
			node.pressed.connect(_on_level.bind(node.level))
	_shop.pressed.connect(_open.bind(shop_window))
	_settings.pressed.connect(_open.bind(settings_window))
	_gift.pressed.connect(_open.bind(gift_window))
	_harvest.pressed.connect(_open.bind(harvest_window))
	Game.grains_changed.connect(func(g: int) -> void: _grains.value = g)
	Game.progress_changed.connect(_refresh)
	Game.start_harvest(Game.now())
	get_viewport().size_changed.connect(_layout)
	_refresh()
	_layout()
	_scroll_to_level(Game.last_open_level())


## Groups (World, Bands, Path, Decor, Nodes) only hold pieces; pieces move.
func _remember(n: Node) -> void:
	if n.name in GROUPS:
		for child: Node in n.get_children():
			_remember(child)
		return
	var band: TextureRect = n as TextureRect
	var c: Control = n as Control
	var n2: Node2D = n as Node2D
	if band != null:
		_bands[band] = Rect2(band.position, band.size)
	elif c != null:
		_home[c] = c.position + c.size * 0.5
	elif n2 != null:
		_home[n2] = n2.position


func _refresh() -> void:
	_grains.value = Game.grains
	var gift_ready: bool = Game.can_claim_gift(Game.today())
	_gift.badge = gift_ready
	_gift.icon_anim = &"icon_gift_shake" if gift_ready else &""
	var ripe: bool = Game.harvest_amount(Game.now()) > 0
	_harvest.badge = ripe
	_harvest_bed.get_node(^"Badge").set(&"visible", ripe)
	var skin: SkinData = Game.META.skin(Game.skin)
	var current: int = Game.last_open_level()
	for n: Node in _nodes.get_children():
		var node: MapNode = n as MapNode
		if node == null:
			continue
		var stars: int = Game.level_stars[node.level - 1]
		var state: String = "locked"
		if node.level == current:
			state = "current"
		elif stars > 0:
			state = "done"
		elif Game.is_level_open(node.level):
			state = "open"
		node.show_state(state, stars, skin.avatar if skin != null else null)


## Places every piece for the orientation and keeps the scroll in range.
func _layout() -> void:
	var screen: Vector2 = get_viewport_rect().size
	var was_portrait: bool = portrait
	portrait = screen.y > screen.x
	for item: CanvasItem in _home:
		var p: Vector2 = _home[item]
		var at: Vector2 = p if portrait else Vector2(LENGTH - p.y, p.x)
		var c: Control = item as Control
		if c != null:
			c.position = at - c.size * 0.5
		else:
			(item as Node2D).position = at
	for band: TextureRect in _bands:
		var r: Rect2 = _bands[band]
		if portrait:
			band.position = r.position
			band.size = r.size
		else:
			band.position = Vector2(LENGTH - r.end.y, r.position.x)
			band.size = Vector2(r.size.y, r.size.x)
	if was_portrait != portrait:
		_scroll_to_level(Game.last_open_level())
	_apply_scroll()


func _scroll_to_level(level: int) -> void:
	var node: MapNode = _nodes.get_child(level - 1) as MapNode
	if node == null:
		return
	var screen: Vector2 = get_viewport_rect().size
	var centre: Vector2 = node.position + node.size * 0.5
	scroll = (centre.y - screen.y * 0.5) if portrait else (centre.x - screen.x * 0.5)
	_apply_scroll()


func _apply_scroll() -> void:
	var screen: Vector2 = get_viewport_rect().size
	var view: float = screen.y if portrait else screen.x
	scroll = clampf(scroll, 0.0, maxf(LENGTH - view, 0.0))
	if portrait:
		_world.position = Vector2(floorf((screen.x - WIDTH) * 0.5), -scroll)
	else:
		_world.position = Vector2(-scroll, floorf((screen.y - WIDTH) * 0.5))


func _process(delta: float) -> void:
	if _touch == -1 and absf(_velocity) > 1.0:
		scroll += _velocity * delta
		_velocity *= exp(-friction * delta)
		_apply_scroll()


func _input(event: InputEvent) -> void:
	if _modal_open():
		return
	if event is InputEventScreenTouch:
		var t: InputEventScreenTouch = event
		if t.pressed and _touch == -1:
			_touch = t.index
			_touch_start = t.position
			_dragged = false
			_velocity = 0.0
		elif not t.pressed and t.index == _touch:
			_touch = -1
	elif event is InputEventScreenDrag:
		var d: InputEventScreenDrag = event
		if d.index != _touch:
			return
		if not _dragged and d.position.distance_to(_touch_start) > drag_threshold:
			_dragged = true
		if _dragged:
			var along: float = -(d.relative.y if portrait else d.relative.x)
			scroll += along
			_velocity = -(d.velocity.y if portrait else d.velocity.x)
			_apply_scroll()
	elif event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var dir: float = -1.0 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0
			# Portrait: wheel up = further (up the map); landscape: to the right.
			scroll += dir * 160.0 * (1.0 if portrait else -1.0)
			_apply_scroll()


func _modal_open() -> bool:
	for c: Node in get_children():
		if c is UiWindow and (c as UiWindow).visible:
			return true
	return false


func _on_level(level: int) -> void:
	if _dragged:
		return
	Game.current_level = level
	if level_start_window == null:
		get_tree().change_scene_to_file(battle_scene)
		return
	_open(level_start_window)


func _open(scene: PackedScene) -> void:
	if scene == null or _dragged:
		return
	var w: UiWindow = scene.instantiate() as UiWindow
	add_child(w)
	w.closed.connect(w.queue_free)
	w.closed.connect(_refresh)
	w.open()
