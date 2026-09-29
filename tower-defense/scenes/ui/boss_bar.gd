class_name BossBar
extends Control
## Boss HP (design H): the portrait in a slot and a big bar; shown instead of
## the wave timer while the boss is alive.

@onready var _fill: NinePatchRect = %Fill
@onready var _portrait: TextureRect = %Portrait
@onready var _frame: NinePatchRect = %Frame

var _shown: float = 1.0


func show_boss(portrait: Texture2D) -> void:
	_portrait.texture = portrait
	_shown = 1.0
	set_value(1.0)
	visible = true
	UiFx.pop(self, 0.7, 0.25)


func set_value(share: float) -> void:
	share = clampf(share, 0.0, 1.0)
	var full: float = _frame.size.x - 16.0
	_fill.visible = share > 0.0
	_fill.size.x = maxf(44.0, full * share)
	if share < _shown - 0.05:
		_shown = share
		UiFx.bump(_fill, 1.04, 0.15)
