class_name ShopWindow
extends UiWindow
## Shop (design I, screens 12–13) with two tabs. "Upgrades": four hero
## stats. "Skins": a big preview of the tapped skin with its action (select,
## buy for grains, unlock for ads, try on for an ad) and the row of cards.
## Grains in the top-left corner of the screen.

@export var stat_card: PackedScene
@export var skin_card: PackedScene
## Preview card side in landscape / portrait, px.
@export var preview_side: Vector2 = Vector2(460, 480)
## Grain counter position in landscape / portrait (design I), px.
@export var counter_landscape: Vector2 = Vector2(80, 30)
@export var counter_portrait: Vector2 = Vector2(60, 90)

var _preview_id: StringName = &""
var _stat_cards: Array[StatCard] = []
var _skin_cards: Array[SkinCard] = []

@onready var _tab_up: Button = %TabUp
@onready var _tab_skins: Button = %TabSkins
@onready var _stats: BoxContainer = %Stats
@onready var _skins: BoxContainer = %Skins
@onready var _preview: VBoxContainer = %Preview
@onready var _hero_card: PanelContainer = %HeroCard
@onready var _hero: AnimatedSprite2D = %Hero
@onready var _shadow: Sprite2D = %Shadow
@onready var _skin_name: Label = %SkinName
@onready var _skin_how: Label = %SkinHow
@onready var _actions: HBoxContainer = %Actions
@onready var _select_skin: Button = %SelectSkin
@onready var _buy_skin: Button = %BuySkin
@onready var _buy_text: Label = %BuySkin.get_node(^"Row/Text") as Label
@onready var _open_ad: AdButton = %OpenAd
@onready var _try: AdButton = %Try
@onready var _cards: GridContainer = %Cards
@onready var _grains: Counter = %Grains


func _ready() -> void:
	super()
	for id: StringName in Game.META.stats:
		var card: StatCard = stat_card.instantiate() as StatCard
		_stats.add_child(card)
		card.setup(id)
		card.changed.connect(_refresh)
	for s: SkinData in Game.META.skins:
		var card: SkinCard = skin_card.instantiate() as SkinCard
		_cards.add_child(card)
		card.setup(s)
		card.picked.connect(_preview_skin)
		card.changed.connect(_refresh)
	_tab_up.pressed.connect(_show_tab.bind(false))
	_tab_skins.pressed.connect(_show_tab.bind(true))
	_select_skin.pressed.connect(_on_select)
	_buy_skin.pressed.connect(_on_buy)
	_open_ad.rewarded.connect(_on_open_ad)
	_try.rewarded.connect(_on_try)
	for b: Button in [_select_skin, _buy_skin]:
		UiFx.press_spring(b)
	(_hero.get_parent() as Control).resized.connect(_place_hero)
	Game.grains_changed.connect(_on_grains)
	_preview_id = Game.skin
	_show_tab(false)
	_refresh()
	_layout()


func open() -> void:
	_preview_id = Game.skin
	_refresh()
	super()


func _on_layout(portrait: bool) -> void:
	super(portrait)
	for card: StatCard in _stat_cards_now():
		card.set_portrait(portrait)
	for card: SkinCard in _skin_cards_now():
		card.set_portrait(portrait)
	var side: float = preview_side.y if portrait else preview_side.x
	_hero_card.custom_minimum_size = Vector2(side, side)
	_grains.position = counter_portrait if portrait else counter_landscape
	# Five cards fit the 1000 portrait panel only close together.
	_cards.add_theme_constant_override(&"h_separation", 8 if portrait else 16)
	_skin_how.custom_minimum_size.x = 900.0 if portrait else 520.0
	# Portrait (design): preview, the cards, then the action under them.
	var home: Node = _skins if portrait else _preview
	if _actions.get_parent() != home:
		_actions.reparent(home)
	if portrait:
		_skins.move_child(_actions, -1)


func _stat_cards_now() -> Array[StatCard]:
	_stat_cards.clear()
	if _stats != null:
		for n: Node in _stats.get_children():
			_stat_cards.append(n as StatCard)
	return _stat_cards


func _skin_cards_now() -> Array[SkinCard]:
	_skin_cards.clear()
	if _cards != null:
		for n: Node in _cards.get_children():
			_skin_cards.append(n as SkinCard)
	return _skin_cards


func _show_tab(skins: bool) -> void:
	_stats.visible = not skins
	_skins.visible = skins
	_tab_up.theme_type_variation = &"TabInactive" if skins else &"TabActive"
	_tab_skins.theme_type_variation = &"TabActive" if skins else &"TabInactive"
	panel.reset_size()
	_place_decor()


func _refresh() -> void:
	_grains.value = Game.grains
	for card: StatCard in _stat_cards_now():
		card.refresh()
	for card: SkinCard in _skin_cards_now():
		card.refresh()
		card.set_previewed(card.skin.id == _preview_id)
	_show_preview()


func _on_grains(_g: int) -> void:
	_refresh()


func _preview_skin(id: StringName) -> void:
	_preview_id = id
	_refresh()


## The big hero, its name, how it opens and what can be done with it.
func _show_preview() -> void:
	var s: SkinData = Game.META.skin(_preview_id)
	var owned: bool = Game.owns_skin(s.id)
	_hero.sprite_frames = s.ui_frames
	_hero.play(&"idle")
	_place_hero()
	_skin_name.text = tr(s.name_key)
	var how: String = ""
	if not owned:
		if s.ad_views > 0:
			how = tr("SKIN_BY_ADS") % s.ad_views
		elif s.unlock_level > 0:
			how = tr("SKIN_BY_LEVEL") % s.unlock_level
		else:
			how = tr("SKIN_BY_GRAINS")
	_skin_how.text = how
	_skin_how.visible = how != ""
	_select_skin.visible = owned and s.id != Game.skin
	_buy_skin.visible = not owned and s.price_grains > 0
	_buy_text.text = str(s.price_grains)
	_buy_skin.disabled = Game.grains < s.price_grains
	_open_ad.visible = not owned and s.ad_views > 0
	_open_ad.text = tr("BTN_OPEN_ADS") % [Game.skin_ad_views(s.id), s.ad_views]
	# Try-on (any locked skin but the ad one: that opens by the same views).
	_try.visible = not owned and s.ad_views <= 0 and Game.trial_skin != s.id
	var any: bool = false
	for b: Node in _actions.get_children():
		any = any or (b as Control).visible
	_actions.visible = any


func _place_hero() -> void:
	var holder: Control = _hero.get_parent() as Control
	var side: float = minf(holder.size.x, holder.size.y)
	if side <= 0.0:
		return
	var frame: Texture2D = _hero.sprite_frames.get_frame_texture(&"idle", 0)
	var k: float = side * 0.8 / float(frame.get_height())
	_hero.scale = Vector2(k, k)
	_hero.position = Vector2(holder.size.x * 0.5, holder.size.y * 0.46)
	_shadow.scale = Vector2(side * 0.36 / 128.0, side * 0.36 / 128.0)
	_shadow.position = Vector2(holder.size.x * 0.5, holder.size.y * 0.46 + side * 0.36)


func _on_select() -> void:
	if Game.select_skin(_preview_id):
		Save.save()
		_refresh()


func _on_buy() -> void:
	if Game.buy_skin(_preview_id):
		Game.select_skin(_preview_id)
		Save.save()
		Ui.toast(tr("TOAST_SKIN_OPEN"))
		UiFx.pop(_hero_card, 0.85, 0.3)
		_refresh()
	else:
		Ui.toast(tr("TOAST_NO_GRAINS"))


func _on_open_ad() -> void:
	if Game.add_skin_ad(_preview_id):
		Ui.toast(tr("TOAST_SKIN_OPEN"))
		UiFx.pop(_hero_card, 0.85, 0.3)
	Save.save()
	_refresh()


## Rewarded try-on: the skin for the next fight only.
func _on_try() -> void:
	Game.trial_skin = _preview_id
	Ui.toast(tr("TOAST_TRIAL"))
	_refresh()
