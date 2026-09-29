class_name Battle
extends Node2D
## One battle: instances the level scene, wires hero, pests, coins, shots,
## plots and HUD together, runs the (temporary) wave spawner.

@export var level_scene: PackedScene
@export var hero_stats: HeroStats
## World px shown along the short side of the screen (design H: the 1080 wide
## portrait mockup shows the world 1:1).
@export var visible_short_side: float = 1080.0
## Delay before the first wave, s.
@export var first_wave_delay: float = 3.0
## All defenders in radial menu order; the level opens some of them.
@export var defender_catalog: Array[DefenderData] = []
@export_file("*.tscn") var menu_scene: String = "res://scenes/ui/main_menu.tscn"

var level: Level
var state: BattleState
var wave: int = 0

var _to_spawn: int = 0
var _spawn_timer: float = 0.0
var _wave_timer: float = 0.0
var _over: bool = false

@onready var _level_holder: Node2D = $World/LevelHolder
@onready var enemies: EnemyManager = $World/Enemies
@onready var coins: Coins = $World/Coins
@onready var hero: Hero = $World/Hero
@onready var projectiles: Projectiles = $World/Projectiles
@onready var camera: Camera2D = $World/Hero/Camera2D
@onready var hud: Hud = $Hud


func _ready() -> void:
	level = level_scene.instantiate() as Level
	_level_holder.add_child(level)
	var data: LevelData = level.data
	state = BattleState.new(data.start_coins, data.carrots)

	var types: Array[EnemyData] = [data.test_enemy]
	enemies.setup(level.road_curve(), types)
	enemies.defeated.connect(_on_enemy_defeated)
	enemies.reached_base.connect(_on_enemy_reached_base)
	projectiles.enemies = enemies

	hero.stats = hero_stats
	hero.enemies = enemies
	hero.projectiles = projectiles
	hero.bounds = level.bounds()
	hero.position = level.hero_start()

	coins.hero = hero
	coins.magnet_radius = hero_stats.magnet_radius
	coins.collected.connect(state.add_coins)

	for plot: BuildPlot in level.plots():
		plot.hero = hero
		plot.state = state
		plot.options = data.defenders
		plot.attach(enemies, projectiles)
		plot.menu_requested.connect(_on_menu_requested)

	hud.bind(state)
	hud.joystick.changed.connect(_on_joystick)
	hud.pause_pressed.connect(_toggle_pause)
	hud.radial_menu.picked.connect(_on_defender_picked)
	hud.radial_menu.closed.connect(_on_menu_closed)
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

	_wave_timer = first_wave_delay
	hud.set_wave(0)
	YandexSdk.gameplay_start()


func _process(delta: float) -> void:
	if _over:
		return
	_run_waves(delta)
	hud.set_debug("%d fps · %d pests · %d coins" % [Engine.get_frames_per_second(), enemies.count, coins.count])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_toggle_pause()


## Grey prototype spawner: waves of one pest type that grow each time.
func _run_waves(delta: float) -> void:
	var data: LevelData = level.data
	if _to_spawn > 0:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_timer += data.test_spawn_interval
			enemies.spawn(data.test_enemy, data.hp_multiplier())
			_to_spawn -= 1
			if _to_spawn == 0:
				_wave_timer = data.test_wave_pause
		return
	_wave_timer -= delta
	if _wave_timer <= 0.0:
		wave += 1
		_to_spawn = data.test_wave_base + data.test_wave_growth * (wave - 1)
		_spawn_timer = 0.0
		hud.set_wave(wave)


func _update_zoom() -> void:
	var size: Vector2 = get_viewport_rect().size
	var z: float = minf(size.x, size.y) / visible_short_side
	camera.zoom = Vector2(z, z)


func _on_joystick(dir: Vector2) -> void:
	hero.joystick = dir


func _on_enemy_defeated(pos: Vector2, data: EnemyData) -> void:
	coins.drop(pos, data.coins)


func _on_enemy_reached_base(data: EnemyData) -> void:
	state.take_carrots(data.carrots)


## Hero stepped on an empty plot: pause and show the defender pick.
func _on_menu_requested(plot: BuildPlot) -> void:
	if _over or get_tree().paused:
		return
	get_tree().paused = true
	_release_input()
	hud.radial_menu.open(plot, defender_catalog, plot.options)


func _on_defender_picked(plot: BuildPlot, data: DefenderData) -> void:
	plot.choose(data)


func _on_menu_closed() -> void:
	if not _over:
		get_tree().paused = false


func _release_input() -> void:
	hud.joystick.release()
	hero.joystick = Vector2.ZERO


func _toggle_pause() -> void:
	if _over or hud.radial_menu.visible:
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


func _on_lost() -> void:
	_over = true
	YandexSdk.gameplay_stop()
	hud.show_message(tr("MSG_LOST"))
	get_tree().paused = true
	await get_tree().create_timer(2.5).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
