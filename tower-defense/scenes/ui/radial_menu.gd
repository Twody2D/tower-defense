class_name RadialMenu
extends Control
## Defender pick over a build plot (design H: arc of 4 slots, R 170 at 1080
## → 113 here). The game goes on while it is open (Twody: the hero must not
## get stuck on a plot): tap a slot or press 1–4 to pick; the battle closes it
## when the hero steps off the plot. Taps outside the slots go to the
## joystick (the menu ignores the mouse, slots are in "hud_blocker").

signal picked(plot: BuildPlot, data: DefenderData)
signal closed

## Menu centre above the plot centre, px (design: 20 at 1080).
@export var lift: float = 20.0

var plot: BuildPlot

@onready var _anchor: Control = $Anchor
var _slots: Array[RadialSlot] = []


func _ready() -> void:
	visible = false
	for child: Node in _anchor.get_children():
		var slot: RadialSlot = child as RadialSlot
		if slot != null:
			_slots.append(slot)
			slot.picked.connect(_on_slot_picked)
			slot.add_to_group(&"hud_blocker")


## `catalog` — all defenders in menu order; `allowed` — open on this level.
func open(for_plot: BuildPlot, catalog: Array[DefenderData], allowed: Array[DefenderData]) -> void:
	plot = for_plot
	for i: int in _slots.size():
		var slot: RadialSlot = _slots[i]
		slot.visible = i < catalog.size()
		if slot.visible:
			slot.show_defender(catalog[i], catalog[i] in allowed)
	_follow_plot()
	_process(0.0)
	visible = true
	UiFx.pop(_anchor, 0.4, 0.2)


func close() -> void:
	if not visible:
		return
	visible = false
	plot = null
	closed.emit()


func _process(_delta: float) -> void:
	if visible:
		_follow_plot()
		if plot != null and plot.state != null:
			for slot: RadialSlot in _slots:
				if slot.visible:
					slot.set_coins(plot.state.coins)


func _follow_plot() -> void:
	if plot == null:
		return
	var screen: Vector2 = get_viewport().get_canvas_transform() * plot.global_position
	_anchor.position = screen - Vector2(0, lift)


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return
	var key: InputEventKey = event as InputEventKey
	if key == null:
		return
	var n: int = key.physical_keycode - KEY_1
	if n >= 0 and n < _slots.size() and _slots[n].visible and not _slots[n].disabled:
		_on_slot_picked(_slots[n].data)
		get_viewport().set_input_as_handled()


func _on_slot_picked(data: DefenderData) -> void:
	var p: BuildPlot = plot
	visible = false
	plot = null
	picked.emit(p, data)
	closed.emit()
