class_name AdButton
extends Button
## Rewarded button (design G: own colour, video icon, glint). Pressing shows
## the video through Ads; `rewarded` fires only when it was watched to the
## end (onRewarded + onClose), otherwise a toast says ads are not available.

signal rewarded

## What the reward is for (Ads tag, daily limit key).
@export var tag: StringName = &"reward"
## The 80 px button of cards (design I shop).
@export var small: bool = false

## Glint: one stripe (the first frame of the kit sheet) sweeps over the
## 256×112 button from `glint_from` to `glint_to` (stripe centre, px), then rests.
@export var glint_from: float = 84.0
@export var glint_to: float = 200.0
@export var glint_sweep: float = 0.55
@export var glint_period: float = 2.2

var _glint_time: float = 0.0

@onready var _glint: Sprite2D = $Glint


func _ready() -> void:
	theme_type_variation = &"ButtonAdSmall" if small else &"ButtonAd"
	if small:
		# Video icon of the 80 px button: 38 px, the text starts at 54.
		var icon: TextureRect = $Icon
		icon.offset_left = 10.0
		icon.offset_right = 48.0
		icon.offset_top = -23.0
		icon.offset_bottom = 15.0
	focus_mode = Control.FOCUS_NONE
	pressed.connect(_on_pressed)
	resized.connect(_place_glint)
	UiFx.press_spring(self)
	_place_glint()


func _place_glint() -> void:
	# The glint is drawn for the 256×112 button: stretch it to ours.
	_glint.scale = Vector2(size.x / 256.0, size.y / 112.0)
	_glint.visible = not disabled
	_move_glint()


func _process(delta: float) -> void:
	_glint.visible = not disabled
	if _glint.visible:
		_glint_time = fmod(_glint_time + delta, glint_period)
		_move_glint()


func _move_glint() -> void:
	var t: float = clampf(_glint_time / glint_sweep, 0.0, 1.0)
	var x: float = lerpf(glint_from, glint_to, ease(t, -1.6))
	_glint.position = Vector2(x * _glint.scale.x, 56.0 * _glint.scale.y)
	# Fades in at the start and out at the end of the sweep.
	_glint.modulate.a = 0.0 if t >= 1.0 else minf(1.0, minf(t, 1.0 - t) * 5.0)


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
