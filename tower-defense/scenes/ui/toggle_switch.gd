@tool
class_name ToggleSwitch
extends TextureButton
## On/off switch from the UI kit (track 128×64, knob 56 slides across).

## Knob x when off / on, px.
const KNOB_OFF: float = 4.0
const KNOB_ON: float = 68.0

@onready var _knob: TextureRect = $Knob


func _ready() -> void:
	toggle_mode = true
	toggled.connect(_on_toggled)
	_knob.position.x = KNOB_ON if button_pressed else KNOB_OFF


## Sets the state without the toggled signal (showing a saved setting).
func set_on(on: bool) -> void:
	set_pressed_no_signal(on)
	_knob.position.x = KNOB_ON if on else KNOB_OFF


func _on_toggled(on: bool) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(_knob, ^"position:x", KNOB_ON if on else KNOB_OFF, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
