extends Node
## Stress test (CODE_PROMPT gate: 250 pests at 60 FPS on a phone): keeps
## `target` pests of mixed types on the field, every plot built at level 3,
## big FPS / frame time read-out. Lives in dev/, so the release build skips it.
## PC: `-- uncapped` removes vsync and the FPS cap to show the headroom.
## Web: `?n=100` in the address sets the pest count (compare 0 / 100 / 250).
## PC profiling: `-- uncapped nobars nopests nolevel nohud` hides that part.

@export var target: int = 250
@export var types: Array[EnemyData] = []
@export var spawn_per_frame: int = 4

var _battle: Battle
var _label: Label
var _frames: int = 0
var _worst: float = 0.0
var _sum: float = 0.0
var _pest_usec: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_battle = get_parent() as Battle
	if "uncapped" in OS.get_cmdline_user_args():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
	if OS.has_feature("web"):
		var location: JavaScriptObject = JavaScriptBridge.get_interface("location")
		var search: String = str(location.get("search"))
		if search.begins_with("?n="):
			target = search.substr(3).to_int()
	await get_tree().process_frame
	# No newcomer windows: they pause the fight (a fresh save meets everyone).
	for d: DefenderData in _battle.defender_catalog:
		Game.first_meet(d.id)
	for e: EnemyData in types:
		Game.first_meet(e.id)
	_battle._intros.clear()
	_battle.defender_intro.visible = false
	_battle.enemy_intro.visible = false
	_battle._resume()
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var em0: EnemyManager = _battle.enemies
	for n: Node in em0.get_children():
		var c: CanvasItem = n as CanvasItem
		if "nobars" in args and n.name.begins_with("Hp"):
			c.visible = false
		if "nopests" in args and not n.name.begins_with("Hp"):
			c.visible = false
	if "nolevel" in args:
		_battle.level.visible = false
	if "nohud" in args:
		_battle.hud.visible = false
	for plot: BuildPlot in _battle.level.plots():
		if plot.fence_plot:
			continue
		plot.choose(_battle.defender_catalog[_rng.randi() % _battle.defender_catalog.size()])
		plot.level = 3
		plot.defender.set_level(3)
		plot.defender.finish_build()
		plot._refresh()
	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", 34)
	_label.add_theme_constant_override(&"outline_size", 8)
	_label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	_label.position = Vector2(20, 90)
	_battle.hud.add_child(_label)


func _process(delta: float) -> void:
	var em: EnemyManager = _battle.enemies
	for n: int in spawn_per_frame:
		if em.count < target:
			em.spawn(types[_rng.randi() % types.size()], 3.0, 0)
	_frames += 1
	_sum += delta
	_worst = maxf(_worst, delta)
	_pest_usec += em.last_usec
	if _frames % 30 == 0 and _label != null:
		_label.text = "%d FPS   %d pests\nframe %.1f ms (worst %.1f)\npests code %.2f ms" % [
			Engine.get_frames_per_second(), em.count, _sum / 30.0 * 1000.0, _worst * 1000.0,
			_pest_usec / 30.0 / 1000.0]
		print(_label.text.replace("\n", " | "))
		_sum = 0.0
		_worst = 0.0
		_pest_usec = 0
