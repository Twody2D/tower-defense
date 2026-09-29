class_name RoadBlock
extends RefCounted
## Something that stops walking pests on the road (a fence). Pests stop in
## front of it and chew; at 0 HP it no longer blocks.

signal hp_changed(hp: float)
signal broken

## Which road and where along it, px.
var road: int = 0
var progress: float = 0.0
var hp: float = 0.0
var max_hp: float = 0.0


func is_up() -> bool:
	return hp > 0.0


func hit(amount: float) -> void:
	if hp <= 0.0:
		return
	hp = maxf(hp - amount, 0.0)
	hp_changed.emit(hp)
	if hp == 0.0:
		broken.emit()


func set_hp(value: float, new_max: float) -> void:
	max_hp = new_max
	hp = clampf(value, 0.0, max_hp)
	hp_changed.emit(hp)
