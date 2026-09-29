class_name BuildPlot
extends Node2D
## Build plot (design: dark green rhombus 128×96 with a dashed frame and a price).
## The hero stands on it → coins go in one by one → at the full price the
## defender appears; standing again upgrades it (up to max level). Leaving
## keeps the paid progress.

signal built(plot: BuildPlot, level: int)
signal coin_paid(plot: BuildPlot)

@export var defender_data: DefenderData
## Rhombus half-size (pad 128×96 from the design), px.
@export var half_size: Vector2 = Vector2(64, 48)
## A full price is paid in about this time (cheap ones go at max_interval per coin), s.
@export var fill_time: float = 1.2
@export var max_interval: float = 0.09

var level: int = 0
var paid: int = 0
var hero: Hero
var state: BattleState

var _timer: float = 0.0
var _hero_on: bool = false

@onready var defender: Defender = $Defender


func _ready() -> void:
	defender.data = defender_data


func is_max() -> bool:
	return level >= defender_data.max_level()


## Price of the next level (0 when maxed).
func next_price() -> int:
	return 0 if is_max() else defender_data.price(level + 1)


func contains(world_pos: Vector2) -> bool:
	var d: Vector2 = (world_pos - global_position).abs()
	return d.x / half_size.x + d.y / half_size.y <= 1.0


func _process(delta: float) -> void:
	var on: bool = hero != null and contains(hero.global_position) and not hero.is_stunned()
	if on != _hero_on:
		_hero_on = on
		_timer = 0.0
		queue_redraw()
	if not on or is_max():
		return
	_timer -= delta
	while _timer <= 0.0 and not is_max():
		if not state.spend(1):
			return
		paid += 1
		coin_paid.emit(self)
		_timer += minf(max_interval, fill_time / float(next_price()))
		if paid >= next_price():
			paid = 0
			level += 1
			defender.set_level(level)
			built.emit(self, level)
		queue_redraw()


func _draw() -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		Vector2(0, -half_size.y), Vector2(half_size.x, 0), Vector2(0, half_size.y), Vector2(-half_size.x, 0)])
	var fill: Color = Color("2e6b35") if not _hero_on else Color("3a8a44")
	draw_colored_polygon(pts, fill)
	# Dashed white frame.
	for k: int in 4:
		var a: Vector2 = pts[k]
		var b: Vector2 = pts[(k + 1) % 4]
		draw_dashed_line(a.lerp(b, 0.08), b.lerp(a, 0.08), Color.WHITE, 4.0, 10.0)
	if is_max():
		return
	var price: int = next_price()
	if paid > 0:
		draw_arc(Vector2(0, 0), 30.0, -PI * 0.5, -PI * 0.5 + TAU * float(paid) / float(price), 32, Color("ffc933"), 6.0)
	# Price in the middle of an empty plot, under the defender on a built one.
	var y: float = 0.0 if level == 0 else half_size.y + 16.0
	var fs: int = 30 if level == 0 else 24
	var font: Font = ThemeDB.get_project_theme().default_font
	var text: String = str(price - paid)
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base: Vector2 = Vector2(-w * 0.5 - 10, y + fs * 0.36)
	draw_string_outline(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 6, Color("2b2b3a"))
	draw_string(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	draw_circle(Vector2(w * 0.5 + 6, y), fs * 0.33, Color("ffc933"))
	draw_circle(Vector2(w * 0.5 + 6, y), fs * 0.33, Color("2b2b3a"), false, 2.0)
