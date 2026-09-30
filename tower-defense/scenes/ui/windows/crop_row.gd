class_name CropRow
extends PanelContainer
## One farm crop in the harvest window (design K): product icon, name and
## level, grains per harvest, growth bar, "Ripe!" or "Ripe in 2 h", upgrade
## for grains. Ripe rows are highlighted; closed ones say which level opens
## them.

signal changed

var crop: CropData

@onready var _icon: TextureRect = %Icon
@onready var _name: Label = %Name
@onready var _level: Label = %Level
@onready var _yield: Label = %Yield
@onready var _bar: TextureProgressBar = %Bar
@onready var _status: Label = %Status
@onready var _upgrade_box: VBoxContainer = %UpgradeBox
@onready var _upgrade: Button = %Upgrade
@onready var _price: Label = %Price


func _ready() -> void:
	_upgrade.pressed.connect(_on_upgrade)
	# Its own sound: bought or not enough grains.
	_upgrade.set_meta(&"no_click", true)
	UiFx.press_spring(_upgrade)


func setup(c: CropData) -> void:
	crop = c
	_icon.texture = c.icon_big
	_name.text = tr(c.name_key)
	refresh()


func refresh() -> void:
	if crop == null:
		return
	var now: int = Game.now()
	var open: bool = Game.crop_open(crop)
	var ready: bool = open and Game.crop_ready(crop, now)
	var level: int = Game.crop_level(crop)
	theme_type_variation = &"CardHighlightTight" if ready else &"CardTight"
	modulate = Color.WHITE if open else Color(1, 1, 1, 0.6)
	_level.text = tr("CROP_LEVEL") % level if open else ""
	_yield.text = "+%d" % Game.crop_yield(crop)
	_bar.value = Game.crop_progress(crop, now)
	if not open:
		_status.text = tr("HARVEST_LOCKED") % crop.unlock_after
	elif ready:
		_status.text = tr("HARVEST_RIPE")
	else:
		_status.text = tr("HARVEST_IN") % time_text(Game.crop_left(crop, now))
	_status.add_theme_color_override(&"font_color", Color("3E8E41") if ready else Color("6B6878"))
	var price: int = crop.upgrade_price(level)
	_upgrade_box.visible = open
	_upgrade.disabled = price <= 0 or Game.grains < price
	_price.text = str(price) if price > 0 else tr("LBL_MAX")


## "2 h", "35 min", "1 min".
static func time_text(seconds: int) -> String:
	if seconds > 59 * 60:
		return TranslationServer.translate("TIME_HOURS") % ceili(seconds / 3600.0)
	return TranslationServer.translate("TIME_MINUTES") % maxi(ceili(seconds / 60.0), 1)


func _on_upgrade() -> void:
	if Game.upgrade_crop(crop):
		Audio.sfx(&"buy", false)
		Save.save()
		UiFx.bump(_icon, 1.15, 0.25)
		changed.emit()
	else:
		Audio.sfx(&"deny", false)
		Ui.toast(tr("TOAST_NO_GRAINS"))
