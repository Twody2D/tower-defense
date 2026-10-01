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
## Start of the fight (Twody): the camera glides to each burrow at the play
## zoom (speed px/s, each glide within min..max s), waits there, then glides
## back to the hero together with the arrows of the last road.
@export var tour_speed: float = 1200.0
@export var tour_glide_min: float = 1.2
@export var tour_glide_max: float = 2.0
@export var tour_return_max: float = 3.5
@export var spawn_hold_time: float = 0.5
## Road arrows of the tour: frames (env set, "ui_edge_arrow"), step along
## the road, size, how long they stay after the tour.
@export var arrow_frames: SpriteFrames
@export var arrow_step: float = 90.0
@export var arrow_size: float = 1.3
@export var arrows_linger: float = 1.0
## Arrows run from a burrow to the carrots at this speed once the camera is
## there, px/s; the camera glides back about as fast.
@export var arrow_run_speed: float = 1100.0
## Edge pointers are updated this often, s.
@export var edge_check_every: float = 0.2
## Level start boost (bought with an ad): the starting defender (level: AdRewards).
@export var boost_defender: DefenderData
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
## The tutorial hint was on screen when the pause opened (it comes back after).
var _hint_hidden: bool = false
## The fps line (debug builds only), updated 4 times a second.
var _debug_shown: bool = OS.is_debug_build()
var _debug_left: float = 0.0
## Newcomers waiting for their window (DefenderData / EnemyData).
var _intros: Array[Resource] = []
var _spawns_shown: bool = false
var _arrows: Node2D
var _boss_id: int = 0
var _edge_left: float = 0.0
## Waves left until the next parcel falls.
var _parcel_in: int = 0

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
@onready var parcel_window: ParcelWindow = $Windows/ParcelWindow
@onready var parcel: Parcel = $World/Parcel
@onready var gift: Parcel = $World/GiftDrop
@onready var helper: Helper = $World/Helper
@onready var bonuses: Bonuses = $World/Bonuses
@onready var tutorial: Tutorial = $Tutorial


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
	enemies.hero_struck.connect(Audio.sfx.bind(&"stun", true))
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
	hero.road_check = level.is_road
	hero.position = level.hero_start()

	coins.hero = hero
	coins.magnet_radius = hero.stats.magnet_radius
	coins.collected.connect(state.add_coins)
	coins.collected.connect(_on_coins_collected)

	for plot: BuildPlot in level.plots():
		plot.hero = hero
		plot.state = state
		plot.options = data.defenders
		plot.attach(enemies, projectiles, fx)
		plot.menu_requested.connect(_on_menu_requested)
		plot.built.connect(_on_plot_built)
		plot.coin_paid.connect(_on_coin_paid)
		plot.hero_left.connect(_on_hero_left_plot)

	for crop: BattleCrop in level.crops():
		crop.hero = hero
		crop.coin_drop.connect(coins.drop)

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
	_wire_parcel()
	tutorial.battle = self
	# Level 1 tutorial: the first wave waits for the first defender.
	waves.hold = level_number == 1 and not Game.tutorial_done
	_apply_boosts()
	YandexSdk.gameplay_start()
	YandexSdk.paused.connect(_on_sdk_paused)
	Audio.music(&"battle")
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


## "Посылка от фермера": the parcel, its pick window, the bonuses and the helper.
func _wire_parcel() -> void:
	var ads: AdRewards = Game.ADS
	_parcel_in = randi_range(ads.parcel_every_min, ads.parcel_every_max)
	parcel.hero = hero
	parcel.fx = fx
	parcel.lifetime = ads.parcel_lifetime
	parcel.blink = ads.parcel_blink
	parcel.pickup = ads.parcel_pickup
	parcel.picked.connect(_on_parcel_picked)
	gift.hero = hero
	gift.fx = fx
	gift.lifetime = ads.parcel_lifetime
	gift.blink = ads.parcel_blink
	gift.pickup = ads.parcel_pickup
	gift.picked.connect(_on_gift_picked)
	parcel_window.picked.connect(_on_bonus_picked)
	parcel_window.declined.connect(_resume)
	helper.hero = hero
	helper.enemies = enemies
	helper.projectiles = projectiles
	helper.fx = fx
	helper.stats = hero.stats
	bonuses.hero = hero
	bonuses.coins = coins
	bonuses.enemies = enemies
	bonuses.fx = fx
	bonuses.helper = helper
	bonuses.camera = camera
	bonuses.hud = hud
	bonuses.plots = level.plots()
	bonuses.roads = level.roads()
	bonuses.bounds = level.bounds()
	bonuses.setup()


## Every 2–3 waves the ad parcel falls near the hero a few seconds after the
## wave starts; on the other waves a free gift does.
func _count_parcel() -> void:
	var ads: AdRewards = Game.ADS
	_parcel_in -= 1
	# A pausable timer: it waits while the game is paused.
	var timer: SceneTreeTimer = get_tree().create_timer(ads.parcel_delay, false)
	if _parcel_in > 0:
		timer.timeout.connect(_drop_gift)
		return
	_parcel_in = randi_range(ads.parcel_every_min, ads.parcel_every_max)
	timer.timeout.connect(_drop_parcel)


func _drop_parcel() -> void:
	if _over or parcel.is_out() or not is_inside_tree():
		return
	parcel.drop(_parcel_spot())


func _drop_gift() -> void:
	if _over or gift.is_out() or not is_inside_tree():
		return
	gift.drop(_parcel_spot())


## The free gift: a bonus at once, no pause, no ad.
func _on_gift_picked() -> void:
	var id: StringName = bonuses.free_pick(Game.ADS.gift_bonuses)
	if _over or id == &"":
		return
	Audio.sfx(&"parcel_open")
	_bonus_sound(id)
	bonuses.apply(id, waves.wave)
	hud.show_bonus_banner(tr("BONUS_" + String(id).to_upper()), bonuses.big_icon(id))


## Bonuses with a voice of their own; the rest chime.
func _bonus_sound(id: StringName) -> void:
	match id:
		&"tractor":
			Audio.sfx(&"tractor")
		&"sleepy_rain":
			Audio.sfx(&"snore")
		_:
			Audio.sfx(&"unlock")


## A free spot around the hero (not inside the barn, the bed or a built plot).
func _parcel_spot() -> Vector2:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	# A box-sized circle must be free, not just the point it lands on.
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 70.0
	query.shape = circle
	var b: Rect2 = level.bounds().grow(-120.0)
	var d: float = Game.ADS.parcel_distance
	for attempt: int in 24:
		var a: float = randf() * TAU
		var p: Vector2 = (hero.global_position + Vector2(cos(a), sin(a) * 0.8) * d).clamp(b.position, b.end)
		query.transform = Transform2D(0.0, p + Vector2(0, -30))
		if space.intersect_shape(query, 1).is_empty() and p.distance_to(hero.global_position) > Game.ADS.parcel_pickup * 1.5:
			return p
	return (hero.global_position + Vector2(d, 0)).clamp(b.position, b.end)


## The hero opened the parcel: the fight waits for the pick.
func _on_parcel_picked() -> void:
	if _over:
		return
	var ids: Array[StringName] = bonuses.offer(2)
	var icons: Array[Texture2D] = []
	for id: StringName in ids:
		icons.append(bonuses.big_icon(id))
	Audio.sfx(&"parcel_open")
	_pause_game()
	parcel_window.show_bonuses(ids, icons)


func _on_bonus_picked(id: StringName) -> void:
	_resume()
	_bonus_sound(id)
	bonuses.apply(id, waves.wave)
	hud.show_bonus_banner(tr("BONUS_" + String(id).to_upper()), bonuses.big_icon(id))


func _apply_boosts() -> void:
	if Game.boost_coins:
		state.add_coins(Game.ADS.start_coins)
	if Game.boost_defender and boost_defender != null:
		for plot: BuildPlot in level.plots():
			if not plot.fence_plot and not plot.locked:
				plot.prebuild(boost_defender, Game.ADS.start_defender_level)
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


## Start of the fight (once, Twody): the camera glides from the hero to each
## burrow in turn at the play zoom; at a burrow the arrows start running from
## it to the carrots; from the last one the camera glides back to the hero
## along with its arrows. The first wave countdown waits for the end.
func _show_spawns() -> void:
	if _spawns_shown or _over:
		return
	_spawns_shown = true
	waves.wait = true
	_arrows = Node2D.new()
	_arrows.z_index = 5
	level.add_child(_arrows)
	var z: Vector2 = camera.zoom
	# The camera may not have caught up with the hero yet (the tour can start
	# in _ready), so the tour starts from where it will look.
	var from: Vector2 = _reach_at(hero.global_position + Vector2(0, -40), z)
	var tw: Tween = create_tween()
	# The camera flies by the view centre it can really reach (the level edges
	# stop it), without smoothing, so every move is the eased curve itself.
	tw.tween_callback(func() -> void:
		camera.position_smoothing_enabled = false
		camera.top_level = true
		camera.global_position = from)
	var last_run: float = 0.0
	for road: Path2D in _tour_order(hero.global_position):
		var arrows: Array[AnimatedSprite2D] = _make_arrows(road)
		var view: Vector2 = _reach_at(road.to_global(road.curve.sample_baked(0.0)), z)
		# A burrow already in view (a wide screen shows the whole width): no glide.
		if from.distance_to(view) > 1.0:
			var glide: float = clampf(from.distance_to(view) / tour_speed, tour_glide_min, tour_glide_max)
			tw.tween_method(_glide.bind(from, view), 0.0, 1.0, glide).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_callback(_run_arrows.bind(arrows))
		tw.tween_interval(spawn_hold_time)
		from = view
		last_run = road.curve.get_baked_length() / arrow_run_speed
	var back: float = clampf(last_run - spawn_hold_time, tour_glide_min, tour_return_max)
	var start: Vector2 = from
	tw.tween_method(func(k: float) -> void:
		var hero_view: Vector2 = _reach_at(hero.global_position + Vector2(0, -40), z)
		camera.global_position = start.lerp(hero_view, k),
		0.0, 1.0, back).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func() -> void:
		camera.top_level = false
		camera.position = Vector2(0, -40)
		camera.reset_smoothing()
		camera.position_smoothing_enabled = true
		waves.wait = false
		tutorial.start(level_number))
	tw.tween_interval(arrows_linger)
	tw.tween_property(_arrows, ^"modulate:a", 0.0, 0.5)
	# Made once at the start, so freed once (not a battle-time pool object).
	tw.tween_callback(_arrows.queue_free)


func _glide(k: float, a: Vector2, b: Vector2) -> void:
	camera.global_position = a.lerp(b, k)


## Roads by their burrows: the nearest to `p` first, then the nearest to it…
func _tour_order(p: Vector2) -> Array[Path2D]:
	var left: Array[Path2D] = level.roads()
	var out: Array[Path2D] = []
	var at: Vector2 = p
	while not left.is_empty():
		var best: int = 0
		for i: int in left.size():
			if _burrow(left[i]).distance_to(at) < _burrow(left[best]).distance_to(at):
				best = i
		at = _burrow(left[best])
		out.append(left[best])
		left.remove_at(best)
	return out


func _burrow(road: Path2D) -> Vector2:
	return road.to_global(road.curve.sample_baked(0.0))


## Each arrow pops when the run from the burrow reaches it.
func _run_arrows(arrows: Array[AnimatedSprite2D]) -> void:
	for a: AnimatedSprite2D in arrows:
		var at: float = a.get_meta(&"d")
		get_tree().create_timer(maxf(at / arrow_run_speed, 0.01), false).timeout.connect(_pop_arrow.bind(a))


## The view centre nearest to `p` that the camera limits allow at `zoom`.
func _reach_at(p: Vector2, zoom: Vector2) -> Vector2:
	var half: Vector2 = get_viewport_rect().size / zoom * 0.5
	var lo: Vector2 = Vector2(camera.limit_left, camera.limit_top) + half
	var hi: Vector2 = Vector2(camera.limit_right, camera.limit_bottom) - half
	return Vector2(clampf(p.x, lo.x, maxf(lo.x, hi.x)), clampf(p.y, lo.y, maxf(lo.y, hi.y)))


## Arrows along a road from its start to the carrots, hidden until the tour
## reaches them (meta "d": distance along the road).
func _make_arrows(road: Path2D) -> Array[AnimatedSprite2D]:
	var out: Array[AnimatedSprite2D] = []
	var curve: Curve2D = road.curve
	var length: float = curve.get_baked_length()
	for i: int in int(length / arrow_step):
		var d: float = (i + 0.5) * arrow_step
		var p: Vector2 = curve.sample_baked(d)
		var ahead: Vector2 = curve.sample_baked(minf(d + 8.0, length))
		var a: AnimatedSprite2D = AnimatedSprite2D.new()
		a.sprite_frames = arrow_frames
		a.play(&"ui_edge_arrow")
		a.position = road.to_global(p) - level.global_position
		a.rotation = (ahead - p).angle()
		a.scale = Vector2.ZERO
		a.visible = false
		a.set_meta(&"d", d)
		_arrows.add_child(a)
		out.append(a)
	return out


## Pops in, then a soft pulse while the tour lasts.
func _pop_arrow(a: AnimatedSprite2D) -> void:
	a.visible = true
	var tw: Tween = a.create_tween()
	tw.tween_property(a, ^"scale", Vector2.ONE * arrow_size, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		var pulse: Tween = a.create_tween().set_loops()
		pulse.tween_property(a, ^"scale", Vector2.ONE * arrow_size * 0.85, 0.35).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(a, ^"scale", Vector2.ONE * arrow_size, 0.35).set_trans(Tween.TRANS_SINE))


func _process(_delta: float) -> void:
	if _over:
		return
	hud.show_break(waves.break_left if waves.in_break() else 0.0)
	level.set_spawning(not waves.in_break() and not waves.is_done())
	if _debug_shown:
		_debug_left -= _delta
		if _debug_left <= 0.0:
			_debug_left = 0.25
			hud.set_debug("%d fps · %d pests · %d coins" % [Engine.get_frames_per_second(), enemies.count, coins.count])
	_update_boss()
	_edge_left -= _delta
	if _edge_left <= 0.0:
		_edge_left = edge_check_every
		_update_edges()
	if waves.is_done() and enemies.count == 0:
		_on_won()


func _update_boss() -> void:
	if _boss_id == 0:
		return
	var i: int = enemies.index_of(_boss_id)
	if i < 0:
		_boss_id = 0
		hud.hide_boss()
		hud.hide_edge(true)
		return
	hud.set_boss_hp(enemies.hp_at(i) / enemies.max_hp_at(i))


## Pointers at the screen edge: to the boss when it is off screen, and to the
## nearest pest when none is on screen (so the hero knows where to run).
func _update_edges() -> void:
	var to_screen: Transform2D = get_viewport().get_canvas_transform()
	var screen: Rect2 = get_viewport().get_visible_rect()
	var boss: int = enemies.index_of(_boss_id) if _boss_id != 0 else -1
	if boss >= 0 and not screen.has_point(to_screen * enemies.position_at(boss)):
		hud.point_edge(true, to_screen * enemies.position_at(boss), enemies.data_at(boss).portrait)
	else:
		hud.hide_edge(true)
	var world: Rect2 = to_screen.affine_inverse() * screen
	var nearest: int = -1
	if enemies.count > 0 and enemies.find_in_radius(world.get_center(), world.size.length() * 0.5).is_empty():
		nearest = enemies.find_nearest_any(hero.global_position)
	if nearest >= 0 and nearest != boss:
		hud.point_edge(false, to_screen * enemies.position_at(nearest), enemies.data_at(nearest).portrait)
	else:
		hud.hide_edge(false)
	var box: Parcel = parcel if parcel.is_waiting() else gift
	if box.is_waiting() and not screen.has_point(to_screen * box.global_position):
		hud.point_parcel(to_screen * box.global_position, box == gift)
	else:
		hud.hide_parcel_edge()


func _on_coins_collected(n: int) -> void:
	var at: Vector2 = get_viewport().get_canvas_transform() * (hero.global_position + Vector2(0, -110))
	hud.popup(at, "+%d" % n)
	Audio.sfx(&"coin")


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
	if number >= 1:
		hud.show_wave_banner(number)
		Audio.sfx(&"wave", false)
		_count_parcel()


## "Call now": the next wave comes at once, +1 coin per second of the break left.
func _on_call_now() -> void:
	var bonus: int = waves.call_now()
	if bonus > 0:
		state.add_coins(bonus)


func _on_enemy_defeated(pos: Vector2, data: EnemyData) -> void:
	coins.drop(pos, data.coins)
	Audio.sfx(&"pop")


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
	Audio.sfx(&"carrot")
	var before: int = state.carrots
	state.take_carrots(data.carrots)
	carrots_lost += before - state.carrots


## The boss banner, its HP bar and edge pointer (updated in _process).
func _on_boss_spawned(id: int, data: EnemyData) -> void:
	_boss_id = id
	hud.show_boss(data)
	Audio.sfx(&"boss", false)


## Hero stepped on an empty plot: the defender pick, the game goes on.
func _on_menu_requested(plot: BuildPlot) -> void:
	if _over or get_tree().paused:
		return
	hud.radial_menu.open(plot, defender_catalog, plot.options)


## Build flash for a new defender / fence, sparks for an upgrade.
func _on_plot_built(plot: BuildPlot, new_level: int) -> void:
	fx.play(&"build_flash" if new_level == 1 else &"upgrade", plot.global_position + Vector2(0, -48), 1.5)
	Audio.sfx(&"build")


## A coin flies from the hero's paws into the plot.
func _on_coin_paid(plot: BuildPlot) -> void:
	fx.fly(&"coin_trail", hero.global_position + Vector2(0, -60), plot.global_position, 0.2, 1.5)
	Audio.sfx(&"pay")


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
	if _over or defender_intro.visible or enemy_intro.visible or parcel_window.visible:
		return
	if hud.radial_menu.visible:
		hud.radial_menu.close()
		return
	if pause_window.visible:
		pause_window.visible = false
		_resume()
	else:
		_pause_game()
		_open_pause()


## Ad, SDK pause, hidden tab or lost focus in the middle of the fight: the
## pause window waits for the player (nothing resumes by itself).
func _on_sdk_paused() -> void:
	if _over or get_tree().paused:
		return
	_pause_game()
	_open_pause()


## The pause shows the battle under a dim: a tutorial hint would show through
## it, so it hides until the game goes on.
func _open_pause() -> void:
	pause_window.setup(level_number, waves.wave, waves.total(), Game.battle_skin())
	_hint_hidden = tutorial.layer.visible
	tutorial.layer.visible = false
	pause_window.open()


func _pause_game() -> void:
	get_tree().paused = true
	_release_input()
	YandexSdk.gameplay_stop()


func _resume() -> void:
	if _over:
		return
	get_tree().paused = false
	if _hint_hidden:
		_hint_hidden = false
		tutorial.layer.visible = true
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
	state.give_carrots(Game.ADS.second_chance_carrots)
	Audio.fade_music(true)
	_resume()


func _on_won() -> void:
	won = true
	var s: int = stars()
	reward = Game.finish_level(level_number, s)
	Save.save()
	fx.play(&"confetti", hero.global_position + Vector2(0, -120), 2.0, true)
	Audio.sfx(&"win", false)
	if await _finish(s):
		win_window.show_result(s, reward)


func _on_lost() -> void:
	if not _over:
		Audio.sfx(&"lose", false)
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
	Audio.fade_music(false)
	_release_input()
	hud.radial_menu.close()
	tutorial.stop()
	if parcel.is_waiting():
		parcel.hide_now()
	if gift.is_out():
		gift.hide_now()
	hud.hide_parcel_edge()
	hero.finish(won)
	get_tree().paused = true
	finished.emit(won, s)
	await get_tree().create_timer(result_delay, true).timeout
	return is_inside_tree()
