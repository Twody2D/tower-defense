class_name SkinCard
extends PanelContainer
## One skin in the shop (design I, screen 13). States: selected (check),
## owned ("Select"), ad skin (views bar, "N more" for an ad), level skin
## (lock, "Lv. 12"), grains skin (price tag). Dark portrait while locked.
## A tap on the card shows the skin in the big preview.

signal picked(id: StringName)
signal changed

## Card size and portrait side in landscape / portrait (design I), px.
@export var landscape_size: Vector2 = Vector2(210, 420)
@export var portrait_size: Vector2 = Vector2(170, 340)

const CHECK: Texture2D = preload("res://art/ui/ui_check.png")
const LOCK: Texture2D = preload("res://art/ui/ui_lock.png")

var skin: SkinData

@onready var _portrait: TextureRect = %Portrait
@onready var _status: HBoxContainer = %Status
@onready var _status_icon: TextureRect = %StatusIcon
@onready var _status_text: Label = %StatusText
@onready var _price: NinePatchRect = %Price
@onready var _price_text: Label = $Box/Status/Price/Text
@onready var _bar: NinePatchRect = %Bar
@onready var _fill: NinePatchRect = %Fill
@onready var _views: Label = %Views
@onready var _select: Button = %Select
@onready var _more: AdButton = %More


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_input)
	_select.pressed.connect(_on_select)
	_more.rewarded.connect(_on_more)
	UiFx.press_spring(_select)
	_bar.resized.connect(_update_fill)


func setup(data: SkinData) -> void:
	skin = data
	refresh()


func set_portrait(portrait: bool) -> void:
	custom_minimum_size = portrait_size if portrait else landscape_size
	var side: float = custom_minimum_size.x - 40.0
	_portrait.custom_minimum_size = Vector2(side, side)
	var font: int = 22 if portrait else 28
	_status_text.add_theme_font_size_override(&"font_size", font)
	_select.add_theme_font_size_override(&"font_size", font)
	_more.add_theme_font_size_override(&"font_size", font)


func set_previewed(on: bool) -> void:
	theme_type_variation = &"CardHighlightTight" if on else &"CardTight"


func refresh() -> void:
	var id: StringName = skin.id
	var owned: bool = Game.owns_skin(id)
	_portrait.texture = skin.portrait if owned or skin.portrait_locked == null else skin.portrait_locked
	_status_icon.visible = false
	_status_text.visible = false
	_price.visible = false
	_bar.visible = false
	_select.visible = false
	_more.visible = false
	if id == Game.skin:
		_show_status(CHECK, tr("SKIN_SELECTED"))
	elif owned:
		_show_status(null, tr("SKIN_OWNED"))
		_select.visible = true
	elif skin.ad_views > 0:
		_bar.visible = true
		_views.text = "%d/%d" % [Game.skin_ad_views(id), skin.ad_views]
		_more.visible = true
		_more.text = tr("BTN_MORE_ADS") % (skin.ad_views - Game.skin_ad_views(id))
		_update_fill()
	elif skin.unlock_level > 0:
		_show_status(LOCK, tr("SKIN_LEVEL_SHORT") % skin.unlock_level)
	else:
		_price.visible = true
		_price_text.text = str(skin.price_grains)
	_status.visible = not _bar.visible


func _show_status(icon: Texture2D, text: String) -> void:
	_status_icon.visible = icon != null
	_status_icon.texture = icon
	_status_text.visible = true
	_status_text.text = text


func _update_fill() -> void:
	if skin == null or skin.ad_views <= 0:
		return
	var k: float = clampf(float(Game.skin_ad_views(skin.id)) / skin.ad_views, 0.0, 1.0)
	var inner: float = _bar.size.x - 16.0
	_fill.visible = k > 0.0
	_fill.size = Vector2(maxf(32.0, inner * k), 32.0)


## Touches arrive as emulated mouse clicks too.
func _on_input(event: InputEvent) -> void:
	var tap: InputEventMouseButton = event as InputEventMouseButton
	if tap != null and tap.pressed and tap.button_index == MOUSE_BUTTON_LEFT:
		picked.emit(skin.id)


func _on_select() -> void:
	if Game.select_skin(skin.id):
		Save.save()
		changed.emit()


func _on_more() -> void:
	if Game.add_skin_ad(skin.id):
		Ui.toast(tr("TOAST_SKIN_OPEN"))
	Save.save()
	picked.emit(skin.id)
	changed.emit()
