class_name PauseWindow
extends UiWindow
## Pause in battle (design O, 3b "pests are eating"): the scene of pests at
## the carrots with the hero (sad, the battle's skin) on the dim, the level
## and the wave with dots (done ✓ / now / next), a big "Continue", "Restart"
## and "To map" tiles, music and sound round buttons (off: crossed out).
## Portrait — the scene on top, the buttons on a panel below; landscape
## (variant 4) — the scene left, the buttons right. Positions are the
## mockup's (1080 × 1920 / 1920 × 1080), the whole body is fitted to the
## screen. Restart and "to map" ask first (progress is lost).

signal resume
signal restart
signal to_map

## Mockup boxes per orientation: position, size (scene: position, width).
const PORTRAIT: Dictionary[StringName, Rect2] = {
	&"banner": Rect2(290, 120, 500, 112), &"scene": Rect2(60, 200, 960, 0), &"level": Rect2(140, 780, 800, 50),
	&"dots": Rect2(540, 844, 0, 44), &"panel": Rect2(40, 940, 1000, 830), &"continue": Rect2(90, 1000, 900, 180),
	&"restart": Rect2(90, 1220, 435, 250), &"to_map": Rect2(555, 1220, 435, 250),
	&"music": Rect2(355, 1500, 150, 150), &"sound": Rect2(575, 1500, 150, 150),
}
const LANDSCAPE: Dictionary[StringName, Rect2] = {
	&"banner": Rect2(310, 40, 500, 112), &"scene": Rect2(60, 190, 1000, 0), &"level": Rect2(160, 800, 800, 50),
	&"dots": Rect2(560, 864, 0, 44), &"continue": Rect2(1130, 190, 730, 300),
	&"restart": Rect2(1130, 520, 350, 270), &"to_map": Rect2(1510, 520, 350, 270),
	&"music": Rect2(1340, 830, 130, 130), &"sound": Rect2(1520, 830, 130, 130),
}
## "Continue": icon size and font size in portrait / landscape.
const CONTINUE_ICON: Vector2 = Vector2(90, 150)
## Tiles' icon size in portrait / landscape.
const TILE_ICON: Vector2 = Vector2(96, 120)
const OFF_KEYS: Dictionary[String, String] = {"LBL_MUSIC": "LBL_MUSIC_OFF", "LBL_SOUND": "LBL_SOUND_OFF"}

@export var dot_done: StyleBox
@export var dot_now: StyleBox
@export var dot_next: StyleBox

@onready var _body: Control = $Body
@onready var _scene: Control = $Body/Diorama
@onready var _hero: AnimatedSprite2D = %Hero
@onready var _banner: Control = %Banner
@onready var _level_text: Label = %LevelText
@onready var _dots: HBoxContainer = %Dots
@onready var _button_panel: Control = %ButtonPanel
@onready var _continue: Button = %Continue
@onready var _continue_icon: TextureRect = $Body/Continue/Row/Icon
@onready var _restart: Button = %Restart
@onready var _to_map: Button = %ToMap
@onready var _music: RoundButton = %Music
@onready var _sound: RoundButton = %Sound

var _level: int = 1
var _wave: int = 1
var _waves: int = 5


func _ready() -> void:
	super()
	_continue.pressed.connect(_on_continue)
	_restart.pressed.connect(_ask.bind("CONFIRM_RESTART", restart))
	_to_map.pressed.connect(_ask.bind("CONFIRM_TO_MAP", to_map))
	_music.pressed.connect(func() -> void:
		Game.set_music(not Game.music_on)
		_show_sound())
	_sound.pressed.connect(func() -> void:
		Game.set_sound(not Game.sound_on)
		_show_sound())
	for b: Button in [_continue, _restart, _to_map]:
		UiFx.press_spring(b)
	_show_sound()
	setup(_level, _wave, _waves, null)


## The battle calls this before open(): level, current wave (0 before the
## first one), wave count and the hero's skin for the scene.
func setup(level: int, wave: int, waves: int, skin: SkinData) -> void:
	_level = level
	_wave = maxi(wave, 1)
	_waves = waves
	if skin != null and skin.ui_frames != null:
		_hero.sprite_frames = skin.ui_frames
		_hero.play(&"sad")
	_level_text.text = tr("PAUSE_LEVEL_WAVE") % [_level, _wave, _waves]
	for i: int in _dots.get_child_count():
		var dot: Panel = _dots.get_child(i) as Panel
		dot.visible = i < _waves
		var done: bool = i < _wave - 1
		dot.add_theme_stylebox_override(&"panel", dot_done if done else dot_now if i == _wave - 1 else dot_next)
		(dot.get_node(^"Check") as CanvasItem).visible = done
		var num: Label = dot.get_node(^"Num") as Label
		num.visible = not done
		num.modulate = Color.WHITE if i == _wave - 1 else Color(1, 1, 1, 0.8)
	_layout()


func open() -> void:
	super()
	_body.pivot_offset = _body.size * 0.5
	_body.modulate.a = 0.0
	var tw: Tween = _body.create_tween()
	tw.tween_property(_body, ^"modulate:a", 1.0, 0.15)


func _show_sound() -> void:
	for pair: Array in [[_music, Game.music_on, "LBL_MUSIC"], [_sound, Game.sound_on, "LBL_SOUND"]]:
		var b: RoundButton = pair[0]
		var on: bool = pair[1]
		var key: String = pair[2]
		b.off = not on
		b.label_key = key if on else OFF_KEYS[key]


## The body is laid out in mockup pixels and fitted to the screen.
func _layout() -> void:
	if not is_node_ready():
		return
	var screen: Vector2 = get_viewport_rect().size
	var portrait: bool = is_portrait()
	var design: Vector2 = Vector2(1080, 1920) if portrait else Vector2(1920, 1080)
	var k: float = minf(screen.x / design.x, screen.y / design.y)
	_body.size = design
	_body.scale = Vector2(k, k)
	_body.position = ((screen - design * k) * 0.5).floor()
	var box: Dictionary[StringName, Rect2] = PORTRAIT if portrait else LANDSCAPE
	_place(_banner, box[&"banner"])
	var s: Rect2 = box[&"scene"]
	_scene.position = s.position
	_scene.scale = Vector2.ONE * (s.size.x / 800.0)
	_place(_level_text, box[&"level"])
	_dots.reset_size()
	var d: Rect2 = box[&"dots"]
	_dots.position = Vector2(d.position.x - _dots.size.x * 0.5, d.position.y)
	_button_panel.visible = portrait
	if portrait:
		_place(_button_panel, box[&"panel"])
	_place(_continue, box[&"continue"])
	var ci: float = CONTINUE_ICON.x if portrait else CONTINUE_ICON.y
	_continue_icon.custom_minimum_size = Vector2(ci, ci)
	for tile: Button in [_restart, _to_map]:
		var icon: TextureRect = tile.get_node(^"Box/Icon") as TextureRect
		var ti: float = TILE_ICON.x if portrait else TILE_ICON.y
		icon.custom_minimum_size = Vector2(ti, ti)
	_place(_restart, box[&"restart"])
	_place(_to_map, box[&"to_map"])
	_place(_music, box[&"music"])
	_place(_sound, box[&"sound"])


static func _place(c: Control, r: Rect2) -> void:
	c.position = r.position
	c.size = r.size


func _on_continue() -> void:
	visible = false
	resume.emit()


func _ask(key: String, answer: Signal) -> void:
	if await Ui.ask(tr(key)):
		visible = false
		answer.emit()
