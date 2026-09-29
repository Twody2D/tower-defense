class_name EnemyManager
extends Node2D
## All pests of the battle as plain arrays (no nodes per enemy).
## Walking pests follow their road curve by `progress` (px along the curve)
## with a sideways offset so the horde looks like a crowd; flying pests go
## in a straight line from the road start to the base. Removal is
## swap-with-last, so indices change: keep ids across frames (index_of).
## Effects: slow (sprinkler), damage over time (hive), fences (RoadBlock),
## mole dives, boss strikes. Lookups go through a SpatialHash (cell 128).
## Drawing: one MultiMeshInstance2D per pest type (made in setup) over the
## pest's EnemyAtlas; row (animation) and frame go to
## shaders/enemy_frames.gdshader through INSTANCE_CUSTOM.
## Animations: walk (crow: fly), chew at a fence, mole dive → underground →
## emerge, boss appear and strike. A defeated pest (or one that took carrots)
## leaves the arrays at once and plays defeat (grab / swoop) as a "ghost" that
## is only drawn.

signal defeated(pos: Vector2, data: EnemyData)
signal reached_base(data: EnemyData)
## A boss hit the hero (the battle stuns it).
signal hero_struck
signal boss_spawned(id: int, data: EnemyData)

## One pest type on screen: its MultiMesh and the per-frame instance buffer.
class TypeView:
	extends RefCounted
	var node: MultiMeshInstance2D
	var buffer: PackedFloat32Array = PackedFloat32Array()
	var used: int = 0
	## Flying pests: shadows on the ground (transform only).
	var shadow: MultiMeshInstance2D
	var shadow_buffer: PackedFloat32Array = PackedFloat32Array()

## Max sideways offset from the road centre, px.
@export var lateral_spread: float = 30.0
## Hard cap on live pests (stress target is 250).
@export var capacity: int = 400
## Gap between a pest and the fence it chews, px (half the fence depth).
@export var fence_gap: float = 14.0
@export var frames_shader: Shader
## Red flash after a hit, s.
@export var flash_time: float = 0.12
## Spatial hash cell, px (CODE_PROMPT: 128).
@export var hash_cell: float = 128.0
## A ghost keeps the last frame of defeat / grab this long, s.
@export var ghost_hold: float = 0.15
@export_group("HP bar")
## Mini HP bar over a hurt pest (design C: frame 48×6, fill 45×3).
@export var hp_frame: Texture2D
@export var hp_fill: Texture2D
## Bar scale = pest cell / 48 × this, clamped to hp_scale_min..max (readable on a phone).
@export var hp_scale: float = 1.6
@export var hp_scale_min: float = 2.0
@export var hp_scale_max: float = 3.0
## Bar centre above the feet, share of the cell (sprites have air on top).
@export var hp_height: float = 0.85

var count: int = 0
## Time of the last _process (move + effects + drawing buffers), µs — for the stress test.
var last_usec: int = 0
## Set by the battle: bosses stun it when close.
var hero: Node2D

var _roads: Array[Curve2D] = []
var _lengths: PackedFloat32Array = PackedFloat32Array()
var _blocks: Array[RoadBlock] = []
var _hash: SpatialHash = SpatialHash.new()
var _bounds: Rect2 = Rect2()
var _hash_dirty: bool = true
var _types: Array[EnemyData] = []
var _ids: PackedInt32Array = PackedInt32Array()
var _road: PackedInt32Array = PackedInt32Array()
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
## Mole: > 0 = underground for this long; _dive_cd = walking time left.
var _under_left: PackedFloat32Array = PackedFloat32Array()
var _dive_cd: PackedFloat32Array = PackedFloat32Array()
## Boss: time to the next fence strike / hero stun.
var _strike_cd: PackedFloat32Array = PackedFloat32Array()
var _stun_cd: PackedFloat32Array = PackedFloat32Array()
## 1 = not targetable (underground); fed to the spatial hash.
var _hidden: PackedByteArray = PackedByteArray()
var _phase: PackedFloat32Array = PackedFloat32Array()
var _flash: PackedFloat32Array = PackedFloat32Array()
## Atlas row playing and time since it started, s.
var _anim: PackedInt32Array = PackedInt32Array()
var _anim_t: PackedFloat32Array = PackedFloat32Array()
## 1 = stands at a fence this frame.
var _blocked: PackedByteArray = PackedByteArray()
## Ghosts: finished pests playing their last animation.
var _g_count: int = 0
var _g_type: Array[EnemyData] = []
var _g_pos: PackedVector2Array = PackedVector2Array()
var _g_facing: PackedFloat32Array = PackedFloat32Array()
var _g_row: PackedInt32Array = PackedInt32Array()
var _g_t: PackedFloat32Array = PackedFloat32Array()
var _views: Dictionary[EnemyData, TypeView] = {}
var _bar_frames: MultiMeshInstance2D
var _bar_fills: MultiMeshInstance2D
var _bar_buf: PackedFloat32Array = PackedFloat32Array()
var _fill_buf: PackedFloat32Array = PackedFloat32Array()
var _index_by_id: Dictionary[int, int] = {}
var _next_id: int = 1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## Roads in world coordinates, the level bounds (for the hash) and every pest
## type the level spawns (their MultiMesh nodes are made here, not in battle).
func setup(roads: Array[Curve2D], bounds: Rect2, types: Array[EnemyData] = []) -> void:
	_roads = roads
	_lengths.resize(roads.size())
	for r: int in roads.size():
		_lengths[r] = roads[r].get_baked_length()
	_bounds = bounds
	_hash.setup(bounds, hash_cell)
	_types.resize(capacity)
	_ids.resize(capacity)
	_road.resize(capacity)
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
	_under_left.resize(capacity)
	_dive_cd.resize(capacity)
	_strike_cd.resize(capacity)
	_stun_cd.resize(capacity)
	_hidden.resize(capacity)
	_phase.resize(capacity)
	_flash.resize(capacity)
	_anim.resize(capacity)
	_anim_t.resize(capacity)
	_blocked.resize(capacity)
	_g_type.resize(capacity)
	_g_pos.resize(capacity)
	_g_facing.resize(capacity)
	_g_row.resize(capacity)
	_g_t.resize(capacity)
	for data: EnemyData in types:
		_view_of(data)
	if hp_frame != null and hp_fill != null and _bar_frames == null:
		var fw: Vector2 = hp_frame.get_size()
		var lw: Vector2 = hp_fill.get_size()
		_bar_frames = _multimesh_node("HpFrames", _quad_rect(Rect2(-fw * 0.5, fw)), false, capacity, fw.x)
		_bar_frames.texture = hp_frame
		# Fill grows from its left edge: scaling x keeps it inside the frame.
		_bar_fills = _multimesh_node("HpFills", _quad_rect(Rect2(Vector2(0.0, -lw.y * 0.5), lw)), false, capacity, fw.x)
		_bar_fills.texture = hp_fill
		_bar_frames.z_index = 5
		_bar_fills.z_index = 5
		_bar_buf.resize(capacity * 8)
		_fill_buf.resize(capacity * 8)
	count = 0
	_g_count = 0


func road_count() -> int:
	return _roads.size()


func road_length(road: int = 0) -> float:
	return _lengths[road]


## Position of a world point along a road, px (for placing fences).
func progress_of(world_pos: Vector2, road: int = 0) -> float:
	return _roads[road].get_closest_offset(world_pos)


## The road passing closest to a world point.
func nearest_road(world_pos: Vector2) -> int:
	var best: int = 0
	var best_d: float = INF
	for r: int in _roads.size():
		var d: float = _roads[r].get_closest_point(world_pos).distance_to(world_pos)
		if d < best_d:
			best_d = d
			best = r
	return best


func add_block(block: RoadBlock) -> void:
	_blocks.append(block)


## Adds a pest at the start of `road`. Returns its id, or 0 if full.
func spawn(data: EnemyData, hp_multiplier: float = 1.0, road: int = 0) -> int:
	if count >= capacity:
		return 0
	var i: int = count
	count += 1
	var id: int = _next_id
	_next_id += 1
	_types[i] = data
	_ids[i] = id
	_road[i] = clampi(road, 0, _roads.size() - 1)
	_progress[i] = 0.0
	_offset[i] = 0.0 if data.flying or data.is_boss else _rng.randf_range(-lateral_spread, lateral_spread)
	_hp[i] = data.hp * hp_multiplier
	_max_hp[i] = _hp[i]
	_facing[i] = 1.0
	_slow[i] = 0.0
	_slow_left[i] = 0.0
	_dot_dps[i] = 0.0
	_dot_left[i] = 0.0
	_under_left[i] = 0.0
	_dive_cd[i] = data.dive_every
	_strike_cd[i] = 0.0
	_stun_cd[i] = data.stun_every
	_hidden[i] = 0
	_phase[i] = _rng.randf()
	_flash[i] = 0.0
	_blocked[i] = 0
	_anim[i] = 0
	_anim_t[i] = _phase[i] * 4.0
	if data.atlas != null:
		data.atlas.prepare()
		_anim[i] = data.atlas.walk
		if data.is_boss:
			_play(i, data.atlas.appear)
	_index_by_id[id] = i
	_place(i)
	_hash_dirty = true
	if data.is_boss:
		boss_spawned.emit(id, data)
	return id


func _process(delta: float) -> void:
	var t0: int = Time.get_ticks_usec()
	step(delta)
	_update_views(delta)
	last_usec = Time.get_ticks_usec() - t0


## Moves everyone, applies effects; pests at the road end take carrots and leave.
func step(delta: float) -> void:
	var i: int = 0
	while i < count:
		var data: EnemyData = _types[i]
		if _dot_left[i] > 0.0:
			var t: float = minf(delta, _dot_left[i])
			_dot_left[i] -= delta
			_hp[i] -= _dot_dps[i] * t
			if _hp[i] <= 0.0:
				_defeat(i)
				continue
		var speed: float = data.speed
		if _slow_left[i] > 0.0:
			_slow_left[i] -= delta
			speed *= 1.0 - _slow[i]
		if data.can_dive:
			_tick_dive(i, data, delta)
		_anim_t[i] += delta
		if data.is_boss and data.atlas != null and _playing(i, data.atlas.appear):
			speed = 0.0
		var from: float = _progress[i]
		var to: float = from + speed * delta
		_blocked[i] = 0
		if not data.flying and _hidden[i] == 0:
			to = _stop_at_fence(i, from, to, data, delta)
		_progress[i] = to
		if to >= _lengths[_road[i]]:
			_leave(i)
			continue
		if data.is_boss:
			_tick_boss_stun(i, data, delta)
		_place(i)
		_pick_anim(i, data)
		i += 1
	_step_ghosts(delta)
	_hash_dirty = true


## Starts a once animation (row -1 = the pest does not have it).
func _play(i: int, row: int) -> void:
	if row >= 0:
		_anim[i] = row
		_anim_t[i] = 0.0


## True while `row` is a once animation still playing on pest i.
func _playing(i: int, row: int) -> bool:
	if row < 0 or _anim[i] != row:
		return false
	var a: EnemyAtlas = _types[i].atlas
	return not a.is_loop(row) and _anim_t[i] < a.length(row)


## After a once animation ends, or when the state changes: the loop for the
## current state (underground / chewing / walking).
func _pick_anim(i: int, data: EnemyData) -> void:
	var a: EnemyAtlas = data.atlas
	if a == null or _playing(i, _anim[i]):
		return
	var want: int = a.walk
	if _hidden[i] == 1 and a.underground >= 0:
		want = a.underground
	elif _blocked[i] == 1 and not data.is_boss and a.chew >= 0:
		want = a.chew
	if _anim[i] != want:
		_anim[i] = want
		_anim_t[i] = _phase[i] * 4.0


func _tick_dive(i: int, data: EnemyData, delta: float) -> void:
	if _under_left[i] > 0.0:
		_under_left[i] -= delta
		if _under_left[i] <= 0.0:
			_under_left[i] = 0.0
			_hidden[i] = 0
			_dive_cd[i] = data.dive_every
			if data.atlas != null:
				_play(i, data.atlas.emerge)
	else:
		_dive_cd[i] -= delta
		if _dive_cd[i] <= 0.0:
			_dive(i, data)


func _dive(i: int, data: EnemyData) -> void:
	_under_left[i] = data.dive_time
	_hidden[i] = 1
	_dot_left[i] = 0.0
	if data.atlas != null:
		_play(i, data.atlas.dive)


func _tick_boss_stun(i: int, data: EnemyData, delta: float) -> void:
	_stun_cd[i] -= delta
	if _stun_cd[i] > 0.0 or hero == null:
		return
	if hero.global_position.distance_to(_pos[i]) <= data.stun_radius:
		_stun_cd[i] = data.stun_every
		if data.atlas != null:
			_play(i, data.atlas.strike)
		hero_struck.emit()


## A standing fence ahead stops the pest; a stopped pest chews it (the boss
## strikes it instead; a mole dives under it).
func _stop_at_fence(i: int, from: float, to: float, data: EnemyData, delta: float) -> float:
	for block: RoadBlock in _blocks:
		if not block.is_up() or block.road != _road[i]:
			continue
		var stop: float = block.progress - fence_gap - data.radius
		if from <= stop + 0.5 and to > stop:
			if data.can_dive:
				_dive(i, data)
				return to
			if data.is_boss:
				_strike_cd[i] -= delta
				if _strike_cd[i] <= 0.0:
					_strike_cd[i] = data.strike_every
					block.hit(block.max_hp / float(maxi(data.fence_hits, 1)) + 0.01)
					if data.atlas != null:
						_play(i, data.atlas.strike)
			else:
				block.hit(data.chew_dps * delta)
			_blocked[i] = 1
			return stop
	return to


func _rebuild_hash() -> void:
	if _hash_dirty:
		_hash.rebuild(_pos, count, _hidden)
		_hash_dirty = false


## Index of the nearest targetable pest within `radius` of `pos`, -1 if none.
func find_nearest(pos: Vector2, radius: float, include_flying: bool = true) -> int:
	_rebuild_hash()
	var best: int = -1
	var best_d2: float = radius * radius
	for i: int in _hash.query(pos, radius):
		if not include_flying and _types[i].flying:
			continue
		var d2: float = pos.distance_squared_to(_pos[i])
		if d2 <= best_d2:
			best_d2 = d2
			best = i
	return best


## A walking pest whose body touches a circle at `pos` (hero stun), -1 if none.
func find_touching(pos: Vector2, radius: float) -> int:
	_rebuild_hash()
	for i: int in _hash.query(pos, radius + 64.0):
		var data: EnemyData = _types[i]
		if data.flying:
			continue
		var r: float = radius + data.radius
		if pos.distance_squared_to(_pos[i]) <= r * r:
			return i
	return -1


## Indices of targetable pests within `radius` (for splash / slow areas).
func find_in_radius(pos: Vector2, radius: float, include_flying: bool = true) -> PackedInt32Array:
	_rebuild_hash()
	var out: PackedInt32Array = PackedInt32Array()
	var r2: float = radius * radius
	for i: int in _hash.query(pos, radius):
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


func data_at(index: int) -> EnemyData:
	return _types[index]


func position_at(index: int) -> Vector2:
	return _pos[index]


func hp_at(index: int) -> float:
	return _hp[index]


func max_hp_at(index: int) -> float:
	return _max_hp[index]


func is_slowed(index: int) -> bool:
	return _slow_left[index] > 0.0


func is_hidden(index: int) -> bool:
	return _hidden[index] == 1


## Deals damage; a pest at 0 HP is defeated (drops coins through the signal).
## Underground moles take no damage.
func damage(index: int, amount: float) -> void:
	if index < 0 or index >= count or _hidden[index] == 1:
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
	if _hidden[index] == 1:
		return
	_dot_dps[index] = maxf(_dot_dps[index] if _dot_left[index] > 0.0 else 0.0, dps)
	_dot_left[index] = maxf(_dot_left[index], time)


func clear() -> void:
	count = 0
	_g_count = 0
	_index_by_id.clear()
	_hash_dirty = true


## Pests still on screen: live ones and ghosts.
func drawn_count() -> int:
	return count + _g_count


func _defeat(i: int) -> void:
	var pos: Vector2 = _pos[i]
	var data: EnemyData = _types[i]
	if data.atlas != null:
		_add_ghost(i, data.atlas.defeat)
	_remove(i)
	defeated.emit(pos, data)


## Reached the base: grabs carrots (the crow swoops) and is gone.
func _leave(i: int) -> void:
	var data: EnemyData = _types[i]
	if data.atlas != null:
		_add_ghost(i, data.atlas.grab)
	_remove(i)
	reached_base.emit(data)


func _add_ghost(i: int, row: int) -> void:
	if row < 0 or _g_count >= capacity:
		return
	var g: int = _g_count
	_g_count += 1
	_g_type[g] = _types[i]
	_g_pos[g] = _pos[i]
	_g_facing[g] = _facing[i]
	_g_row[g] = row
	_g_t[g] = 0.0


func _step_ghosts(delta: float) -> void:
	var g: int = 0
	while g < _g_count:
		_g_t[g] += delta
		if _g_t[g] < _g_type[g].atlas.length(_g_row[g]) + ghost_hold:
			g += 1
			continue
		var last: int = _g_count - 1
		_g_type[g] = _g_type[last]
		_g_pos[g] = _g_pos[last]
		_g_facing[g] = _g_facing[last]
		_g_row[g] = _g_row[last]
		_g_t[g] = _g_t[last]
		_g_type[last] = null
		_g_count = last


func _place(i: int) -> void:
	var old: Vector2 = _pos[i]
	var curve: Curve2D = _roads[_road[i]]
	if _types[i].flying:
		# Straight from the road start to the base.
		var a: Vector2 = curve.get_point_position(0)
		var b: Vector2 = curve.get_point_position(curve.point_count - 1)
		_pos[i] = a.lerp(b, clampf(_progress[i] / a.distance_to(b), 0.0, 1.0))
	else:
		var t: Transform2D = curve.sample_baked_with_rotation(_progress[i])
		_pos[i] = t.origin + t.y.normalized() * _offset[i]
	if absf(_pos[i].x - old.x) > 0.01:
		_facing[i] = signf(_pos[i].x - old.x)


func _remove(i: int) -> void:
	_index_by_id.erase(_ids[i])
	var last: int = count - 1
	if i != last:
		_types[i] = _types[last]
		_ids[i] = _ids[last]
		_road[i] = _road[last]
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
		_under_left[i] = _under_left[last]
		_dive_cd[i] = _dive_cd[last]
		_strike_cd[i] = _strike_cd[last]
		_stun_cd[i] = _stun_cd[last]
		_hidden[i] = _hidden[last]
		_phase[i] = _phase[last]
		_flash[i] = _flash[last]
		_anim[i] = _anim[last]
		_anim_t[i] = _anim_t[last]
		_blocked[i] = _blocked[last]
		_index_by_id[_ids[i]] = i
	_types[last] = null
	count = last
	_hash_dirty = true


func _view_of(data: EnemyData) -> TypeView:
	if _views.has(data):
		return _views[data]
	var view: TypeView = TypeView.new()
	var a: EnemyAtlas = data.atlas
	a.prepare()
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = frames_shader
	mat.set_shader_parameter(&"columns", a.columns)
	mat.set_shader_parameter(&"rows", a.rows())
	# Live pests and ghosts share the buffer.
	view.node = _multimesh_node(String(data.id), _quad(float(a.cell)), true, capacity * 2, float(a.cell))
	view.node.texture = a.texture
	view.node.material = mat
	# Crows fly above everything on the ground.
	view.node.z_index = 4 if data.flying else 0
	view.buffer.resize(capacity * 2 * 12)
	if data.shadow != null:
		var sw: float = float(data.shadow.get_width())
		view.shadow = _multimesh_node(String(data.id) + "Shadow", _quad(sw), false, capacity, sw)
		view.shadow.texture = data.shadow
		view.shadow.z_index = -1
		view.shadow_buffer.resize(capacity * 8)
	_views[data] = view
	return view


## `size`: the biggest sprite side, px (margin of the culling box).
func _multimesh_node(node_name: String, mesh: ArrayMesh, custom: bool, instances: int, size: float) -> MultiMeshInstance2D:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_custom_data = custom
	mm.mesh = mesh
	mm.instance_count = instances
	mm.visible_instance_count = 0
	# Culling box = the whole level (plus a margin for big sprites). Without it
	# the box is computed once from the first positions and pests that walk out
	# of it are culled: invisible, yet still shot at.
	var area: Rect2 = _bounds.grow(size * 2.0)
	mm.custom_aabb = AABB(Vector3(area.position.x, area.position.y, -1.0), Vector3(area.size.x, area.size.y, 2.0))
	var node: MultiMeshInstance2D = MultiMeshInstance2D.new()
	node.name = node_name
	node.multimesh = mm
	add_child(node)
	return node


## Square 2D mesh, y down, UV (0,0) at the top-left. Built by hand: QuadMesh
## is a 3D class and is cut out of the slim web template (custom.build).
static func _quad(size: float) -> ArrayMesh:
	return _quad_rect(Rect2(-size * 0.5, -size * 0.5, size, size))


static func _quad_rect(r: Rect2) -> ArrayMesh:
	var a: Vector2 = r.position
	var b: Vector2 = r.end
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector2Array([a, Vector2(b.x, a.y), b, Vector2(a.x, b.y)])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


## Writes every pest and ghost into its type's instance buffer: transform
## (facing by the sign of x scale), then custom data = frame, hit flash,
## slowed, atlas row. Flying pests also fill their shadow buffer.
## Buffers are taken out of the view while filled, so writes do not copy them.
func _update_views(delta: float) -> void:
	for data: EnemyData in _views:
		var view: TypeView = _views[data]
		var a: EnemyAtlas = data.atlas
		var lift: float = data.feet_offset + data.fly_height
		var b: PackedFloat32Array = view.buffer
		view.buffer = PackedFloat32Array()
		var sb: PackedFloat32Array = view.shadow_buffer
		view.shadow_buffer = PackedFloat32Array()
		var used: int = 0
		for i: int in count:
			if _types[i] != data:
				continue
			var p: Vector2 = _pos[i]
			var row: int = _anim[i]
			var o: int = used * 12
			b[o] = _facing[i]
			b[o + 1] = 0.0
			b[o + 2] = 0.0
			b[o + 3] = p.x
			b[o + 4] = 0.0
			b[o + 5] = 1.0
			b[o + 6] = 0.0
			b[o + 7] = p.y - lift
			b[o + 8] = float(a.frame_at(row, _anim_t[i]))
			b[o + 9] = clampf(_flash[i] / flash_time, 0.0, 1.0)
			b[o + 10] = 1.0 if _slow_left[i] > 0.0 else 0.0
			b[o + 11] = float(row)
			if view.shadow != null:
				var so: int = used * 8
				sb[so] = 1.0
				sb[so + 1] = 0.0
				sb[so + 2] = 0.0
				sb[so + 3] = p.x
				sb[so + 4] = 0.0
				sb[so + 5] = 1.0
				sb[so + 6] = 0.0
				sb[so + 7] = p.y
			used += 1
		var live: int = used
		for g: int in _g_count:
			if _g_type[g] != data:
				continue
			var p: Vector2 = _g_pos[g]
			var row: int = _g_row[g]
			var o: int = used * 12
			b[o] = _g_facing[g]
			b[o + 1] = 0.0
			b[o + 2] = 0.0
			b[o + 3] = p.x
			b[o + 4] = 0.0
			b[o + 5] = 1.0
			b[o + 6] = 0.0
			b[o + 7] = p.y - lift
			b[o + 8] = float(a.frame_at(row, _g_t[g]))
			b[o + 9] = 0.0
			b[o + 10] = 0.0
			b[o + 11] = float(row)
			used += 1
		var mm: MultiMesh = view.node.multimesh
		mm.buffer = b
		mm.visible_instance_count = used
		view.buffer = b
		view.used = used
		if view.shadow != null:
			var smm: MultiMesh = view.shadow.multimesh
			smm.buffer = sb
			smm.visible_instance_count = live
		view.shadow_buffer = sb
	for i: int in count:
		_flash[i] = maxf(_flash[i] - delta, 0.0)
	_update_bars()


## Frame + fill over every hurt, visible pest.
func _update_bars() -> void:
	if _bar_frames == null:
		return
	var fb: PackedFloat32Array = _bar_buf
	_bar_buf = PackedFloat32Array()
	var lb: PackedFloat32Array = _fill_buf
	_fill_buf = PackedFloat32Array()
	var half: float = hp_frame.get_width() * 0.5
	var inset: float = (hp_frame.get_width() - hp_fill.get_width()) * 0.5
	var used: int = 0
	for i: int in count:
		if _hp[i] >= _max_hp[i] or _hidden[i] == 1:
			continue
		var data: EnemyData = _types[i]
		if data.atlas == null:
			continue
		var cell: float = float(data.atlas.cell)
		var sc: float = clampf(cell / 48.0 * hp_scale, hp_scale_min, hp_scale_max)
		var x: float = _pos[i].x
		var y: float = _pos[i].y - data.feet_offset - data.fly_height - cell * (hp_height - 0.5)
		var o: int = used * 8
		fb[o] = sc
		fb[o + 1] = 0.0
		fb[o + 2] = 0.0
		fb[o + 3] = x
		fb[o + 4] = 0.0
		fb[o + 5] = sc
		fb[o + 6] = 0.0
		fb[o + 7] = y
		lb[o] = sc * clampf(_hp[i] / _max_hp[i], 0.0, 1.0)
		lb[o + 1] = 0.0
		lb[o + 2] = 0.0
		lb[o + 3] = x - (half - inset) * sc
		lb[o + 4] = 0.0
		lb[o + 5] = sc
		lb[o + 6] = 0.0
		lb[o + 7] = y
		used += 1
	var fmm: MultiMesh = _bar_frames.multimesh
	fmm.buffer = fb
	fmm.visible_instance_count = used
	var lmm: MultiMesh = _bar_fills.multimesh
	lmm.buffer = lb
	lmm.visible_instance_count = used
	_bar_buf = fb
	_fill_buf = lb
