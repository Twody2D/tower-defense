class_name Battle
extends Node2D
## One battle: instances the level scene, wires hero, pests, coins, shots,
## plots, waves and HUD together; decides victory (all waves out, field
## clear) or defeat (no carrots) and stores the stars. Windows (pause,
## victory, defeat, "New defender!/pest!") are made with the scene and only
## shown; each of them pauses the fight.

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
## Pause between the end of the fight and the result window, s.
@export var result_delay: float = 1.2
## Start of the fight: the camera flies to where each road starts, waits and
## comes back to the hero (fly and hold times, s).
@export var spawn_fly_time: float = 1.3
@export var spawn_hold_time: float = 1.6
## Road arrows of the tour: frames (env set, "ui_edge_arrow"), step along
## the road, pop delay between arrows, size, how long they stay after it.
@export var arrow_frames: SpriteFrames
@export var arrow_step: float = 90.0
@export var arrow_delay: float = 0.05
@export var arrow_size: float = 0.8
@export var arrows_linger: float = 1.0
## Level start boosts (bought with an ad): coins, starting defender and its level.
@export var boost_defender: DefenderData
@export var boost_defender_level: int = 2
@export_file("*.tscn") var menu_scene: String = "res://scenes/map/map.tscn"
## Level scenes by number (Game.current_level); level_scene is used if missing.
@export var level_path_pattern: String = "res://scenes/levels/level_%02d.tscn"

var level: Level
var state: BattleState
var carrots_lost: int = 0
var won: bool = false
## Grains paid for the win (the result screen shows it).
var reward: int = 0
## Campaign level being played: the one picked on the map (Game.current_level);
## sandboxes without a level pattern use their LevelData number.
var level_number: int = 1

var _over: bool = false
var _chance_used: bool = false
## Newcomers waiting for their window (DefenderData / EnemyData).
var _intros: Array[Resource] = []
var _spawns_shown: bool = false
var _arrows: Node2D

@onready var _level_holder: Node2D = $World/LevelHolder
@onready var enemies: EnemyManager = $World/Enemies
@onready var coins: Coins = $World/Coins
@onready var hero: Hero = $World/Hero
@onready var projectiles: Projectiles = $World/Projectiles
@onready var fx: FxPool = $World/Fx
@onready var camera: Camera2D = $World/Hero/Camera2D
@onready var waves: WaveRunner = $WaveRunner
@onready var hud: Hud = $Hud
@onready var pause_window: PauseWindow = $Windows/PauseWindow
@onready var win_window: WinWindow = $Windows/WinWindow
@onready var lose_window: LoseWindow = $Windows/LoseWindow
@onready var defender_intro: IntroWindow = $Windows/NewDefender
@onready var enemy_intro: IntroWindow = $Windows/NewEnemy


func _ready() -> void:
	var path: String = level_path_pattern % Game.current_level
	if level_path_pattern != "" and ResourceLoader.exists(path):
		level_scene = load(path) as PackedScene
	level = level_scene.instantiate() as Level
	_level_holder.add_child(level)
	var data: LevelData = level.data
	level_number = Game.current_level if level_path_pattern != "" else data.number
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
	enemies.first_of_type.connect(_on_first_of_type)
	enemies.fx = fx
	projectiles.enemies = enemies
	projectiles.fx = fx

	hero.stats = Game.hero_stats(hero_stats)
	var skin: SkinData = Game.battle_skin()
	if skin != null:
		hero.set_skin(skin.frames, skin.projectile)
	hero.enemies = enemies
	hero.projectiles = projectiles
	hero.fx = fx
	hero.bounds = level.bounds()
	hero.position = level.hero_start()

	coins.hero = hero
	coins.magnet_radius = hero.stats.magnet_radius
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
	_wire_windows()
	_apply_boosts()
	YandexSdk.gameplay_start()
	for d: DefenderData in data.defenders:
		if Game.first_meet(d.id):
			_intros.append(d)
	_next_intro()
	if _intros.is_empty() and not get_tree().paused:
		_show_spawns()


func _wire_windows() -> void:
	pause_window.resume.connect(_resume)
	pause_window.restart.connect(_restart)
	pause_window.to_map.connect(_to_map)
	win_window.next.connect(_to_map)
	lose_window.second_chance.connect(_on_second_chance)
	lose_window.restart.connect(_restart)
	lose_window.to_map.connect(_to_map)
	defender_intro.closed.connect(_on_intro_closed)
	enemy_intro.closed.connect(_on_intro_closed)


func _apply_boosts() -> void:
	if Game.boost_coins:
		state.add_coins(Game.META.boost_coins)
	if Game.boost_defender and boost_defender != null:
		for plot: BuildPlot in level.plots():
			if not plot.fence_plot and not plot.locked:
				plot.prebuild(boost_defender, boost_defender_level)
				break
	Game.boost_coins = false
	Game.boost_defender = false


## Shows the next newcomer window, pausing the fight while it is open.
func _next_intro() -> void:
	if _intros.is_empty() or _over or defender_intro.visible or enemy_intro.visible:
		return
	var item: Resource = _intros.pop_front()
	_pause_game()
	if item is DefenderData:
		defender_intro.show_defender(item as DefenderData)
	else:
		enemy_intro.show_enemy(item as EnemyData)


func _on_intro_closed() -> void:
	Save.save()
	if _intros.is_empty():
		_resume()
		_show_spawns()
	else:
		_next_intro()


func _on_first_of_type(data: EnemyData) -> void:
	if Game.first_meet(data.id):
		_intros.append(data)
		_next_intro()


## Camera tour at the start of the fight (once): the camera glides to where
## each road starts, arrows pop one after another along the road to the
## carrots and pulse, then the camera glides back to the hero and the arrows
## fade out.
func _show_spawns() -> void:
	if _spawns_shown or _over:
		return
	_spawns_shown = true
	_arrows = Node2D.new()
	_arrows.z_index = 5
	level.add_child(_arrows)
	var tw: Tween = create_tween()
	tw.tween_callback(func() -> void:
		var at: Vector2 = camera.get_screen_center_position()
		camera.top_level = true
		camera.global_position = at)
	for road: Path2D in level.roads():
		var start: Vector2 = road.to_global(road.curve.get_point_position(0))
		tw.tween_property(camera, ^"global_position", start, spawn_fly_time) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_callback(_pop_arrows.bind(road))
		tw.tween_interval(spawn_hold_time)
	var back: Array[Vector2] = [Vector2.ZERO]
	tw.tween_callback(func() -> void: back[0] = camera.global_position)
	tw.tween_method(func(k: float) -> void:
		camera.global_position = back[0].lerp(hero.global_position + Vector2(0, -40), k),
		0.0, 1.0, spawn_fly_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func() -> void:
		camera.top_level = false
		camera.position = Vector2(0, -40))
	tw.tween_interval(arrows_linger)
	tw.tween_property(_arrows, ^"modulate:a", 0.0, 0.5)
	# Made once at the start, so freed once (not a battle-time pool object).
	tw.tween_callback(_arrows.queue_free)


## Arrows along a road, from its start to the carrots, popping in order.
func _pop_arrows(road: Path2D) -> void:
	var curve: Curve2D = road.curve
	var length: float = curve.get_baked_length()
	var n: int = int(length / arrow_step)
	for i: int in n:
		var d: float = (i + 0.5) * arrow_step
		var p: Vector2 = curve.sample_baked(d)
		var ahead: Vector2 = curve.sample_baked(minf(d + 8.0, length))
		var a: AnimatedSprite2D = AnimatedSprite2D.new()
		a.sprite_frames = arrow_frames
		a.play(&"ui_edge_arrow")
		a.position = road.to_global(p) - level.global_position
		a.rotation = (ahead - p).angle()
		a.scale = Vector2.ZERO
		_arrows.add_child(a)
		var tw: Tween = a.create_tween()
		tw.tween_interval(i * arrow_delay)
		tw.tween_property(a, ^"scale", Vector2.ONE * arrow_size, 0.2) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Then a soft pulse while the tour lasts.
		tw.tween_callback(func() -> void:
			var pulse: Tween = a.create_tween().set_loops()
			pulse.tween_property(a, ^"scale", Vector2.ONE * arrow_size * 0.85, 0.35).set_trans(Tween.TRANS_SINE)
			pulse.tween_property(a, ^"scale", Vector2.ONE * arrow_size, 0.35).set_trans(Tween.TRANS_SINE))


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
## Esc with the pick menu open only closes the menu; newcomer windows wait
## for their button.
func _toggle_pause() -> void:
	if _over or defender_intro.visible or enemy_intro.visible:
		return
	if hud.radial_menu.visible:
		hud.radial_menu.close()
		return
	if pause_window.visible:
		pause_window.visible = false
		_resume()
	else:
		_pause_game()
		pause_window.open()


func _pause_game() -> void:
	get_tree().paused = true
	_release_input()
	YandexSdk.gameplay_stop()


func _resume() -> void:
	if _over:
		return
	get_tree().paused = false
	YandexSdk.gameplay_start()


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


## Back to the farm map (fullscreen ad point: level → map).
func _to_map() -> void:
	get_tree().paused = false
	Ads.on_level_exit(level_number)
	get_tree().change_scene_to_file(menu_scene)


## +5 carrots, the fight goes on (once per level).
func _on_second_chance() -> void:
	_chance_used = true
	_over = false
	hero.revive()
	state.give_carrots(lose_window.chance_carrots)
	_resume()


func _on_won() -> void:
	won = true
	var s: int = stars()
	reward = Game.finish_level(level_number, s)
	Save.save()
	fx.play(&"confetti", hero.global_position + Vector2(0, -120), 2.0, true)
	if await _finish(s):
		win_window.show_result(s, reward)


func _on_lost() -> void:
	if await _finish(0):
		lose_window.show_result(not _chance_used)


## Stops the fight; after a short look at the field the result window opens
## (false if the scene is gone by then).
func _finish(s: int) -> bool:
	if _over:
		return false
	_over = true
	# A tried-on skin lasts one level.
	if won:
		Game.trial_skin = &""
	YandexSdk.gameplay_stop()
	_release_input()
	hud.radial_menu.close()
	hero.finish(won)
	get_tree().paused = true
	finished.emit(won, s)
	await get_tree().create_timer(result_delay, true).timeout
	return is_inside_tree()
