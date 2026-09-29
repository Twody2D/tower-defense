class_name StatCard
extends PanelContainer
## One hero upgrade in the shop (design I, screen 12): icon, name, 10 level
## segments, "Lv. 4/10", buy for grains and "−50%" for an ad (a daily
## limit: the button goes grey when it is used up). A tall card in landscape, a wide row in portrait.

signal changed

const SEG_ON: Texture2D = preload("res://art/ui/ui_seg_on.png")
const SEG_OFF: Texture2D = preload("res://art/ui/ui_seg_off.png")

## Card size in landscape and portrait (design I), px.
@export var landscape_size: Vector2 = Vector2(400, 640)
@export var portrait_size: Vector2 = Vector2(880, 270)
## Buttons: width in landscape / portrait.
@export var buy_width: Vector2 = Vector2(320, 300)
@export var ad_width: Vector2 = Vector2(320, 320)

var stat: StringName = &"damage"

@onready var _icon: TextureRect = %Icon
@onready var _name: Label = %Name
@onready var _info: VBoxContainer = %Info
@onready var _segs: HBoxContainer = %Segs
@onready var _level_row: BoxContainer = %LevelRow
@onready var _buttons: BoxContainer = %Buttons
@onready var _level: Label = %Level
@onready var _buy: Button = %Buy
@onready var _buy_text: Label = $Body/Info/Buttons/Buy/Row/Text
@onready var _discount: AdButton = %Discount


func _ready() -> void:
	_buy.pressed.connect(_on_buy)
	_discount.rewarded.connect(_on_discount)
	UiFx.press_spring(_buy)


func setup(id: StringName) -> void:
	stat = id
	_icon.texture = load("res://art/ui/ui_icon_%s.png" % id) as Texture2D
	_name.text = tr("STAT_" + String(id).to_upper())
	refresh()


func set_portrait(portrait: bool) -> void:
	custom_minimum_size = portrait_size if portrait else landscape_size
	var align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT if portrait else HORIZONTAL_ALIGNMENT_CENTER
	_name.horizontal_alignment = align
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL if portrait else Control.SIZE_SHRINK_CENTER
	var box_align: BoxContainer.AlignmentMode = BoxContainer.ALIGNMENT_BEGIN if portrait else BoxContainer.ALIGNMENT_CENTER
	_level_row.alignment = box_align
	_buttons.alignment = box_align
	_buy.custom_minimum_size.x = buy_width.y if portrait else buy_width.x
	_discount.custom_minimum_size.x = ad_width.y if portrait else ad_width.x


func refresh() -> void:
	var lv: int = Game.stat_level(stat)
	var top: int = Game.META.stat_max_level
	for i: int in _segs.get_child_count():
		var seg: TextureRect = _segs.get_child(i) as TextureRect
		seg.visible = i < top
		seg.texture = SEG_ON if i < lv else SEG_OFF
	_level.text = tr("LBL_LEVEL_OF") % [lv, top]
	var maxed: bool = Game.is_stat_max(stat)
	if maxed:
		_buy_text.text = tr("LBL_MAX")
		_buy.disabled = true
		_discount.visible = false
		return
	_buy_text.text = str(Game.stat_price(stat))
	_buy.disabled = Game.grains < Game.stat_price(stat)
	var left: int = Game.META.discount_ads_per_day - Game.ads_used(&"discount", Game.today())
	_discount.visible = true
	_discount.disabled = left <= 0 or Game.grains < Game.stat_price(stat, true)


func _on_buy() -> void:
	if Game.buy_stat(stat):
		_bought()
	else:
		Ui.toast(tr("TOAST_NO_GRAINS"))


## The ad was watched: one upgrade at half price.
func _on_discount() -> void:
	Game.use_ad(&"discount", Game.today())
	if Game.buy_stat(stat, true):
		_bought()


func _bought() -> void:
	Save.save()
	UiFx.bump(_segs, 1.15, 0.25)
	changed.emit()
