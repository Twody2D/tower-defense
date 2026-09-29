class_name HowToWindow
extends UiWindow
## "How to play" (Yandex requirement 2.2, the "?" button in the main menu):
## moving, coins, plots and defenders, carrots and stars, the boss.

@onready var _ok: Button = %Ok


func _ready() -> void:
	super()
	_ok.pressed.connect(close)
	UiFx.press_spring(_ok)
