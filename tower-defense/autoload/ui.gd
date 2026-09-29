extends CanvasLayer
## Interface over every screen: toasts (design I, screen 17) and the
## "Yes / No" dialog. Works while the game is paused.
## Ui.toast(tr("TOAST_NO_AD")) · if await Ui.ask(text): ...

## How long a toast stays, s.
@export var toast_time: float = 2.2

@onready var _toasts: VBoxContainer = $Toasts
@onready var _confirm: ConfirmWindow = $ConfirmWindow


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_confirm.visible = false
	for t: Node in _toasts.get_children():
		(t as CanvasItem).visible = false


## Shows a short message at the top; the oldest one is reused if all are busy.
func toast(text: String) -> void:
	var box: PanelContainer = null
	for t: Node in _toasts.get_children():
		var c: PanelContainer = t as PanelContainer
		if not c.visible:
			box = c
			break
	if box == null:
		box = _toasts.get_child(0) as PanelContainer
	(box.get_node(^"Label") as Label).text = text
	_toasts.move_child(box, -1)
	box.visible = true
	box.modulate.a = 0.0
	var tw: Tween = box.create_tween()
	tw.tween_property(box, ^"modulate:a", 1.0, 0.15)
	tw.tween_interval(toast_time)
	tw.tween_property(box, ^"modulate:a", 0.0, 0.3)
	tw.tween_callback(box.hide)


func ask(text: String) -> bool:
	var yes: bool = await _confirm.ask(text)
	return yes
