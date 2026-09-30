class_name Tutorial
extends Node
## Level 1 tutorial (CODE_PROMPT: swipe, plot, defender pick, coins; design I
## screen 18) and level 2 tips (fence, upgrade). Level 1 holds the first
## wave until the first defender stands. Steps follow what the player really
## does: running onto a plot early skips "move", leaving the plot before the
## pick goes back to "stand on a plot".

enum Step { OFF, MOVE, PLOT, PICK, BUILD, COINS, FENCE, UPGRADE }

## Hole radii around targets, screen px.
@export var hero_radius: float = 120.0
@export var plot_radius: float = 110.0
@export var slot_radius: float = 80.0
@export var coin_radius: float = 110.0
## "Move" is done after running this far, px.
@export var move_distance: float = 220.0
## The coins hint lasts until this many coins are picked or this long, s.
@export var coins_to_pick: int = 3
@export var coins_time: float = 8.0
## Level 2 tips go away by themselves after this long, s.
@export var tip_time: float = 12.0

var battle: Battle
var step: Step = Step.OFF

var _plot: BuildPlot
var _moved: float = 0.0
var _last_hero: Vector2 = Vector2.ZERO
var _coins_at: int = 0
var _left: float = 0.0

@onready var layer: TutorialLayer = $TutorialLayer


## Level 1 teaches (once per save); level 2 shows its tips once.
func needed(level_number: int) -> bool:
	return (level_number == 1 and not Game.tutorial_done) or level_number == 2


## Called when the camera tour is over.
func start(level_number: int) -> void:
	if level_number == 1 and not Game.tutorial_done:
		_last_hero = battle.hero.global_position
		_go(Step.MOVE)
	elif level_number == 2 and _fence_plot() != null and Game.first_meet(&"tut_fence"):
		_left = tip_time
		_go(Step.FENCE)


## End of the fight: hints go away (the level 1 tutorial starts over next time).
func stop() -> void:
	_go(Step.OFF)


func _go(s: Step) -> void:
	step = s
	if s == Step.OFF:
		layer.clear()


func _process(delta: float) -> void:
	if step == Step.OFF or battle == null:
		return
	var hero: Hero = battle.hero
	var menu: RadialMenu = battle.hud.radial_menu
	var to_screen: Transform2D = battle.get_viewport().get_canvas_transform()
	var hero_at: Vector2 = to_screen * (hero.global_position + Vector2(0, -50))
	match step:
		Step.MOVE:
			_moved += hero.global_position.distance_to(_last_hero)
			_last_hero = hero.global_position
			var touch: bool = DisplayServer.is_touchscreen_available()
			layer.point(tr("TUT_MOVE_TOUCH" if touch else "TUT_MOVE_KEYS"), hero_at, hero_radius, true,
					&"swipe" if touch else &"")
			if menu.visible:
				_go(Step.PICK)
			elif _moved >= move_distance:
				_go(Step.PLOT)
		Step.PLOT:
			if menu.visible:
				_go(Step.PICK)
				return
			_plot = _free_plot()
			if _plot == null:
				_go(Step.BUILD)
				return
			layer.point(tr("TUT_PLOT"), to_screen * _plot.global_position, plot_radius, true, &"arrow", true)
		Step.PICK:
			if menu.plot != null:
				_plot = menu.plot
			if _plot != null and _plot.chosen != null:
				_go(Step.BUILD)
				return
			if not menu.visible:
				_go(Step.PLOT)
				return
			var goose: DefenderData = battle.level.data.defenders[0]
			var slot: Vector2 = menu.slot_centre(goose)
			if slot != Vector2.INF:
				layer.point(tr("TUT_PICK"), slot, slot_radius, true, &"tap", true)
		Step.BUILD:
			if _plot == null or _plot.chosen == null:
				_go(Step.PLOT)
				return
			if _plot.level >= 1:
				battle.waves.hold = false
				_coins_at = battle.state.coins
				_left = coins_time
				layer.clear()
				_go(Step.COINS)
				return
			layer.point(tr("TUT_BUILD"), to_screen * _plot.global_position, plot_radius, true, &"arrow", true)
		Step.COINS:
			# Waits for the first coins on the ground, then points at one.
			if battle.coins.count == 0:
				_coins_at = battle.state.coins
				return
			_left -= delta
			if battle.state.coins - _coins_at >= coins_to_pick or _left <= 0.0:
				Game.tutorial_done = true
				Save.save()
				_go(Step.OFF)
				return
			layer.point(tr("TUT_COINS"), to_screen * battle.coins.position_of(0), coin_radius, true, &"arrow")
		Step.FENCE:
			var fence: BuildPlot = _fence_plot()
			_left -= delta
			if fence == null or fence.level > 0 or _left <= 0.0:
				_left = tip_time
				_go(Step.UPGRADE)
				return
			layer.point(tr("TUT_FENCE"), to_screen * fence.global_position, plot_radius, false, &"arrow", true)
		Step.UPGRADE:
			# Only once a built defender can really be raised.
			var up: BuildPlot = _upgradable_plot()
			if up == null:
				layer.clear()
				return
			if not Game.seen.has(&"tut_upgrade"):
				Game.first_meet(&"tut_upgrade")
				_left = tip_time
			_left -= delta
			if _left <= 0.0 or up.paid > 0:
				_go(Step.OFF)
				return
			layer.point(tr("TUT_UPGRADE"), to_screen * up.global_position, plot_radius, false, &"arrow", true)


## The nearest empty open plot for a defender.
func _free_plot() -> BuildPlot:
	var best: BuildPlot = null
	var best_d: float = INF
	for p: BuildPlot in battle.level.plots():
		if p.fence_plot or p.locked or p.level > 0:
			continue
		var d: float = p.global_position.distance_to(battle.hero.global_position)
		if d < best_d:
			best_d = d
			best = p
	return best


func _fence_plot() -> BuildPlot:
	for p: BuildPlot in battle.level.plots():
		if p.fence_plot and not p.locked:
			return p
	return null


func _upgradable_plot() -> BuildPlot:
	for p: BuildPlot in battle.level.plots():
		if not p.fence_plot and p.level > 0 and not p.is_max() and battle.state.coins >= p.next_price():
			return p
	return null
