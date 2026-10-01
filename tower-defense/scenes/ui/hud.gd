class_name Hud
extends CanvasLayer
## Battle HUD (design H): coins and carrots top-left, pause top-right,
## wave line in the centre, floating joystick. Sizes are the 1080 mockup × 2/3.

signal pause_pressed
signal call_pressed

## Wave line lift in landscape: the top centre is free there, so the wave
## line sits level with the counters instead of under them, px.
@export var landscape_lift: float = 84.0
## Banner centre: portrait — this far from the top (under the boss bar, the
## hero is lower); landscape — this far below the screen centre (little height).
@export var banner_top_portrait: float = 560.0
@export var banner_below_landscape: float = 220.0
## Bonus rings: landscape — a row under the counters; portrait — a column
## under the pause button (design H).
@export var rings_landscape: Vector2 = Vector2(33, 108)
@export var rings_portrait_top: float = 136.0
## Parcel / free gift pointer icons at the screen edge.
@export var parcel_icon: Texture2D
@export var gift_icon: Texture2D

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
@onready var _banner: HudBanner = $Banner
@onready var _boss_bar: BossBar = $TopCenter/BossBar
@onready var _edge_boss: EdgeArrow = $EdgeBoss
@onready var _edge_pests: EdgeArrow = $EdgePests
@onready var _edge_parcel: EdgeArrow = $EdgeParcel
@onready var _rings: BoxContainer = $Rings
@onready var _popups: Control = $Popups

## Seconds on the break timer now (it is rewritten only when they change).
var _break_shown: int = -1

var _next_popup: int = 0

var _max_carrots: int = 20
var _carrots_shown: int = -1
var _wave_shown: int = -1


func _ready() -> void:
	# FPS and counts: only in debug builds (editor, stress test), not for players.
	_debug.visible = OS.is_debug_build()
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
	var cy: float = s.y * 0.5 + banner_below_landscape if s.x > s.y else banner_top_portrait
	_banner.position = Vector2((s.x - _banner.size.x) * 0.5, cy - _banner.size.y * 0.5)
	var portrait: bool = s.y > s.x
	_rings.vertical = portrait
	_rings.reset_size()
	if portrait:
		# Centred under the pause button.
		var pause_centre: float = _pause.get_global_rect().get_center().x
		_rings.position = Vector2(pause_centre - _rings.size.x * 0.5, rings_portrait_top)
	else:
		_rings.position = rings_landscape


## Esc / P: the HUD runs while the game is paused, so the key also resumes.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		# A closable window on top (a "Sure?" over the pause) goes first.
		if not UiWindow.close_top():
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
	if seconds_left <= 0.0 or _boss_bar.visible:
		_timer_row.visible = false
		return
	_timer_row.visible = true
	var s: int = int(ceilf(seconds_left))
	if s == _break_shown:
		return
	_break_shown = s
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


## "Wave 4!" in the middle of the screen.
func show_wave_banner(n: int) -> void:
	_banner.show_banner(tr("HUD_WAVE_BANNER") % n)


## "The Fox is coming!" with its portrait, and its HP bar instead of the timer.
func show_boss(data: EnemyData) -> void:
	_banner.show_banner(tr(data.name_key + "_COMING"), data.portrait)
	_timer_row.visible = false
	_boss_bar.show_boss(data.portrait)


func set_boss_hp(share: float) -> void:
	_boss_bar.set_value(share)


func hide_boss() -> void:
	_boss_bar.visible = false


## Edge pointers; `target` in screen coordinates, off screen. `boss`: the
## boss pointer, otherwise the one to the nearest pest.
func point_edge(boss: bool, target: Vector2, icon: Texture2D) -> void:
	var edge: EdgeArrow = _edge_boss if boss else _edge_pests
	edge.point(target, get_viewport().get_visible_rect(), icon)


func hide_edge(boss: bool) -> void:
	(_edge_boss if boss else _edge_pests).visible = false


## Pointer to the parcel (or the free gift) lying off screen (`target` in
## screen coordinates).
func point_parcel(target: Vector2, is_gift: bool = false) -> void:
	_edge_parcel.point(target, get_viewport().get_visible_rect(), gift_icon if is_gift else parcel_icon)


func hide_parcel_edge() -> void:
	_edge_parcel.visible = false


## Rings of the running bonuses (icon and time left 0..1), in this order.
func show_rings(icons: Array[Texture2D], shares: PackedFloat32Array) -> void:
	var was: int = _visible_rings()
	for i: int in _rings.get_child_count():
		var ring: BonusRing = _rings.get_child(i) as BonusRing
		if i < icons.size():
			ring.show_bonus(icons[i], shares[i])
		else:
			ring.visible = false
	if _visible_rings() != was:
		_layout()


func _visible_rings() -> int:
	var n: int = 0
	for c: Node in _rings.get_children():
		if (c as Control).visible:
			n += 1
	return n


## "Gold rain!" with the bonus icon above the ribbon.
func show_bonus_banner(text: String, icon: Texture2D) -> void:
	_banner.show_banner(text, icon, false)


## Gold "+N" that floats up from `at` (screen coordinates) and fades.
func popup(at: Vector2, text: String) -> void:
	var label: Label = _popups.get_child(_next_popup) as Label
	_next_popup = (_next_popup + 1) % _popups.get_child_count()
	label.text = text
	label.position = at - Vector2(label.size.x * 0.5, 40.0)
	label.modulate.a = 1.0
	label.visible = true
	var tw: Tween = label.create_tween()
	tw.tween_property(label, ^"position:y", label.position.y - 70.0, 0.7).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, ^"modulate:a", 0.0, 0.7).set_delay(0.3)
	tw.tween_callback(label.hide)
