class_name HarvestWindow
extends UiWindow
## Offline harvest (design I, screen 15): the bed grew grains while the
## player was away (MetaData: per hour, up to a cap). "Claim" and "Claim ×3"
## for an ad; when the bed is empty it says when to come back.

@onready var _text: Label = %Text
@onready var _value: Label = %Value
@onready var _full: Label = %Full
@onready var _claim: Button = %Claim
@onready var _claim_x3: AdButton = %ClaimX3


func _ready() -> void:
	super()
	_claim.pressed.connect(_take.bind(1))
	_claim_x3.rewarded.connect(_take.bind(3))
	UiFx.press_spring(_claim)
	_refresh()


func open() -> void:
	_refresh()
	super()


func _refresh() -> void:
	var now: int = Game.now()
	var n: int = Game.harvest_amount(now)
	_value.text = "+%d" % n
	_text.text = tr("HARVEST_TEXT") if n > 0 else tr("HARVEST_EMPTY")
	var cap: float = Game.META.harvest_max_hours * 3600.0
	var left_h: int = ceili(maxf(cap - float(now - Game.harvest_time), 0.0) / 3600.0)
	_full.text = tr("HARVEST_FULL_IN") % left_h if left_h > 0 else tr("HARVEST_FULL")
	_claim.disabled = n <= 0
	_claim_x3.disabled = n <= 0


func _take(mult: int) -> void:
	var n: int = Game.collect_harvest(Game.now(), mult)
	if n <= 0:
		return
	Save.save()
	Ui.toast(tr("TOAST_GRAINS") % n)
	close()
