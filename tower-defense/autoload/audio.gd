extends Node
## Sound: Music and Sfx buses under Master. Player switches (Game.music_on /
## sound_on) mute the child buses; YandexSdk mutes Master for ads and lost
## focus. SFX play from a fixed pool of players (nothing is made in battle),
## one looping music track. Files: CC0 packs via tools/import_sounds.py
## (docs/AUDIO_CREDITS.md). Audio.sfx(&"coin") · Audio.music(&"battle")

const MUSIC_BUS := &"Music"
const SFX_BUS := &"Sfx"

## Several files = variants, one is picked at random each time.
const SFX: Dictionary[StringName, Array] = {
	&"click": [preload("res://audio/sfx/click.ogg")],
	&"deny": [preload("res://audio/sfx/deny.ogg")],
	&"buy": [preload("res://audio/sfx/buy.ogg")],
	&"unlock": [preload("res://audio/sfx/unlock.ogg")],
	&"coin": [preload("res://audio/sfx/coin_1.ogg"), preload("res://audio/sfx/coin_2.ogg")],
	&"pay": [preload("res://audio/sfx/pay.ogg")],
	&"build": [preload("res://audio/sfx/build_1.ogg"), preload("res://audio/sfx/build_2.ogg")],
	&"throw": [
		preload("res://audio/sfx/throw_1.ogg"),
		preload("res://audio/sfx/throw_2.ogg"),
		preload("res://audio/sfx/throw_3.ogg"),
	],
	&"hit": [
		preload("res://audio/sfx/hit_1.ogg"),
		preload("res://audio/sfx/hit_2.ogg"),
		preload("res://audio/sfx/hit_3.ogg"),
	],
	&"pop": [preload("res://audio/sfx/pop_1.ogg"), preload("res://audio/sfx/pop_2.ogg")],
	&"carrot": [preload("res://audio/sfx/carrot_1.ogg"), preload("res://audio/sfx/carrot_2.ogg")],
	&"wave": [preload("res://audio/sfx/wave.ogg")],
	&"boss": [preload("res://audio/sfx/boss.ogg")],
	&"stun": [preload("res://audio/sfx/stun.ogg")],
	&"fence_hit": [
		preload("res://audio/sfx/fence_hit_1.ogg"),
		preload("res://audio/sfx/fence_hit_2.ogg"),
		preload("res://audio/sfx/fence_hit_3.ogg"),
	],
	&"fence_break": [preload("res://audio/sfx/fence_break.ogg")],
	&"parcel_land": [preload("res://audio/sfx/parcel_land.ogg")],
	&"parcel_open": [preload("res://audio/sfx/parcel_open.ogg")],
	&"tractor": [preload("res://audio/sfx/tractor.ogg")],
	&"snore": [preload("res://audio/sfx/snore.ogg")],
	&"win": [preload("res://audio/sfx/win.ogg")],
	&"lose": [preload("res://audio/sfx/lose.ogg")],
}
const MUSIC: Dictionary[StringName, AudioStreamOggVorbis] = {
	&"menu": preload("res://audio/music/menu.ogg"),
	&"battle": preload("res://audio/music/battle.ogg"),
}
## Simultaneous SFX; the oldest one is cut when all are busy.
const POOL_SIZE := 12
## The same SFX again within this time is skipped (a crowd hit at once).
const REPEAT_GAP := 0.06
## Longer gaps for what a big fight repeats all the time: without them the
## battle is a wall of plops and swishes.
const REPEAT_GAPS: Dictionary[StringName, float] = {
	&"hit": 0.1, &"throw": 0.12, &"pop": 0.07, &"coin": 0.07, &"pay": 0.045,
	&"fence_hit": 0.25, &"carrot": 0.2, &"build": 0.15,
}
## Random pitch spread so repeated sounds are not the same.
const PITCH_JITTER := 0.08
## Music fades out on pause and back in, s.
const MUSIC_FADE := 0.6
## Music plays this much under the sounds (it is mixed louder than them).
const MUSIC_DB := -6.0
const SILENT_DB := -40.0

var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _last_played: Dictionary[StringName, int] = {}
var _music: AudioStreamPlayer
var _music_id: StringName = &""
var _music_fade: Tween


func _ready() -> void:
	# UI clicks and music keep going on the pause screen.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	for i: int in POOL_SIZE:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = SFX_BUS
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = MUSIC_BUS
	add_child(_music)
	for s: AudioStreamOggVorbis in MUSIC.values():
		s.loop = true
	Game.settings_changed.connect(apply_settings)
	apply_settings()
	get_tree().node_added.connect(_on_node_added)


func apply_settings() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MUSIC_BUS), not Game.music_on)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(SFX_BUS), not Game.sound_on)
	# The volume slider moves both child buses (Master mute stays with YandexSdk).
	var db: float = linear_to_db(maxf(Game.volume, 0.0001))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), db)


func sfx(id: StringName, jitter: bool = true) -> void:
	var variants: Array = SFX.get(id, [])
	if variants.is_empty():
		push_warning("Audio: unknown sfx %s" % id)
		return
	var now: int = Time.get_ticks_msec()
	var gap: float = REPEAT_GAPS.get(id, REPEAT_GAP)
	if now - _last_played.get(id, -100000) < int(gap * 1000.0):
		return
	_last_played[id] = now
	var p: AudioStreamPlayer = _free_player()
	p.stream = variants.pick_random()
	p.pitch_scale = 1.0 + (randf_range(-PITCH_JITTER, PITCH_JITTER) if jitter else 0.0)
	p.play()


func music(id: StringName) -> void:
	if id == _music_id and (_music.playing or _music.stream_paused):
		# The same track (a restart from the pause screen): just bring it back.
		fade_music(true)
		return
	var stream: AudioStreamOggVorbis = MUSIC.get(id)
	if stream == null:
		push_warning("Audio: unknown music %s" % id)
		return
	_music_id = id
	_music.stream = stream
	_music.stream_paused = false
	_music.volume_db = MUSIC_DB
	_music.play()


## Softly silences the music and holds it (pause) or brings it back.
func fade_music(on: bool) -> void:
	if _music_fade != null and _music_fade.is_valid():
		_music_fade.kill()
	_music_fade = create_tween()
	if on:
		_music.stream_paused = false
		_music_fade.tween_property(_music, ^"volume_db", MUSIC_DB, MUSIC_FADE)
	else:
		_music_fade.tween_property(_music, ^"volume_db", SILENT_DB, MUSIC_FADE)
		_music_fade.tween_callback(func() -> void: _music.stream_paused = true)


## Every button clicks (one place instead of each scene). A button with the
## "no_click" meta plays its own sound (buy buttons; checked on the press,
## so a script may set it in _ready).
func _on_node_added(node: Node) -> void:
	var button: BaseButton = node as BaseButton
	if button != null and not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed.bind(button))


func _on_button_pressed(button: BaseButton) -> void:
	if not button.has_meta(&"no_click"):
		sfx(&"click", false)


func _free_player() -> AudioStreamPlayer:
	for i: int in POOL_SIZE:
		var p: AudioStreamPlayer = _players[(_next + i) % POOL_SIZE]
		if not p.playing:
			_next = (_next + i + 1) % POOL_SIZE
			return p
	var oldest: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % POOL_SIZE
	return oldest


static func _ensure_bus(bus: StringName) -> void:
	if AudioServer.get_bus_index(bus) != -1:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus)
	AudioServer.set_bus_send(index, &"Master")
