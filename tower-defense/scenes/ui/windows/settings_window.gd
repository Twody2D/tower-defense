class_name SettingsWindow
extends UiWindow
## Settings (design I, screen 7): music, sound, volume. No language switch —
## the language comes from the SDK (Yandex rule 2.14).

@onready var _music: ToggleSwitch = %Music
@onready var _sound: ToggleSwitch = %Sound
@onready var _volume: HSlider = %Volume
@onready var _done: Button = %Done


func _ready() -> void:
	super()
	_music.set_on(Game.music_on)
	_sound.set_on(Game.sound_on)
	_volume.value = Game.volume
	_music.toggled.connect(Game.set_music)
	_sound.toggled.connect(Game.set_sound)
	_volume.value_changed.connect(Game.set_volume)
	_done.pressed.connect(close)
	UiFx.press_spring(_done)
	closed.connect(Save.save)
