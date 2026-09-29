class_name PauseWindow
extends UiWindow
## Pause in battle (design I, screen 6): continue, restart, to the map, music
## and sound switches. Restart and "to map" ask first (progress is lost).

signal resume
signal restart
signal to_map

@onready var _continue: Button = %Continue
@onready var _restart: Button = %Restart
@onready var _to_map: Button = %ToMap
@onready var _music: ToggleSwitch = %Music
@onready var _sound: ToggleSwitch = %Sound


func _ready() -> void:
	super()
	_music.set_on(Game.music_on)
	_sound.set_on(Game.sound_on)
	_music.toggled.connect(Game.set_music)
	_sound.toggled.connect(Game.set_sound)
	_continue.pressed.connect(_on_continue)
	_restart.pressed.connect(_ask.bind("CONFIRM_RESTART", restart))
	_to_map.pressed.connect(_ask.bind("CONFIRM_TO_MAP", to_map))
	for b: Button in [_continue, _restart, _to_map]:
		UiFx.press_spring(b)


func _on_continue() -> void:
	visible = false
	resume.emit()


func _ask(key: String, answer: Signal) -> void:
	if await Ui.ask(tr(key)):
		visible = false
		answer.emit()
