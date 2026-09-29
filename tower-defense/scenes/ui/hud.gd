class_name Hud
extends CanvasLayer
## Battle HUD (design H): coins and carrots top-left, pause top-right,
## wave line in the centre, floating joystick. Sizes are the 1080 mockup × 2/3.

signal pause_pressed
signal call_pressed

## Wave line lift in landscape: the top centre is free there, so the wave
## line sits level with the counters instead of under them, px.
@export var landscape_lift: float = 84.0

@onready var joystick: Joystick = $Joystick
@onready var radial_menu: RadialMenu = $RadialMenu
@onready var _coins: Label = %CoinsLabel
@onready var _carrots: Label = %CarrotsLabel
@onready var _wave: Label = %WaveLabel
@onready var _wave_bar: TextureProgressBar = %WaveBar
@onready var _timer_row: Control = %TimerRow
@onready var _timer: Label = %TimerLabel
@onready var _call: Button = %CallButton
@onready var _call_text: Label = %Text
@onready var _bonus: Label = %Bonus
@onready var _debug: Label = %DebugLabel
@onready var _pause: TextureButton = %PauseButton
@onready var _message: Label = %MessageLabel
@onready var _top_center: Control = $TopCenter

var _max_carrots: int = 20
var _carrots_shown: int = -1
var _wave_shown: int = -1


func _ready() -> void:
	_pause.pressed.connect(pause_pressed.emit)
	_call.pressed.connect(call_pressed.emit)
	UiFx.press_spring(_pause)
	UiFx.press_spring(_call)
	_call_text.text = tr("HUD_CALL_NOW")
	_message.visible = false
	_timer_row.visible = false
	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	var s: Vector2 = get_viewport().get_visible_rect().size
	_top_center.position.y = -landscape_lift if s.x > s.y else 0.0


## Esc / P: the HUD runs while the game is paused, so the key also resumes.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		pause_pressed.emit()


func bind(state: BattleState) -> void:
	_max_carrots = state.carrots
	state.coins_changed.connect(set_coins)
	state.carrots_changed.connect(set_carrots)
	set_coins(state.coins)
	set_carrots(state.carrots)


func set_coins(n: int) -> void:
	_coins.text = str(n)


func set_carrots(n: int) -> void:
	_carrots.text = "%d/%d" % [n, _max_carrots]
	if _carrots_shown >= 0 and n < _carrots_shown:
		UiFx.bump(_carrots, 1.4, 0.3)
	_carrots_shown = n


## "Wave 3/7" and the bar over all waves.
func set_wave(n: int, total: int) -> void:
	_wave.text = tr("HUD_WAVE") % [maxi(n, 1), total]
	_wave_bar.value = float(n) / float(maxi(total, 1))
	if _wave_shown >= 1 and n > _wave_shown:
		UiFx.bump(_wave, 1.3, 0.35)
	_wave_shown = n


## Break before the next wave: countdown and the "call now" bonus; hidden
## while a wave is coming out.
func show_break(seconds_left: float) -> void:
	if seconds_left <= 0.0:
		_timer_row.visible = false
		return
	_timer_row.visible = true
	var s: int = int(ceilf(seconds_left))
	_timer.text = "%d:%02d" % [floori(s / 60.0), s % 60]
	_bonus.text = "+%d" % s


func set_debug(text: String) -> void:
	_debug.text = text


func show_message(text: String) -> void:
	var was: String = _message.text if _message.visible else ""
	_message.text = text
	_message.visible = text != ""
	if _message.visible and text != was:
		UiFx.pop(_message)
