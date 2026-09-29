extends Control
## Main menu (design I, screen 3): logo, hero in idle, Play → farm map,
## shop, settings, daily gift (shakes with a red dot while it can be taken),
## grains counter. Windows open over the menu. A gift that can be taken
## opens by itself once per launch (so the player sees the streak).

## The gift window already opened by itself in this launch.
static var _gift_auto_shown: bool = false

@export_file("*.tscn") var map_scene: String = "res://scenes/map/map.tscn"
@export var shop_window: PackedScene
@export var settings_window: PackedScene
@export var gift_window: PackedScene

@onready var _play: Button = %Play
@onready var _shop: RoundButton = %Shop
@onready var _settings: RoundButton = %Settings
@onready var _gift: RoundButton = %Gift
@onready var _grains: Counter = %Grains
@onready var _hero: AnimatedSprite2D = $Stage/Hero/Sprite


func _ready() -> void:
	_play.text = tr("BTN_PLAY")
	UiFx.press_spring(_play)
	_play.pressed.connect(func() -> void: get_tree().change_scene_to_file(map_scene))
	_shop.pressed.connect(_open.bind(shop_window))
	_settings.pressed.connect(_open.bind(settings_window))
	_gift.pressed.connect(_open.bind(gift_window))
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
