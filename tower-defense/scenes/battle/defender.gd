class_name Defender
extends Node2D
## A defender standing on a build plot. Look: the idle sheet of its level
## and 1–3 stars. Attack by kind (DefenderData.Kind): one target, slow area,
## splash shot, damage-over-time shot. Targets are re-picked every
## `retarget_time`, not every frame.

## Target re-pick period, s (CODE_PROMPT: 0.2).
@export var retarget_time: float = 0.2
@export var star_textures: Array[Texture2D] = []

var data: DefenderData
var level: int = 0
var enemies: EnemyManager
var projectiles: Projectiles

var _cooldown: float = 0.0
var _retarget: float = 0.0
var _target_id: int = 0
var _anim_time: float = 0.0
var _shot: Projectiles.Shot = Projectiles.Shot.new()

@onready var _sprite: Sprite2D = $Sprite
@onready var _stars: Sprite2D = $Stars


func _ready() -> void:
	set_level(level)


func set_level(new_level: int) -> void:
	level = new_level
	visible = level > 0
	if level <= 0 or data == null:
		return
	_sprite.texture = data.idle_sheet(level)
	_sprite.hframes = data.idle_frames
	_sprite.offset = Vector2(0, -data.feet_offset)
	_stars.texture = star_textures[clampi(level - 1, 0, star_textures.size() - 1)]
	_stars.position = Vector2(0, -data.feet_offset * 2.0 - 4.0)
	_shot.texture = data.projectile_texture
	_shot.frames = data.projectile_frames
	_shot.speed = data.projectile_speed
	_shot.include_flying = data.hits_flying
	_shot.damage = data.damage_at(level)
	_shot.splash_radius = data.splash_radius
	_shot.dot_dps = data.dot_dps_at(level)
	_shot.dot_time = data.dot_time
	if data.kind == DefenderData.Kind.DOT:
		_shot.damage = 0.0


func _process(delta: float) -> void:
	if level <= 0 or enemies == null:
		return
	_anim_time += delta
	_sprite.frame = int(_anim_time * data.idle_fps) % _sprite.hframes
	_cooldown -= delta
	_retarget -= delta
	if _retarget <= 0.0:
		_retarget = retarget_time
		_pick_target()
	if _cooldown > 0.0:
		return
	match data.kind:
		DefenderData.Kind.SLOW_AREA:
			_splash_slow()
		_:
			_shoot()


func _pick_target() -> void:
	var r: float = data.radius_at(level)
	var idx: int = enemies.index_of(_target_id)
	if idx >= 0 and enemies.position_at(idx).distance_to(global_position) <= r:
		return
	var nearest: int = enemies.find_nearest(global_position, r, data.hits_flying)
	_target_id = enemies.id_at(nearest) if nearest >= 0 else 0


func _shoot() -> void:
	var idx: int = enemies.index_of(_target_id)
	if idx < 0:
		return
	_cooldown = 1.0 / data.attacks_per_second
	projectiles.fire(global_position + data.muzzle, idx, _shot)


## Sprinkler: every pest in range is slowed and splashed a little.
func _splash_slow() -> void:
	var r: float = data.radius_at(level)
	var hit: PackedInt32Array = enemies.find_in_radius(global_position, r, data.hits_flying)
	if hit.is_empty():
		return
	_cooldown = 1.0 / data.attacks_per_second
	for i: int in hit:
		enemies.apply_slow(i, data.slow, data.slow_time)
	enemies.damage_area(global_position, r, data.damage_at(level), data.hits_flying)
