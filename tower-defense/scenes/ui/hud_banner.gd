class_name HudBanner
extends Control
## Big ribbon in the middle of the battle (design H): "Wave 4!" or the boss
## "The Fox is coming!" with its portrait in a slot above. Pops in, stays,
## fades out; the game goes on.

@export var ribbon_normal: Texture2D
@export var ribbon_boss: Texture2D
## Time on screen, s.
@export var hold: float = 1.4

var _tween: Tween

@onready var _slot: TextureRect = %Slot
@onready var _portrait: TextureRect = %Portrait
@onready var _ribbon: NinePatchRect = %Ribbon
@onready var _title: Label = %Title


## `portrait` null: a plain orange ribbon; otherwise the boss ribbon.
func show_banner(text: String, portrait: Texture2D = null) -> void:
	_title.text = text
	_slot.visible = portrait != null
	_portrait.texture = portrait
	_ribbon.texture = ribbon_boss if portrait != null else ribbon_normal
	visible = true
	modulate.a = 1.0
	pivot_offset = size * 0.5
	scale = Vector2(0.5, 0.5)
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, ^"scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(hold)
	_tween.tween_property(self, ^"modulate:a", 0.0, 0.4)
	_tween.tween_callback(hide)
