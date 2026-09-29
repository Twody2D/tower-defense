class_name Coins
extends Node2D
## Coins on the ground: a pool of Coin nodes made once at start. A coin pops
## out of a defeated pest, lies `lifetime` seconds (blinks at the end) and
## flies to the hero inside the magnet radius. Over `capacity` new coins
## merge into existing ones (the big ×5 coin).

signal collected(value: int)

@export var coin_scene: PackedScene
@export var lifetime: float = 15.0
## Blinking before a coin disappears, s.
@export var blink_time: float = 3.0
@export var capacity: int = 150
## A coin worth this much or more looks like the big ×5 coin.
@export var merged_value: int = 5
## Pop scatter around the drop point, px.
@export var scatter: float = 26.0
## Flight to the hero: start speed and acceleration, px/s and px/s².
@export var fly_speed: float = 260.0
@export var fly_accel: float = 1400.0
## Pick-up distance, px.
@export var pickup_distance: float = 22.0
## A dropped coin lies this long before the magnet takes it (the pop and the
## coin on the ground stay visible even right next to the hero), s.
@export var magnet_delay: float = 0.5
## Coins fly to the hero from the chest height, px.
@export var hero_offset: Vector2 = Vector2(0, -40)

var count: int = 0
## Set by the battle: coins fly to this node inside `magnet_radius`.
var hero: Node2D
var magnet_radius: float = 120.0

var _pool: Array[Coin] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _time: float = 0.0


func _ready() -> void:
	for i: int in capacity:
		var c: Coin = coin_scene.instantiate() as Coin
		c.visible = false
		add_child(c)
		_pool.append(c)


func drop(at: Vector2, amount: int) -> void:
	for n: int in amount:
		var p: Vector2 = at + Vector2(_rng.randf_range(-scatter, scatter), _rng.randf_range(-scatter, scatter) * 0.6)
		if count < capacity:
			_pool[count].drop(p)
			count += 1
		else:
			_merge(p)


func _process(delta: float) -> void:
	if hero != null:
		step(delta, hero.global_position + hero_offset, magnet_radius)


## One frame: age, magnet, pick-up. Separate from _process for tests.
func step(delta: float, hero_pos: Vector2, magnet: float) -> void:
	_time += delta
	var r2: float = magnet * magnet
	var i: int = 0
	while i < count:
		var c: Coin = _pool[i]
		c.age += delta
		if c.fly == 0.0 and c.age >= magnet_delay and c.global_position.distance_squared_to(hero_pos) <= r2:
			c.fly = fly_speed
		if c.fly > 0.0:
			c.fly += fly_accel * delta
			var to: Vector2 = hero_pos - c.global_position
			var travel: float = c.fly * delta
			if to.length() <= maxf(travel, pickup_distance):
				var v: int = c.value
				_release(i)
				collected.emit(v)
				continue
			c.global_position += to.normalized() * travel
		elif c.age >= lifetime:
			_release(i)
			continue
		c.tick_look(_time, c.fly == 0.0 and lifetime - c.age < blink_time)
		i += 1


func clear() -> void:
	for i: int in count:
		_pool[i].visible = false
	count = 0


func total_value() -> int:
	var total: int = 0
	for i: int in count:
		total += _pool[i].value
	return total


## Pool is full: add the coin to the nearest lying small coin (it grows to ×5),
## or to the nearest coin at all.
func _merge(p: Vector2) -> void:
	var best: int = -1
	var best_d2: float = INF
	for i: int in count:
		var c: Coin = _pool[i]
		if c.fly > 0.0 or c.value >= merged_value:
			continue
		var d2: float = p.distance_squared_to(c.global_position)
		if d2 < best_d2:
			best_d2 = d2
			best = i
	if best < 0:
		for i: int in count:
			var d2: float = p.distance_squared_to(_pool[i].global_position)
			if d2 < best_d2:
				best_d2 = d2
				best = i
	if best >= 0:
		var c: Coin = _pool[best]
		c.set_value(c.value + 1, merged_value)
		c.age = 0.0


func _release(i: int) -> void:
	var last: int = count - 1
	var done: Coin = _pool[i]
	done.visible = false
	_pool[i] = _pool[last]
	_pool[last] = done
	count = last
