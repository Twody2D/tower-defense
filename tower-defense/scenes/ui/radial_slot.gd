class_name RadialSlot
extends TextureButton
## One defender in the radial menu: portrait, price tag, or a lock when the
## defender is not open on this level (design H).

signal picked(data: DefenderData)

@export var slot_texture: Texture2D
@export var slot_locked_texture: Texture2D

var data: DefenderData

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
	disabled = not open
