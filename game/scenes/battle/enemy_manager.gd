class_name EnemyManager
extends Node2D
## All pests of the battle as plain arrays (no nodes per enemy).
## Each pest walks the road curve by `progress` (px along the curve) with a
## sideways offset so the horde looks like a crowd. Removal is swap-with-last,
## so indices change: keep ids, not indices, across frames (index_of).
## Grey prototype draws circles; stage 4 switches drawing to MultiMesh.

signal defeated(pos: Vector2, data: EnemyData)
signal reached_base(data: EnemyData)

## Max sideways offset from the road centre, px.
@export var lateral_spread: float = 30.0
## Hard cap on live pests (stress target is 250).
@export var capacity: int = 400

var count: int = 0

var _curve: Curve2D
var _length: float = 0.0
var _types: Array[EnemyData] = []
var _ids: PackedInt32Array = PackedInt32Array()
var _progress: PackedFloat32Array = PackedFloat32Array()
var _offset: PackedFloat32Array = PackedFloat32Array()
var _hp: PackedFloat32Array = PackedFloat32Array()
var _max_hp: PackedFloat32Array = PackedFloat32Array()
var _pos: PackedVector2Array = PackedVector2Array()
var _facing: PackedFloat32Array = PackedFloat32Array()
var _index_by_id: Dictionary[int, int] = {}
var _next_id: int = 1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## Road in world coordinates (the curve is baked with the Path2D transform).
func setup(curve: Curve2D) -> void:
	_curve = curve
	_length = curve.get_baked_length()
	_types.resize(capacity)
	_ids.resize(capacity)
	_progress.resize(capacity)
	_offset.resize(capacity)
	_hp.resize(capacity)
	_max_hp.resize(capacity)
	_pos.resize(capacity)
	_facing.resize(capacity)
	count = 0


## Adds a pest at the road start. Returns its id, or 0 if full.
func spawn(data: EnemyData, hp_multiplier: float = 1.0) -> int:
	if count >= capacity:
		return 0
	var i: int = count
	count += 1
	var id: int = _next_id
	_next_id += 1
	_types[i] = data
	_ids[i] = id
	_progress[i] = 0.0
	_offset[i] = _rng.randf_range(-lateral_spread, lateral_spread)
	_hp[i] = data.hp * hp_multiplier
	_max_hp[i] = _hp[i]
	_facing[i] = 1.0
	_index_by_id[id] = i
	_place(i)
	return id


func _process(delta: float) -> void:
	step(delta)
	queue_redraw()


## Moves everyone; pests at the road end take carrots and leave.
func step(delta: float) -> void:
	var i: int = 0
	while i < count:
		_progress[i] += _types[i].speed * delta
		if _progress[i] >= _length:
			var data: EnemyData = _types[i]
			_remove(i)
			reached_base.emit(data)
			continue
		_place(i)
		i += 1


## Index of the nearest pest within `radius` of `pos`, -1 if none.
## Linear for now; stage 4 uses a spatial hash.
func find_nearest(pos: Vector2, radius: float) -> int:
	var best: int = -1
	var best_d2: float = radius * radius
	for i: int in count:
		var d2: float = pos.distance_squared_to(_pos[i])
		if d2 <= best_d2:
			best_d2 = d2
			best = i
	return best


## Indices of pests within `radius` (for splash / slow areas).
func find_in_radius(pos: Vector2, radius: float) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	var r2: float = radius * radius
	for i: int in count:
		if pos.distance_squared_to(_pos[i]) <= r2:
			out.append(i)
	return out


## Current index of a pest id, -1 if it is gone.
func index_of(id: int) -> int:
	return _index_by_id.get(id, -1)


func id_at(index: int) -> int:
	return _ids[index]


func position_at(index: int) -> Vector2:
	return _pos[index]


func hp_at(index: int) -> float:
	return _hp[index]


## Deals damage; a pest at 0 HP is defeated (drops coins through the signal).
func damage(index: int, amount: float) -> void:
	if index < 0 or index >= count:
		return
	_hp[index] -= amount
	if _hp[index] <= 0.0:
		var pos: Vector2 = _pos[index]
		var data: EnemyData = _types[index]
		_remove(index)
		defeated.emit(pos, data)


func clear() -> void:
	count = 0
	_index_by_id.clear()


func _place(i: int) -> void:
	var t: Transform2D = _curve.sample_baked_with_rotation(_progress[i])
	var old: Vector2 = _pos[i]
	_pos[i] = t.origin + t.y.normalized() * _offset[i]
	if absf(_pos[i].x - old.x) > 0.01:
		_facing[i] = signf(_pos[i].x - old.x)


func _remove(i: int) -> void:
	_index_by_id.erase(_ids[i])
	var last: int = count - 1
	if i != last:
		_types[i] = _types[last]
		_ids[i] = _ids[last]
		_progress[i] = _progress[last]
		_offset[i] = _offset[last]
		_hp[i] = _hp[last]
		_max_hp[i] = _max_hp[last]
		_pos[i] = _pos[last]
		_facing[i] = _facing[last]
		_index_by_id[_ids[i]] = i
	_types[last] = null
	count = last


func _draw() -> void:
	for i: int in count:
		var data: EnemyData = _types[i]
		var p: Vector2 = _pos[i]
		draw_circle(p + Vector2(0, data.radius * 0.6), data.radius * 0.9, Color(0, 0, 0, 0.18))
		draw_circle(p, data.radius, data.color)
		draw_circle(p, data.radius, Color("2b2b3a"), false, 3.0)
		# Eye shows the walking direction.
		draw_circle(p + Vector2(data.radius * 0.45 * _facing[i], -data.radius * 0.25), data.radius * 0.22, Color.WHITE)
		if _hp[i] < _max_hp[i]:
			var w: float = data.radius * 2.0
			var top: Vector2 = p + Vector2(-w * 0.5, -data.radius - 10.0)
			draw_rect(Rect2(top, Vector2(w, 5)), Color("2b2b3a"))
			draw_rect(Rect2(top, Vector2(w * _hp[i] / _max_hp[i], 5)), Color("7ed957"))
