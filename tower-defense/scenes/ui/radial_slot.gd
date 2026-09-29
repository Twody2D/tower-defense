class_name RadialSlot
extends TextureButton
## One defender in the radial menu: portrait, price tag, or a lock when the
## defender is not open on this level (design H). Not enough coins: greyed,
## red price, cannot be picked.

signal picked(data: DefenderData)

@export var slot_texture: Texture2D
@export var slot_locked_texture: Texture2D
@export var poor_modulate: Color = Color(0.6, 0.6, 0.6, 1.0)
@export var poor_price_color: Color = Color(1.0, 0.42, 0.42, 1.0)

var data: DefenderData
var _open: bool = false

@onready var _portrait: TextureRect = $Portrait
@onready var _lock: TextureRect = $Lock
@onready var _price: Control = $Price
@onready var _price_label: Label = $Price/Label


func _ready() -> void:
	pressed.connect(func() -> void: picked.emit(data))


func show_defender(d: DefenderData, open: bool) -> void:
	data = d
	texture_normal = slot_texture if open else slot_locked_texture
	_portrait.texture = d.portrait if open else d.portrait_locked
	_lock.visible = not open
	_price.visible = open
	_price_label.text = str(d.price(1))
	_open = open
	disabled = not open


## Coins changed: a defender the hero cannot pay for is greyed out.
func set_coins(coins: int) -> void:
	if not _open:
		return
	var poor: bool = coins < data.price(1)
	disabled = poor
	_portrait.modulate = poor_modulate if poor else Color.WHITE
	if poor:
		_price_label.add_theme_color_override(&"font_color", poor_price_color)
	else:
		_price_label.remove_theme_color_override(&"font_color")
