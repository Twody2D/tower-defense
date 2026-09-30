class_name ShopTutorial
extends Node
## After level 1 (Twody): the map teaches the shop — a hand on the Shop
## button, then in the shop on the buy button of the first upgrade (on the
## skins tab — on the upgrades tab). Done once a stat is bought (or one
## already was); leaving the shop without buying shows the hint again.
## Windows are the map's children; the hint hides under any other window.

const DONE: StringName = &"tut_shop"

@export var layer: TutorialLayer
@export var shop_button: Control
## Hole around the Shop button, px; around a button in the shop — half its
## size plus this.
@export var shop_radius: float = 80.0
@export var button_pad: float = 16.0

var active: bool = false


func _ready() -> void:
	active = Game.is_level_open(2) and DONE not in Game.seen
	if active and _bought_any():
		_finish()


func _process(_delta: float) -> void:
	if not active:
		return
	if _bought_any():
		_finish()
		return
	var shop: ShopWindow = null
	var other: bool = false
	for n: Node in get_parent().get_children():
		var w: UiWindow = n as UiWindow
		if w == null:
			continue
		if w is ShopWindow:
			shop = w as ShopWindow
		else:
			other = true
	if other:
		layer.clear()
	elif shop != null:
		var target: Control = shop.tutorial_target()
		var r: Rect2 = target.get_global_rect()
		layer.point(tr("TUT_SHOP_BUY"), r.get_center(), maxf(r.size.x, r.size.y) * 0.5 + button_pad, true, &"tap")
	else:
		layer.point(tr("TUT_SHOP"), shop_button.get_global_rect().get_center(), shop_radius, true, &"tap")


func _bought_any() -> bool:
	for id: StringName in Game.META.stats:
		if Game.stat_level(id) > 1:
			return true
	return false


func _finish() -> void:
	active = false
	Game.first_meet(DONE)
	Save.save()
	layer.clear()
