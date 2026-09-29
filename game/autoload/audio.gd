extends Node
## Sound: Music and Sfx buses under Master. Player switches (Game.music_on /
## sound_on) mute the child buses; YandexSdk mutes Master for ads and lost focus.
## Players and sound files come in stage 8.

const MUSIC_BUS := &"Music"
const SFX_BUS := &"Sfx"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	Game.settings_changed.connect(apply_settings)
	apply_settings()


func apply_settings() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MUSIC_BUS), not Game.music_on)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(SFX_BUS), not Game.sound_on)


static func _ensure_bus(bus: StringName) -> void:
	if AudioServer.get_bus_index(bus) != -1:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus)
	AudioServer.set_bus_send(index, &"Master")
