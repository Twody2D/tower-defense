class_name ParcelWindow
extends UiWindow
## "Посылка!" (design H): the fight is paused, two random bonuses, each for
## a rewarded video; "No, thanks" is free. A bonus is given only after the
## whole video (AdButton); a video not watched closes the window, the fight
## goes on without a bonus.

signal picked(id: StringName)
signal declined

@onready var _cards: Array[BonusCard] = [%Card1, %Card2]
@onready var _decline: Button = %Decline
@onready var _glow: Control = $Panel/Content/Glow
@onready var _box: AnimatedSprite2D = %Box


func _ready() -> void:
	super()
	for card: BonusCard in _cards:
		card.taken.connect(_on_taken)
		card.failed.connect(_on_declined)
	_decline.pressed.connect(_on_declined)
	UiFx.press_spring(_decline)
	_glow.resized.connect(func() -> void: _box.position = _glow.size * 0.5)


## `ids` and their icons, one card each (a second card only if there is a second bonus).
func show_bonuses(ids: Array[StringName], icons: Array[Texture2D]) -> void:
	for i: int in _cards.size():
		_cards[i].visible = i < ids.size()
		if i < ids.size():
			_cards[i].show_bonus(ids[i], icons[i])
	open()


func _on_taken(id: StringName) -> void:
	visible = false
	picked.emit(id)


func _on_declined() -> void:
	visible = false
	declined.emit()
