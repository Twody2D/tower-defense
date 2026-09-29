class_name ConfirmWindow
extends UiWindow
## Universal "Yes / No" dialog (design I, screen 16). Use with await:
## `if await Ui.ask(tr("CONFIRM_TO_MAP")): ...`. Closing = No.

signal answered(yes: bool)

@onready var _message: Label = $Panel/Content/Message
@onready var _yes: Button = $Panel/Content/Buttons/Yes
@onready var _no: Button = $Panel/Content/Buttons/No


func _ready() -> void:
	super()
	_yes.text = tr("BTN_YES")
	_no.text = tr("BTN_NO")
	_yes.pressed.connect(_answer.bind(true))
	_no.pressed.connect(_answer.bind(false))
	closed.connect(func() -> void: answered.emit(false))
	UiFx.press_spring(_yes)
	UiFx.press_spring(_no)


func ask(text: String) -> bool:
	_message.text = text
	open()
	var yes: bool = await answered
	return yes


func _answer(yes: bool) -> void:
	visible = false
	answered.emit(yes)
