class_name AdButton
extends Button
## Rewarded button (design G: own colour, video icon, glint). Pressing shows
## the video through Ads; `rewarded` fires only when it was watched to the
## end (onRewarded + onClose), otherwise a toast says ads are not available.

signal rewarded

## What the reward is for (Ads tag, daily limit key).
@export var tag: StringName = &"reward"

@onready var _glint: AnimatedSprite2D = $Glint


func _ready() -> void:
	theme_type_variation = &"ButtonAd"
	focus_mode = Control.FOCUS_NONE
	pressed.connect(_on_pressed)
	resized.connect(_place_glint)
	UiFx.press_spring(self)
	_place_glint()


func _place_glint() -> void:
	# The glint sheet is drawn for the 256×112 button: stretch it to ours.
	_glint.position = size * 0.5
	_glint.scale = Vector2(size.x / 256.0, size.y / 112.0)
	_glint.visible = not disabled


func _on_pressed() -> void:
	if Ads.busy:
		return
	disabled = true
	_glint.visible = false
	var ok: bool = await Ads.show_rewarded(tag)
	disabled = false
	_glint.visible = true
	if ok:
		rewarded.emit()
	else:
		Ui.toast(tr("TOAST_NO_AD"))
