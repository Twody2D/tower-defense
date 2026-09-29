class_name EnemyManager
extends Node2D
## All pests of the battle as plain arrays (no nodes per enemy).
## Each pest walks the road curve by `progress` (px along the curve) with a
## sideways offset so the horde looks like a crowd. Removal is swap-with-last,
## so indices change: keep ids, not indices, across frames (index_of).
## Effects: slow (sprinkler), damage over time (hive), fences (RoadBlock).
## Drawing: one MultiMeshInstance2D per pest type (made in setup), frames
## picked in shaders/enemy_frames.gdshader through INSTANCE_CUSTOM.

## One pest type on screen: its MultiMesh and the per-frame instance buffer.
class TypeView:
	extends RefCounted
	var node: MultiMeshInstance2D
	var buffer: PackedFloat32Array = PackedFloat32Array()
	var used: int = 0

signal defeated(pos: Vector2, data: EnemyData)
signal reached_base(data: EnemyData)

## Max sideways offset from the road centre, px.
@export var lateral_spread: float = 30.0
## Hard cap on live pests (stress target is 250).
@export var capacity: int = 400
## Gap between a pest and the fence it chews, px (half the fence depth).
@export var fence_gap: float = 14.0
@export var frames_shader: Shader
## Red flash after a hit, s.
@export var flash_time: float = 0.12

var count: int = 0

var _curve: Curve2D
var _length: float = 0.0
var _blocks: Array[RoadBlock] = []
var _types: Array[EnemyData] = []
var _ids: PackedInt32Array = PackedInt32Array()
var _progress: PackedFloat32Array = PackedFloat32Array()
var _offset: PackedFloat32Array = PackedFloat32Array()
var _hp: PackedFloat32Array = PackedFloat32Array()
var _max_hp: PackedFloat32Array = PackedFloat32Array()
var _pos: PackedVector2Array = PackedVector2Array()
var _facing: PackedFloat32Array = PackedFloat32Array()
var _slow: PackedFloat32Array = PackedFloat32Array()
var _slow_left: PackedFloat32Array = PackedFloat32Array()
var _dot_dps: PackedFloat32Array = PackedFloat32Array()
var _dot_left: PackedFloat32Array = PackedFloat32Array()
var _phase: PackedFloat32Array = PackedFloat32Array()
var _flash: PackedFloat32Array = PackedFloat32Array()
var _views: Dictionary[EnemyData, TypeView] = {}
var _time: float = 0.0
var _index_by_id: Dictionary[int, int] = {}
var _next_id: int = 1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## Road in world coordinates (the curve is baked with the Path2D transform) and
## every pest type the level spawns (their MultiMesh nodes are made here).
func setup(curve: Curve2D, types: Array[EnemyData] = []) -> void:
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
	_slow.resize(capacity)
	_slow_left.resize(capacity)
	_dot_dps.resize(capacity)
	_dot_left.resize(capacity)
	_phase.resize(capacity)
	_flash.resize(capacity)
	for data: EnemyData in types:
		_view_of(data)
	count = 0


func road_length() -> float:
	return _length


## Position of a world point along the road, px (for placing fences).
func progress_of(world_pos: Vector2) -> float:
	return _curve.get_closest_offset(world_pos)


func add_block(block: RoadBlock) -> void:
	_blocks.append(block)


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
	_slow[i] = 0.0
	_slow_left[i] = 0.0
	_dot_dps[i] = 0.0
	_dot_left[i] = 0.0
	_phase[i] = _rng.randf()
	_flash[i] = 0.0
	_index_by_id[id] = i
	_place(i)
	return id


func _process(delta: float) -> void:
	step(delta)
	_update_views(delta)


## Moves everyone, applies effects; pests at the road end take carrots and leave.
func step(delta: float) -> void:
	var i: int = 0
	while i < count:
		var data: EnemyData = _types[i]
		# Damage over time.
		if _dot_left[i] > 0.0:
			var t: float = minf(delta, _dot_left[i])
			_dot_left[i] -= delta
			_hp[i] -= _dot_dps[i] * t
			if _hp[i] <= 0.0:
				_defeat(i)
				continue
		# Slow.
		var speed: float = data.speed
		if _slow_left[i] > 0.0:
			_slow_left[i] -= delta
			speed *= 1.0 - _slow[i]
		var from: float = _progress[i]
		var to: float = from + speed * delta
		if not data.flying:
			to = _stop_at_fence(from, to, data, delta)
		_progress[i] = to
		if to >= _length:
			_remove(i)
			reached_base.emit(data)
			continue
		_place(i)
		i += 1


## A standing fence ahead stops the pest; a stopped pest chews it.
func _stop_at_fence(from: float, to: float, data: EnemyData, delta: float) -> float:
	for block: RoadBlock in _blocks:
		if not block.is_up():
			continue
		var stop: float = block.progress - fence_gap - data.radius
		if from <= stop + 0.5 and to > stop:
			block.hit(data.chew_dps * delta)
			return stop
	return to


## Index of the nearest pest within `radius` of `pos`, -1 if none.
## Linear for now; stage 4 uses a spatial hash.
func find_nearest(pos: Vector2, radius: float, include_flying: bool = true) -> int:
	var best: int = -1
	var best_d2: float = radius * radius
	for i: int in count:
		if not include_flying and _types[i].flying:
			continue
		var d2: float = pos.distance_squared_to(_pos[i])
		if d2 <= best_d2:
			best_d2 = d2
			best = i
	return best


## A walking pest whose body touches a circle at `pos` (hero stun), -1 if none.
func find_touching(pos: Vector2, radius: float) -> int:
	for i: int in count:
		var data: EnemyData = _types[i]
		if data.flying:
			continue
		var r: float = radius + data.radius
		if pos.distance_squared_to(_pos[i]) <= r * r:
			return i
	return -1


## Indices of pests within `radius` (for splash / slow areas).
func find_in_radius(pos: Vector2, radius: float, include_flying: bool = true) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	var r2: float = radius * radius
	for i: int in count:
		if not include_flying and _types[i].flying:
			continue
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


func is_slowed(index: int) -> bool:
	return _slow_left[index] > 0.0


## Deals damage; a pest at 0 HP is defeated (drops coins through the signal).
func damage(index: int, amount: float) -> void:
	if index < 0 or index >= count:
		return
	_hp[index] -= amount
	_flash[index] = flash_time
	if _hp[index] <= 0.0:
		_defeat(index)


## Damage to everyone around `pos`; walks ids so removals do not skip anyone.
func damage_area(pos: Vector2, radius: float, amount: float, include_flying: bool = true) -> void:
	var ids: PackedInt32Array = PackedInt32Array()
	for i: int in find_in_radius(pos, radius, include_flying):
		ids.append(_ids[i])
	for id: int in ids:
		damage(index_of(id), amount)


## Slows by `share` (0.4 = 40%) for `time` s; the stronger slow wins.
func apply_slow(index: int, share: float, time: float) -> void:
	_slow[index] = maxf(_slow[index] if _slow_left[index] > 0.0 else 0.0, share)
	_slow_left[index] = maxf(_slow_left[index], time)


## Damage over time; a new sting refreshes the timer (does not stack).
func apply_dot(index: int, dps: float, time: float) -> void:
	_dot_dps[index] = maxf(_dot_dps[index] if _dot_left[index] > 0.0 else 0.0, dps)
	_dot_left[index] = maxf(_dot_left[index], time)


func clear() -> void:
	count = 0
	_index_by_id.clear()


func _defeat(i: int) -> void:
	var pos: Vector2 = _pos[i]
	var data: EnemyData = _types[i]
	_remove(i)
	defeated.emit(pos, data)


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
		_slow[i] = _slow[last]
		_slow_left[i] = _slow_left[last]
		_dot_dps[i] = _dot_dps[last]
		_dot_left[i] = _dot_left[last]
		_phase[i] = _phase[last]
		_flash[i] = _flash[last]
		_index_by_id[_ids[i]] = i
	_types[last] = null
	count = last


func _view_of(data: EnemyData) -> TypeView:
	if _views.has(data):
		return _views[data]
	var view: TypeView = TypeView.new()
	var size: float = float(data.walk_sheet.get_height())
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_custom_data = true
	mm.mesh = _quad(size)
	mm.instance_count = capacity
	mm.visible_instance_count = 0
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = frames_shader
	mat.set_shader_parameter(&"hframes", data.walk_frames)
	var node: MultiMeshInstance2D = MultiMeshInstance2D.new()
	node.name = String(data.id)
	node.multimesh = mm
	node.texture = data.walk_sheet
	node.material = mat
	add_child(node)
	view.node = node
	view.buffer.resize(capacity * 12)
	_views[data] = view
	return view


## Square 2D mesh, y down, UV (0,0) at the top-left. Built by hand: QuadMesh
## is a 3D class and is cut out of the slim web template (custom.build).
static func _quad(size: float) -> ArrayMesh:
	var h: float = size * 0.5
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


## Writes every pest into its type's instance buffer: transform (facing by the
## sign of x scale), then custom data.
## The buffer is taken out of the view while filled, so writes do not copy it.
func _update_views(delta: float) -> void:
	_time += delta
	for data: EnemyData in _views:
		var view: TypeView = _views[data]
		var b: PackedFloat32Array = view.buffer
		view.buffer = PackedFloat32Array()
		var used: int = 0
		for i: int in count:
			if _types[i] != data:
				continue
			var o: int = used * 12
			var p: Vector2 = _pos[i]
			b[o] = _facing[i]
			b[o + 1] = 0.0
			b[o + 2] = 0.0
			b[o + 3] = p.x
			b[o + 4] = 0.0
			b[o + 5] = 1.0
			b[o + 6] = 0.0
			b[o + 7] = p.y - data.feet_offset
			b[o + 8] = float(int((_time + _phase[i]) * data.walk_fps) % data.walk_frames)
			b[o + 9] = clampf(_flash[i] / flash_time, 0.0, 1.0)
			b[o + 10] = 1.0 if _slow_left[i] > 0.0 else 0.0
			b[o + 11] = 0.0
			used += 1
		var mm: MultiMesh = view.node.multimesh
		mm.buffer = b
		mm.visible_instance_count = used
		view.buffer = b
		view.used = used
	for i: int in count:
		_flash[i] = maxf(_flash[i] - delta, 0.0)
