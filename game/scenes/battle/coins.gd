class_name Coins
extends Node2D
## Coins on the ground as arrays. A coin pops out of a defeated pest, lies
## `lifetime` seconds (blinks at the end) and flies to the hero inside the
## magnet radius. Over `capacity` new coins merge into existing ones (×5 coin).

signal collected(value: int)

@export var lifetime: float = 15.0
## Blinking before a coin disappears, s.
@export var blink_time: float = 3.0
@export var capacity: int = 150
## Value of a merged big coin.
@export var merged_value: int = 5
## Pop scatter around the drop point, px.
@export var scatter: float = 26.0
## Flight to the hero: start speed and acceleration, px/s and px/s².
@export var fly_speed: float = 260.0
@export var fly_accel: float = 1400.0
## Pick-up distance, px.
@export var pickup_distance: float = 22.0

var count: int = 0
## Set by the battle: coins fly to this node inside `magnet_radius`.
var hero: Node2D
var magnet_radius: float = 120.0

var _pos: PackedVector2Array = PackedVector2Array()
var _age: PackedFloat32Array = PackedFloat32Array()
var _value: PackedInt32Array = PackedInt32Array()
## 0 = lying, > 0 = flying at this speed.
var _fly: PackedFloat32Array = PackedFloat32Array()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _time: float = 0.0


func _ready() -> void:
	_pos.resize(capacity)
	_age.resize(capacity)
	_value.resize(capacity)
	_fly.resize(capacity)


func drop(at: Vector2, amount: int) -> void:
	for n: int in amount:
		var p: Vector2 = at + Vector2(_rng.randf_range(-scatter, scatter), _rng.randf_range(-scatter, scatter) * 0.6)
		if count < capacity:
			var i: int = count
			count += 1
			_pos[i] = p
			_age[i] = 0.0
			_value[i] = 1
			_fly[i] = 0.0
		else:
			_merge(p)


func _process(delta: float) -> void:
	if hero != null:
		step(delta, hero.global_position, magnet_radius)
	queue_redraw()


## One frame: age, magnet, pick-up. Separate from _process for tests.
func step(delta: float, hero_pos: Vector2, magnet_radius: float) -> void:
	_time += delta
	var r2: float = magnet_radius * magnet_radius
	var i: int = 0
	while i < count:
		_age[i] += delta
		if _fly[i] == 0.0 and _pos[i].distance_squared_to(hero_pos) <= r2:
			_fly[i] = fly_speed
		if _fly[i] > 0.0:
			_fly[i] += fly_accel * delta
			var to: Vector2 = hero_pos - _pos[i]
			var travel: float = _fly[i] * delta
			if to.length() <= maxf(travel, pickup_distance):
				var v: int = _value[i]
				_remove(i)
				collected.emit(v)
				continue
			_pos[i] += to.normalized() * travel
		elif _age[i] >= lifetime:
			_remove(i)
			continue
		i += 1


func clear() -> void:
	count = 0


func total_value() -> int:
	var total: int = 0
	for i: int in count:
		total += _value[i]
	return total


## Pool is full: add the coin to the nearest lying single coin (it becomes ×5),
## or to the nearest coin at all.
func _merge(p: Vector2) -> void:
	var best: int = -1
	var best_d2: float = INF
	for i: int in count:
		if _fly[i] > 0.0 or _value[i] >= merged_value:
			continue
		var d2: float = p.distance_squared_to(_pos[i])
		if d2 < best_d2:
			best_d2 = d2
			best = i
	if best < 0:
		for i: int in count:
			var d2: float = p.distance_squared_to(_pos[i])
			if d2 < best_d2:
				best_d2 = d2
				best = i
	if best >= 0:
		_value[best] += 1
		_age[best] = 0.0


func _remove(i: int) -> void:
	var last: int = count - 1
	if i != last:
		_pos[i] = _pos[last]
		_age[i] = _age[last]
		_value[i] = _value[last]
		_fly[i] = _fly[last]
	count = last


func _draw() -> void:
	for i: int in count:
		var left: float = lifetime - _age[i]
		if _fly[i] == 0.0 and left < blink_time and fmod(_time, 0.3) < 0.12:
			continue
		var r: float = 11.0 if _value[i] < merged_value else 16.0
		var p: Vector2 = _pos[i]
		if _fly[i] == 0.0:
			draw_circle(p + Vector2(0, r * 0.7), r * 0.8, Color(0, 0, 0, 0.18))
		draw_circle(p, r, Color("ffc933"))
		draw_circle(p, r, Color("2b2b3a"), false, 2.5)
		draw_circle(p + Vector2(-r * 0.3, -r * 0.3), r * 0.25, Color("fff4dc"))
