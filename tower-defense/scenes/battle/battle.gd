class_name Battle
extends Node2D
## One battle: instances the level scene, wires hero, pests, coins, shots,
## plots, waves and HUD together; decides victory (all waves out, field
## clear) or defeat (no carrots) and stores the stars.

signal finished(won: bool, stars: int)

@export var level_scene: PackedScene
@export var hero_stats: HeroStats
## World px shown along the short side of the screen (design H: the 1080 wide
## portrait mockup shows the world 1:1).
@export var visible_short_side: float = 1080.0
## All defenders in radial menu order; the level opens some of them.
@export var defender_catalog: Array[DefenderData] = []
## Camera shake when carrots are taken / the boss hits the hero, px.
@export var shake_carrot: float = 10.0
@export var shake_boss: float = 18.0
## Pause on the result message before going back to the menu, s.
@export var result_delay: float = 3.0
@export_file("*.tscn") var menu_scene: String = "res://scenes/ui/main_menu.tscn"

var level: Level
var state: BattleState
var carrots_lost: int = 0
var won: bool = false

var _over: bool = false

@onready var _level_holder: Node2D = $World/LevelHolder
@onready var enemies: EnemyManager = $World/Enemies
@onready var coins: Coins = $World/Coins
@onready var hero: Hero = $World/Hero
@onready var projectiles: Projectiles = $World/Projectiles
@onready var fx: FxPool = $World/Fx
@onready var camera: Camera2D = $World/Hero/Camera2D
@onready var waves: WaveRunner = $WaveRunner
@onready var hud: Hud = $Hud


func _ready() -> void:
	level = level_scene.instantiate() as Level
	_level_holder.add_child(level)
	var data: LevelData = level.data
	state = BattleState.new(data.start_coins, data.carrots)

	var curves: Array[Curve2D] = []
	for road: Path2D in level.roads():
		curves.append(road.curve)
	enemies.setup(curves, level.bounds(), data.enemy_types())
	enemies.hero = hero
	enemies.defeated.connect(_on_enemy_defeated)
	enemies.reached_base.connect(_on_enemy_reached_base)
	enemies.hero_struck.connect(hero.stun)
	enemies.hero_struck.connect(shake.bind(shake_boss, 0.35))
	enemies.boss_spawned.connect(_on_boss_spawned)
	enemies.fx = fx
	projectiles.enemies = enemies
	projectiles.fx = fx

	hero.stats = hero_stats
	hero.enemies = enemies
	hero.projectiles = projectiles
	hero.fx = fx
	hero.bounds = level.bounds()
	hero.position = level.hero_start()

	coins.hero = hero
	coins.magnet_radius = hero_stats.magnet_radius
	coins.collected.connect(state.add_coins)

	for plot: BuildPlot in level.plots():
		plot.hero = hero
		plot.state = state
		plot.options = data.defenders
		plot.attach(enemies, projectiles, fx)
		plot.menu_requested.connect(_on_menu_requested)
		plot.built.connect(_on_plot_built)
		plot.coin_paid.connect(_on_coin_paid)
		plot.hero_left.connect(_on_hero_left_plot)

	hud.bind(state)
	hud.joystick.changed.connect(_on_joystick)
	hud.pause_pressed.connect(_toggle_pause)
	hud.call_pressed.connect(_on_call_now)
	hud.radial_menu.picked.connect(_on_defender_picked)
	level.base().set_carrots(state.carrots)
	state.carrots_changed.connect(level.base().set_carrots)
	state.carrots_gone.connect(_on_lost)

	var b: Rect2 = level.bounds()
	camera.limit_left = int(b.position.x)
	camera.limit_top = int(b.position.y)
	camera.limit_right = int(b.end.x)
	camera.limit_bottom = int(b.end.y)
	get_viewport().size_changed.connect(_update_zoom)
	_update_zoom()
	camera.reset_smoothing()

	waves.wave_started.connect(_on_wave_started)
	waves.start(data, enemies)
	hud.set_wave(0, waves.total())
	YandexSdk.gameplay_start()


func _process(_delta: float) -> void:
	if _over:
		return
	hud.show_break(waves.break_left if waves.in_break() else 0.0)
	level.set_spawning(not waves.in_break() and not waves.is_done())
	hud.set_debug("%d fps · %d pests · %d coins" % [Engine.get_frames_per_second(), enemies.count, coins.count])
	if waves.is_done() and enemies.count == 0:
		_on_won()


func stars() -> int:
	return level.data.stars_for(carrots_lost)


func _update_zoom() -> void:
	var size: Vector2 = get_viewport_rect().size
	var z: float = minf(size.x, size.y) / visible_short_side
	camera.zoom = Vector2(z, z)


func _on_joystick(dir: Vector2) -> void:
	hero.joystick = dir


func _on_wave_started(number: int, total: int) -> void:
	hud.set_wave(number, total)


## "Call now": the next wave comes at once, +1 coin per second of the break left.
func _on_call_now() -> void:
	var bonus: int = waves.call_now()
	if bonus > 0:
		state.add_coins(bonus)


func _on_enemy_defeated(pos: Vector2, data: EnemyData) -> void:
	coins.drop(pos, data.coins)


## Camera shake: a few random offsets, then back to rest.
func shake(strength: float, time: float) -> void:
	var tw: Tween = camera.create_tween()
	var steps: int = 6
	for k: int in steps:
		var fade: float = 1.0 - float(k) / steps
		var o: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * fade
		tw.tween_property(camera, ^"offset", o, time / (steps + 1))
	tw.tween_property(camera, ^"offset", Vector2.ZERO, time / (steps + 1))


func _on_enemy_reached_base(data: EnemyData) -> void:
	shake(shake_carrot * minf(data.carrots, 3), 0.25)
	var before: int = state.carrots
	state.take_carrots(data.carrots)
	carrots_lost += before - state.carrots


func _on_boss_spawned(_id: int, _data: EnemyData) -> void:
	hud.show_message(tr("MSG_BOSS"))
	await get_tree().create_timer(2.0, false).timeout
	if not _over:
		hud.show_message("")


## Hero stepped on an empty plot: the defender pick, the game goes on.
func _on_menu_requested(plot: BuildPlot) -> void:
	if _over or get_tree().paused:
		return
	hud.radial_menu.open(plot, defender_catalog, plot.options)


## Build flash for a new defender / fence, sparks for an upgrade.
func _on_plot_built(plot: BuildPlot, new_level: int) -> void:
	fx.play(&"build_flash" if new_level == 1 else &"upgrade", plot.global_position + Vector2(0, -48), 1.5)


## A coin flies from the hero's paws into the plot.
func _on_coin_paid(plot: BuildPlot) -> void:
	fx.fly(&"coin_trail", hero.global_position + Vector2(0, -60), plot.global_position, 0.2, 1.5)


func _on_hero_left_plot(plot: BuildPlot) -> void:
	if hud.radial_menu.plot == plot:
		hud.radial_menu.close()


func _on_defender_picked(plot: BuildPlot, data: DefenderData) -> void:
	plot.choose(data)


func _release_input() -> void:
	hud.joystick.release()
	hero.joystick = Vector2.ZERO


## Pause button, Esc / P (the HUD catches the key: it runs while paused).
## Esc with the pick menu open only closes the menu.
func _toggle_pause() -> void:
	if _over:
		return
	if hud.radial_menu.visible:
		hud.radial_menu.close()
		return
	var tree: SceneTree = get_tree()
	tree.paused = not tree.paused
	_release_input()
	if tree.paused:
		YandexSdk.gameplay_stop()
		hud.show_message(tr("MSG_PAUSED"))
	else:
		YandexSdk.gameplay_start()
		hud.show_message("")


func _on_won() -> void:
	won = true
	var s: int = stars()
	var index: int = level.data.number - 1
	if index >= 0 and index < Game.level_stars.size():
		Game.level_stars[index] = maxi(Game.level_stars[index], s)
		Save.save()
	fx.play(&"confetti", hero.global_position + Vector2(0, -120), 2.0, true)
	_finish(tr("MSG_WON") + "  " + "★".repeat(s), s)


func _on_lost() -> void:
	_finish(tr("MSG_LOST"), 0)


## Result for now: a message, then back to the menu (win/lose screens: stage 6).
func _finish(message: String, s: int) -> void:
	if _over:
		return
	_over = true
	YandexSdk.gameplay_stop()
	_release_input()
	hero.finish(won)
	hud.show_message(message)
	get_tree().paused = true
	finished.emit(won, s)
	await get_tree().create_timer(result_delay).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file(menu_scene)
