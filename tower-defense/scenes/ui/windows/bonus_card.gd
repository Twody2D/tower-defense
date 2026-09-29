class_name BonusCard
extends PanelContainer
## One parcel bonus in the pick window (design H): icon, name, what it does,
## "Take" for a rewarded video.

signal taken(id: StringName)
## The video was not watched to the end (the toast is already shown).
signal failed

var id: StringName = &""

@onready var _icon: TextureRect = %Icon
@onready var _name: Label = %Name
@onready var _desc: Label = %Desc
@onready var _take: AdButton = %Take


func _ready() -> void:
	_take.rewarded.connect(func() -> void: taken.emit(id))
	_take.failed.connect(failed.emit)


## `bonus`: id from Bonuses.IDS; texts BONUS_<ID> and BONUS_<ID>_DESC.
func show_bonus(bonus: StringName, icon: Texture2D) -> void:
	id = bonus
	_icon.texture = icon
	var key: String = "BONUS_" + String(bonus).to_upper()
	_name.text = tr(key)
	_desc.text = tr(key + "_DESC")
	_take.disabled = false
