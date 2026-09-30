extends Control
## Main menu (design L, scene made by tools/make_menu.py): the farm yard
## with the house, the wheat and apple crops (a ripe one is collected with a
## tap, an unripe one opens the harvest window), the hero in idle, logo,
## Play → farm map, shop, daily gift (shakes with a red dot while it can be
## taken), harvest (a dot while something is ripe), settings, "How to play",
## grains counter. Windows open over the menu. A gift that can be taken
## opens by itself once per launch (so the player sees the streak).

## The gift window already opened by itself in this launch.
static var _gift_auto_shown: bool = false

@export_file("*.tscn") var map_scene: String = "res://scenes/map/map.tscn"
@export var shop_window: PackedScene
@export var settings_window: PackedScene
@export var gift_window: PackedScene
## "How to play" (Yandex requirement 2.2).
@export var how_to_window: PackedScene
@export var harvest_window: PackedScene

@onready var _play: Button = %Play
@onready var _shop: RoundButton = %Shop
@onready var _settings: RoundButton = %Settings
@onready var _gift: RoundButton = %Gift
@onready var _how_to: RoundButton = %HowTo
@onready var _harvest: RoundButton = %Harvest
@onready var _grains: Counter = %Grains
@onready var _hero: AnimatedSprite2D = $Stage/Hero/Sprite


func _ready() -> void:
	_play.text = tr("BTN_PLAY")
	Audio.music(&"menu")
	UiFx.press_spring(_play)
	_play.pressed.connect(func() -> void: get_tree().change_scene_to_file(map_scene))
	_shop.pressed.connect(_open.bind(shop_window))
	_settings.pressed.connect(_open.bind(settings_window))
	_gift.pressed.connect(_open.bind(gift_window))
	_how_to.pressed.connect(_open.bind(how_to_window))
	_harvest.pressed.connect(_open.bind(harvest_window))
	Game.start_harvest(Game.now())
	for crop: MapCrop in _crops():
		crop.pressed.connect(_on_crop.bind(crop))
	Game.grains_changed.connect(_on_grains)
	Game.progress_changed.connect(_refresh)
	var skin: SkinData = Game.META.skin(Game.skin)
	if skin != null:
		_hero.sprite_frames = skin.ui_frames
		_hero.play(&"idle")
	_refresh()
	if Game.can_claim_gift(Game.today()) and not _gift_auto_shown:
		_gift_auto_shown = true
		_open.call_deferred(gift_window)


func _refresh() -> void:
	_grains.value = Game.grains
	var gift_ready: bool = Game.can_claim_gift(Game.today())
	_gift.badge = gift_ready
	_gift.icon_anim = &"icon_gift_shake" if gift_ready else &""
	var ripe: bool = Game.harvest_ready(Game.now()) > 0
	_harvest.badge = ripe
	_harvest.icon_anim = &"icon_harvest_ripe" if ripe else &""
	for crop: MapCrop in _crops():
		crop.refresh()


## The yard is drawn for each orientation: crops of both.
func _crops() -> Array[MapCrop]:
	var out: Array[MapCrop] = []
	for group: String in ["Stage/Portrait", "Stage/Landscape"]:
		for n: Node in get_node(group).get_children():
			if n is MapCrop:
				out.append(n as MapCrop)
	return out


func _on_crop(crop: MapCrop) -> void:
	if crop.is_ripe():
		crop.collect(self, _grains)
		_refresh()
	else:
		_open(harvest_window)


func _on_grains(n: int) -> void:
	_grains.value = n


func _open(scene: PackedScene) -> void:
	if scene == null:
		return
	var w: UiWindow = scene.instantiate() as UiWindow
	add_child(w)
	w.closed.connect(w.queue_free)
	w.closed.connect(_refresh)
	w.open()
