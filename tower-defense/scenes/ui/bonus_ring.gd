class_name BonusRing
extends Control
## Active parcel bonus in the HUD (design H): the ring track, the ring fill
## that runs down with the time left, the bonus icon inside.

@onready var _timer: TextureProgressBar = %Timer
@onready var _icon: TextureRect = %Icon


## `share`: time left of the whole, 0..1.
func show_bonus(icon: Texture2D, share: float) -> void:
	_icon.texture = icon
	_timer.value = share
	visible = true
