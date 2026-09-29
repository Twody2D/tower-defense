extends Node
## UI kit check: a window with every button kind, a counter, tabs, a card and
## a toast. Open dev/ui_kit_demo.tscn or shoot it with dev/shot.gd.

@onready var _window: UiWindow = $Window


func _ready() -> void:
	_window.set_title("Магазин")
	_window.open()
	await get_tree().create_timer(3.0).timeout
	Ui.toast(tr("TOAST_NO_GRAINS"))
