class_name Projectiles
extends Node2D
## Pool of homing shots. All Projectile nodes are made once at start (no
## instantiate() in battle); active ones sit at the front of `_pool`.
## A shot follows its target id; if the target is gone it finishes the
## flight to the last known point and vanishes.

## What a shot does on hit. Shooters keep one and reuse it.
class Shot:
	extends RefCounted
	var damage: float = 10.0
	var speed: float = 700.0
	var texture: Texture2D
	var frames: int = 1
	var spin_fps: float = 12.0
	## > 0: hurts everyone around the hit point (tomato).
	var splash_radius: float = 0.0
	## > 0: damage over time on the target (bee).
	var dot_dps: float = 0.0
	var dot_time: float = 0.0
	var include_flying: bool = true
	## Effect at the hit point (fx.tres animation, "" = none) and its scale.
	var hit_fx: StringName = &""
	var hit_fx_size: float = 1.0

@export var projectile_scene: PackedScene
@export var capacity: int = 256
## Distance at which a shot counts as a hit, px.
@export var hit_distance: float = 14.0

var count: int = 0
var enemies: EnemyManager
var fx: FxPool

var _pool: Array[Projectile] = []


func _ready() -> void:
	for i: int in capacity:
		var p: Projectile = projectile_scene.instantiate() as Projectile
		p.visible = false
		add_child(p)
		_pool.append(p)


func fire(from: Vector2, target_index: int, shot: Shot) -> void:
	if count >= capacity or target_index < 0:
		return
	_pool[count].launch(from, enemies.id_at(target_index), enemies.position_at(target_index), shot)
	count += 1


func _process(delta: float) -> void:
	var i: int = 0
	while i < count:
		var p: Projectile = _pool[i]
		var idx: int = enemies.index_of(p.target_id)
		if idx >= 0:
			p.target_pos = enemies.position_at(idx)
		var to: Vector2 = p.target_pos - p.global_position
		var travel: float = p.shot.speed * delta
		if to.length() <= maxf(travel, hit_distance):
			_hit(p, idx)
			_release(i)
			continue
		p.global_position += to.normalized() * travel
		p.tick_look(delta)
		i += 1


func clear() -> void:
	for i: int in count:
		_pool[i].visible = false
	count = 0


func _hit(p: Projectile, idx: int) -> void:
	var shot: Shot = p.shot
	if fx != null and shot.hit_fx != &"":
		fx.play(shot.hit_fx, p.global_position, shot.hit_fx_size)
	if shot.splash_radius > 0.0:
		enemies.damage_area(p.target_pos, shot.splash_radius, shot.damage, shot.include_flying)
		return
	if idx < 0:
		return
	if shot.dot_dps > 0.0:
		enemies.apply_dot(idx, shot.dot_dps, shot.dot_time)
	if shot.damage > 0.0:
		enemies.damage(idx, shot.damage)


## Swap the finished shot with the last active one.
func _release(i: int) -> void:
	var last: int = count - 1
	var done: Projectile = _pool[i]
	done.visible = false
	_pool[i] = _pool[last]
	_pool[last] = done
	count = last
