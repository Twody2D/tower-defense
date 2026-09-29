class_name Projectiles
extends Node2D
## Pool of homing shots (apples, peas…) as arrays. A shot follows its target id;
## if the target is gone it finishes the flight to the last known point and vanishes.

## Distance at which a shot counts as a hit, px.
@export var hit_distance: float = 14.0
@export var capacity: int = 256

var count: int = 0
var enemies: EnemyManager

var _pos: PackedVector2Array = PackedVector2Array()
var _target_id: PackedInt32Array = PackedInt32Array()
var _target_pos: PackedVector2Array = PackedVector2Array()
var _speed: PackedFloat32Array = PackedFloat32Array()
var _damage: PackedFloat32Array = PackedFloat32Array()
var _color: PackedColorArray = PackedColorArray()
var _size: PackedFloat32Array = PackedFloat32Array()


func _ready() -> void:
	_pos.resize(capacity)
	_target_id.resize(capacity)
	_target_pos.resize(capacity)
	_speed.resize(capacity)
	_damage.resize(capacity)
	_color.resize(capacity)
	_size.resize(capacity)


func fire(from: Vector2, target_index: int, damage: float, speed: float, color: Color, size: float) -> void:
	if count >= capacity or target_index < 0:
		return
	var i: int = count
	count += 1
	_pos[i] = from
	_target_id[i] = enemies.id_at(target_index)
	_target_pos[i] = enemies.position_at(target_index)
	_speed[i] = speed
	_damage[i] = damage
	_color[i] = color
	_size[i] = size


func _process(delta: float) -> void:
	var i: int = 0
	while i < count:
		var idx: int = enemies.index_of(_target_id[i])
		if idx >= 0:
			_target_pos[i] = enemies.position_at(idx)
		var to: Vector2 = _target_pos[i] - _pos[i]
		var travel: float = _speed[i] * delta
		if to.length() <= maxf(travel, hit_distance):
			if idx >= 0:
				enemies.damage(idx, _damage[i])
			_remove(i)
			continue
		_pos[i] += to.normalized() * travel
		i += 1
	queue_redraw()


func clear() -> void:
	count = 0


func _remove(i: int) -> void:
	var last: int = count - 1
	if i != last:
		_pos[i] = _pos[last]
		_target_id[i] = _target_id[last]
		_target_pos[i] = _target_pos[last]
		_speed[i] = _speed[last]
		_damage[i] = _damage[last]
		_color[i] = _color[last]
		_size[i] = _size[last]
	count = last


func _draw() -> void:
	for i: int in count:
		draw_circle(_pos[i], _size[i], _color[i])
		draw_circle(_pos[i], _size[i], Color("2b2b3a"), false, 2.0)
