class_name Bonuses
extends Node2D
## The seven parcel bonuses (CODE_PROMPT "Посылка от фермера", numbers in
## AdRewards): gold rain, hero rage, super magnet, free upgrade, tractor,
## sleepy rain, helper. Timed ones show a ring in the HUD. Tractors and
## clouds are made once in setup(), not during the fight.

const IDS: Array[StringName] = [&"gold_rain", &"rage", &"super_magnet", &"upgrade", &"tractor", &"sleepy_rain", &"helper"]
## Bonuses that last (a ring in the HUD while they do).
const TIMED: Array[StringName] = [&"rage", &"super_magnet", &"sleepy_rain", &"helper"]

## Icon of a bonus: 64 px for the HUD rings, 128 px for the pick window and banner.
@export var icon_pattern: String = "res://art/ui/ui_icon_bonus_%s.png"
@export var big_icon_pattern: String = "res://art/hi/ui_icon_bonus_%s.png"
@export var fx_frames: SpriteFrames
## Gold rain: coins fall in this many drops from this height.
@export var rain_drops: int = 24
@export var rain_height: float = 520.0
@export var rain_fall_time: float = 0.45
## Tractor look: scale and lift so the wheels are on the road.
@export var tractor_scale: float = 1.3
@export var tractor_lift: float = 60.0
## Sleepy rain clouds along the top of the view: x as a share of the view
## width, y in world px below its top edge (under the HUD counters); scale,
## see-through so the pests under them stay visible.
@export var cloud_spots: Array[Vector2] = [Vector2(0.18, 330), Vector2(0.5, 260), Vector2(0.82, 330)]
@export var cloud_scale: float = 1.0
@export var cloud_alpha: float = 0.85

var hero: Hero
var coins: Coins
var enemies: EnemyManager
var fx: FxPool
var helper: Helper
var camera: Camera2D
var hud: Hud
var plots: Array[BuildPlot] = []
var roads: Array[Path2D] = []
var bounds: Rect2 = Rect2()

var _icons: Dictionary[StringName, Texture2D] = {}
var _big_icons: Dictionary[StringName, Texture2D] = {}
var _left: Dictionary[StringName, float] = {}
var _total: Dictionary[StringName, float] = {}
var _tractors: Array[AnimatedSprite2D] = []
## Distance along each road of its tractor (< 0: parked).
var _tractor_d: PackedFloat32Array = PackedFloat32Array()
var _clouds: Array[AnimatedSprite2D] = []
var _time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	for id: StringName in IDS:
		_icons[id] = load(icon_pattern % id) as Texture2D
		_big_icons[id] = load(big_icon_pattern % id) as Texture2D


## Tractors (one per road) and clouds; call once the level is in place.
func setup() -> void:
	for road: Path2D in roads:
		var t: AnimatedSprite2D = _sprite(&"tractor", tractor_scale)
		t.offset = Vector2(0, -tractor_lift / tractor_scale)
		add_child(t)
		_tractors.append(t)
		_tractor_d.append(-1.0)
	for o: Vector2 in cloud_spots:
		var c: AnimatedSprite2D = _sprite(&"sleepy_cloud", cloud_scale)
		c.z_index = 20
		add_child(c)
		_clouds.append(c)


func _sprite(anim: StringName, s: float) -> AnimatedSprite2D:
	var a: AnimatedSprite2D = AnimatedSprite2D.new()
	a.sprite_frames = fx_frames
	a.animation = anim
	a.scale = Vector2(s, s)
	a.visible = false
	return a


func big_icon(id: StringName) -> Texture2D:
	return _big_icons[id]


func is_active(id: StringName) -> bool:
	return _left.get(id, 0.0) > 0.0


## `n` different bonuses that make sense right now (no timed one already
## running, an upgrade only with something to raise, the tractor only with
## pests on the field).
func offer(n: int) -> Array[StringName]:
	var pool: Array[StringName] = []
	for id: StringName in IDS:
		if _can_offer(id):
			pool.append(id)
	pool.shuffle()
	return pool.slice(0, n)


## A free gift bonus: one of `pool` that is not running now (&"" if none).
func free_pick(pool: Array[StringName]) -> StringName:
	var left: Array[StringName] = []
	for id: StringName in pool:
		if _can_offer(id):
			left.append(id)
	return left[_rng.randi() % left.size()] if not left.is_empty() else &""


func _can_offer(id: StringName) -> bool:
	if is_active(id):
		return false
	match id:
		&"upgrade":
			for p: BuildPlot in plots:
				if p.can_free_upgrade():
					return true
			return false
		&"tractor":
			return enemies.count > 0 and not _tractor_running()
	return true


func _tractor_running() -> bool:
	for d: float in _tractor_d:
		if d >= 0.0:
			return true
	return false


## The video was watched: the bonus works now. `wave`: current wave number.
func apply(id: StringName, wave: int) -> void:
	var ads: AdRewards = Game.ADS
	match id:
		&"gold_rain":
			_rain(ads.gold_rain_coins(wave), ads.gold_rain_time, ads.gold_rain_radius)
		&"rage":
			hero.set_rage(ads.rage_mult)
			_start(id, ads.rage_time)
		&"super_magnet":
			coins.magnet_radius = INF
			hero.set_magnet_aura(true)
			_start(id, ads.magnet_time)
		&"upgrade":
			for p: BuildPlot in plots:
				p.free_upgrade()
		&"tractor":
			_start_tractors()
		&"sleepy_rain":
			enemies.global_slow = ads.sleepy_slow
			for c: AnimatedSprite2D in _clouds:
				c.visible = true
				c.play()
				c.modulate.a = 0.0
				c.create_tween().tween_property(c, ^"modulate:a", cloud_alpha, 0.4)
			_start(id, ads.sleepy_time)
		&"helper":
			helper.appear(_helper_skin())
			_start(id, ads.helper_time)


func _start(id: StringName, time: float) -> void:
	_left[id] = time
	_total[id] = time


func _end(id: StringName) -> void:
	_left.erase(id)
	match id:
		&"rage":
			hero.set_rage(1.0)
		&"super_magnet":
			coins.magnet_radius = hero.stats.magnet_radius
			hero.set_magnet_aura(false)
		&"sleepy_rain":
			enemies.global_slow = 0.0
			for c: AnimatedSprite2D in _clouds:
				var tw: Tween = c.create_tween()
				tw.tween_property(c, ^"modulate:a", 0.0, 0.5)
				tw.tween_callback(c.hide)
		&"helper":
			helper.vanish()


## Another skin than the hero's (any, even a locked one: a taste of it).
func _helper_skin() -> SkinData:
	var own: SkinData = Game.battle_skin()
	var others: Array[SkinData] = []
	for s: SkinData in Game.META.skins:
		if s != own:
			others.append(s)
	return others[_rng.randi() % others.size()] if not others.is_empty() else own


## Coins fall from the sky around the hero in drops over `time`.
func _rain(total: int, time: float, radius: float) -> void:
	var drops: int = clampi(total, 1, rain_drops)
	var tw: Tween = create_tween()
	for k: int in drops:
		# Split the coins evenly; the first drops take the remainder.
		var amount: int = total / drops + (1 if k < total % drops else 0)
		tw.tween_callback(_rain_drop.bind(amount, radius))
		tw.tween_interval(time / drops)


func _rain_drop(amount: int, radius: float) -> void:
	var a: float = _rng.randf() * TAU
	var r: float = lerpf(radius * 0.25, radius, sqrt(_rng.randf()))
	var p: Vector2 = hero.global_position + Vector2(cos(a), sin(a) * 0.7) * r
	p = p.clamp(bounds.position + Vector2(40, 40), bounds.end - Vector2(40, 40))
	var tw: Tween = fx.fly(&"gold_rain_coin", p - Vector2(0, rain_height), p, rain_fall_time, 1.8)
	if tw == null:
		coins.drop(p, amount)
	else:
		tw.tween_callback(coins.drop.bind(p, amount))


## Every road gets its tractor, from the carrots back to the burrow.
func _start_tractors() -> void:
	for i: int in _tractors.size():
		_tractor_d[i] = roads[i].curve.get_baked_length()
		var t: AnimatedSprite2D = _tractors[i]
		t.visible = true
		t.modulate.a = 1.0
		t.play()
		_move_tractor(i, 0.0)


func _process(delta: float) -> void:
	_time += delta
	for id: StringName in _left.keys():
		_left[id] -= delta
		if _left[id] <= 0.0:
			_end(id)
	for i: int in _tractors.size():
		if _tractor_d[i] >= 0.0:
			_move_tractor(i, delta)
	if is_active(&"sleepy_rain"):
		var view: Vector2 = get_viewport_rect().size / camera.zoom
		var top_left: Vector2 = camera.get_screen_center_position() - view * 0.5
		for k: int in _clouds.size():
			var spot: Vector2 = cloud_spots[k]
			_clouds[k].global_position = top_left + Vector2(view.x * spot.x + sin(_time * 0.6 + k * 2.0) * 30.0, spot.y)
	_show_rings()


## Drives a tractor back along its road and blows away the pests it meets
## (not the boss; they drop their coins).
func _move_tractor(i: int, delta: float) -> void:
	var ads: AdRewards = Game.ADS
	var road: Path2D = roads[i]
	var t: AnimatedSprite2D = _tractors[i]
	var d: float = _tractor_d[i] - ads.tractor_speed * delta
	var from: Vector2 = t.global_position
	t.global_position = road.to_global(road.curve.sample_baked(maxf(d, 0.0)))
	if absf(t.global_position.x - from.x) > 0.5:
		t.flip_h = t.global_position.x < from.x
	var ids: PackedInt32Array = PackedInt32Array()
	for e: int in enemies.find_in_radius(t.global_position, ads.tractor_radius):
		if not enemies.data_at(e).is_boss:
			ids.append(enemies.id_at(e))
	for id: int in ids:
		enemies.damage(enemies.index_of(id), INF)
	if d <= 0.0:
		_tractor_d[i] = -1.0
		var tw: Tween = t.create_tween()
		tw.tween_property(t, ^"modulate:a", 0.0, 0.4)
		tw.tween_callback(t.hide)
	else:
		_tractor_d[i] = d


func _show_rings() -> void:
	var icons: Array[Texture2D] = []
	var shares: PackedFloat32Array = PackedFloat32Array()
	for id: StringName in TIMED:
		if is_active(id):
			icons.append(_icons[id])
			shares.append(_left[id] / _total[id])
	hud.show_rings(icons, shares)
