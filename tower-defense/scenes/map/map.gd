class_name FarmMap
extends Control
## Farm map (design L, scene made by tools/make_map.py): three biomes along a
## 5760 px strip with river strips and bridges between them, a trodden path
## through 12 level signs, decor, the farm crops, clouds over closed zones.
## The world is authored in portrait mockup coordinates (1080 × 5760, level
## 1 at the bottom); in landscape every piece moves by the mockup rule
## (x, y) → (5760 − y, x), so level 1 is on the left, and the pieces under
## Turned (rivers, bridges) turn 90°.
## Drag (finger or mouse) or the wheel scrolls with inertia. A level sign
## opens the level start window, a ripe crop is collected (its products fly
## to the grains counter), an unripe one opens the harvest window; a drag
## never presses anything.

const LENGTH: float = 5760.0
const WIDTH: float = 1080.0
const GROUPS: Array[StringName] = [&"World", &"Bands", &"Turned", &"Path", &"Decor", &"Crops", &"Nodes",
	&"CloudsWheat", &"CloudsLake"]
## A closed zone opens with its first level: clouds cover it until then.
const ZONES: Dictionary[StringName, int] = {&"CloudsWheat": 6, &"CloudsLake": 10}

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
var _turned: Array[Node2D] = []
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
	for n: Node in $World/Crops.get_children():
		var crop: MapCrop = n as MapCrop
		if crop != null:
			crop.pressed.connect(_on_crop.bind(crop))
	Game.grains_changed.connect(func(g: int) -> void: _grains.value = g)
	Game.progress_changed.connect(_refresh)
	Game.start_harvest(Game.now())
	_show_clouds()
	get_viewport().size_changed.connect(_layout)
	_refresh()
	_layout()
	_scroll_to_level(Game.last_open_level())


## Groups (World, Bands, Path, Decor, Nodes) only hold pieces; pieces move.
func _remember(n: Node) -> void:
	if n.name in GROUPS:
		for child: Node in n.get_children():
			_remember(child)
			if n.name == &"Turned":
				_turned.append(child as Node2D)
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
	for n: Node in $World/Crops.get_children():
		(n as MapCrop).refresh()
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
	for t: Node2D in _turned:
		t.rotation = 0.0 if portrait else PI * 0.5
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


## Clouds over a zone whose first level is still closed; the first visit
## after it opens blows them away once.
func _show_clouds() -> void:
	for group: StringName in ZONES:
		var open: bool = Game.is_level_open(ZONES[group])
		var clouds: Node = $World.get_node(NodePath(String(group)))
		var first_time: bool = open and Game.first_meet(StringName("zone_" + String(group)))
		for c: Node in clouds.get_children():
			var cloud: AnimatedSprite2D = c as AnimatedSprite2D
			cloud.visible = not open or first_time
			if first_time:
				cloud.play(StringName(String(cloud.animation).replace("_sway", "_clear")))
				cloud.animation_finished.connect(cloud.hide)
		if first_time:
			Save.save()


## A ripe crop: collected here, its products fly to the counter as grains.
## An unripe or closed one opens the harvest window.
func _on_crop(crop: MapCrop) -> void:
	if _dragged:
		return
	if not crop.is_ripe():
		_open(harvest_window)
		return
	crop.collect(self, _grains)


func _open(scene: PackedScene) -> void:
	if scene == null or _dragged:
		return
	var w: UiWindow = scene.instantiate() as UiWindow
	add_child(w)
	w.closed.connect(w.queue_free)
	w.closed.connect(_refresh)
	w.open()
