class_name Hud
extends CanvasLayer
## Battle HUD (design H): coins and carrots top-left, pause top-right,
## wave line in the centre, floating joystick. Sizes are the 1080 mockup × 2/3.

signal pause_pressed

@onready var joystick: Joystick = $Joystick
@onready var _coins: Label = %CoinsLabel
@onready var _carrots: Label = %CarrotsLabel
@onready var _wave: Label = %WaveLabel
@onready var _debug: Label = %DebugLabel
@onready var _pause: TextureButton = %PauseButton
@onready var _message: Label = %MessageLabel

var _max_carrots: int = 20


func _ready() -> void:
	_pause.pressed.connect(pause_pressed.emit)
	_message.visible = false


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


func set_wave(n: int) -> void:
	_wave.text = tr("HUD_WAVE") % n if n > 0 else ""


func set_debug(text: String) -> void:
	_debug.text = text


func show_message(text: String) -> void:
	_message.text = text
	_message.visible = text != ""
