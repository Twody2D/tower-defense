class_name Defender
extends Node2D
## A defender standing on a build plot. Look: animations of its level
## (DefenderData.frames) and 1–3 stars. Attack by kind (DefenderData.Kind):
## one target, slow area, splash shot, damage-over-time shot. Targets are
## re-picked every `retarget_time`, not every frame.
## Animations: build (new), upgrade 1→2 / 2→3, then idle; attack on every
## shot (the sprinkler loops it while it waters). No attacks while building.

## Target re-pick period, s (CODE_PROMPT: 0.2).
@export var retarget_time: float = 0.2
## A looping attack (sprinkler) goes back to idle this long after the last use, s.
@export var attack_linger: float = 0.4
## Sprinkler: splash effects on at most this many watered pests per use.
@export var splash_fx_max: int = 3
@export var star_textures: Array[Texture2D] = []

var data: DefenderData
var level: int = 0
var enemies: EnemyManager
var projectiles: Projectiles
var fx: FxPool

var _cooldown: float = 0.0
var _retarget: float = 0.0
var _target_id: int = 0
var _attack_left: float = 0.0
var _shot: Projectiles.Shot = Projectiles.Shot.new()

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _stars: Sprite2D = $Stars


func _ready() -> void:
	set_level(level)


func set_level(new_level: int) -> void:
	var old: int = level
	level = new_level
	visible = level > 0
	if level <= 0 or data == null:
		return
	_sprite.sprite_frames = data.frames
	if old > 0 and level == old + 1:
		_sprite.play(StringName("upgrade_%dto%d" % [old, level]))
	elif old != level:
		_sprite.play(data.anim_at(level, "build"))
	else:
		_sprite.play(data.anim_at(level, "idle"))
	_sprite.offset = Vector2(0, -data.feet_offset)
	_stars.texture = star_textures[clampi(level - 1, 0, star_textures.size() - 1)]
	# Stars sit just above the sprite; scaled ×2 in the scene so they read on a phone.
	_stars.position = Vector2(0, -data.feet_offset * 2.0 - 24.0)
	_shot.texture = data.projectile_texture
	_shot.frames = data.projectile_frames
	_shot.speed = data.projectile_speed
	_shot.include_flying = data.hits_flying
	_shot.damage = data.damage_at(level)
	_shot.splash_radius = data.splash_radius
	_shot.dot_dps = data.dot_dps_at(level)
	_shot.dot_time = data.dot_time
	_shot.hit_fx = data.hit_fx
	_shot.hit_fx_size = data.hit_fx_size
	if data.kind == DefenderData.Kind.DOT:
		_shot.damage = 0.0


func _process(delta: float) -> void:
	if level <= 0 or enemies == null:
		return
	if is_building():
		return
	_animate(delta)
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


## Build or upgrade animation still playing.
func is_building() -> bool:
	var a: String = String(_sprite.animation)
	return _sprite.is_playing() and (a.ends_with("_build") or a.begins_with("upgrade"))


## Skips the build / upgrade animation (tests, stress scene).
func finish_build() -> void:
	if level > 0:
		_sprite.play(data.anim_at(level, "idle"))


## Back to idle after a once attack; a looping attack stops after `attack_linger`.
func _animate(delta: float) -> void:
	_attack_left = maxf(_attack_left - delta, 0.0)
	var attack: StringName = data.anim_at(level, "attack")
	if _sprite.animation == attack and _sprite.is_playing():
		if not data.frames.get_animation_loop(attack) or _attack_left > 0.0:
			return
	var idle: StringName = data.anim_at(level, "idle")
	if _sprite.animation != idle or not _sprite.is_playing():
		_sprite.play(idle)


func _play_attack() -> void:
	var attack: StringName = data.anim_at(level, "attack")
	_attack_left = attack_linger
	if data.frames.get_animation_loop(attack):
		if _sprite.animation != attack:
			_sprite.play(attack)
	else:
		_sprite.stop()
		_sprite.play(attack)


## Twody: the pest closest to the carrots first (re-picked every retarget).
func _pick_target() -> void:
	var first: int = enemies.find_first(global_position, data.radius_at(level), data.hits_flying)
	_target_id = enemies.id_at(first) if first >= 0 else 0


func _shoot() -> void:
	var idx: int = enemies.index_of(_target_id)
	if idx < 0:
		return
	_cooldown = 1.0 / data.attacks_per_second
	# The art faces right: turn to the target, the muzzle turns too.
	_sprite.flip_h = enemies.position_at(idx).x < global_position.x
	var muzzle: Vector2 = data.muzzle
	if _sprite.flip_h:
		muzzle.x = -muzzle.x
	projectiles.fire(global_position + muzzle, idx, _shot)
	_play_attack()


## Sprinkler: every pest in range is slowed and splashed a little.
func _splash_slow() -> void:
	var r: float = data.radius_at(level)
	var hit: PackedInt32Array = enemies.find_in_radius(global_position, r, data.hits_flying)
	if hit.is_empty():
		return
	_cooldown = 1.0 / data.attacks_per_second
	_play_attack()
	if fx != null and data.hit_fx != &"":
		for k: int in mini(hit.size(), splash_fx_max):
			fx.play(data.hit_fx, enemies.position_at(hit[k]) + Vector2(0, -16), data.hit_fx_size)
	for i: int in hit:
		enemies.apply_slow(i, data.slow, data.slow_time)
	enemies.damage_area(global_position, r, data.damage_at(level), data.hits_flying)
