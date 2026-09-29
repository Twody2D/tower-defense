class_name GiftDay
extends PanelContainer
## One day of the daily gift calendar (design I, screen 14): "Day N" or
## "Today", the prize icon (grains; day 7 — the chest; today — the shaking
## gift), "+N". Taken days are faded with a check.

## Card size in landscape and portrait; the wide day 7 in portrait.
@export var landscape_size: Vector2 = Vector2(220, 340)
@export var portrait_size: Vector2 = Vector2(270, 300)
@export var portrait_wide_size: Vector2 = Vector2(858, 300)
@export var taken_alpha: float = 0.45

@onready var _day: Label = %Day
@onready var _icon: TextureRect = %Icon
@onready var _shake: AnimatedSprite2D = %Shake
@onready var _check: TextureRect = %Check
@onready var _amount: Label = %Amount


## `state`: "taken", "today" or "next".
func show_day(day: int, amount: int, state: String, chest: bool) -> void:
	var today: bool = state == "today"
	theme_type_variation = &"CardHighlight" if today else &"Card"
	_day.text = tr("LBL_TODAY") if today else tr("LBL_DAY") % (day + 1)
	_day.theme_type_variation = &"LabelDark" if today else &"LabelSmall"
	_amount.text = "+%d" % amount
	_icon.visible = not today and not chest
	_shake.visible = today or chest
	if _shake.visible:
		_shake.play(&"gift_shake" if today else &"gift")
	_check.visible = state == "taken"
	var a: float = taken_alpha if state == "taken" else 1.0
	_icon.modulate.a = a
	_shake.modulate.a = a
	_amount.modulate.a = a


func set_layout(portrait: bool, wide: bool) -> void:
	custom_minimum_size = (portrait_wide_size if wide else portrait_size) if portrait else landscape_size
