class_name Helper
extends Node2D
## Parcel "Helper": a second hero in another skin runs next to the hero and
## throws at the nearest pest with the hero's stats. Made with the battle
## scene and only shown for the bonus time (no instantiate() in battle).

## Place next to the hero: x on the side the helper already is (it never
## runs across the hero), y below it, px.
@export var side_offset: Vector2 = Vector2(90, 16)
## Follows its place softly (Twody: not every move of the hero): speed =
## `hero_share` of the hero's own + distance × `follow_gain`, up to
## `max_speed_mult` × the hero speed (so it lags a little, never overlaps).
@export var hero_share: float = 0.6
@export var follow_gain: float = 3.0
@export var max_speed_mult: float = 1.6
## Speeds up and slows down softly: this much of the way to the wanted
## speed per second (exponential).
@export var accel: float = 8.0
## Changes side only when the hero is this far past it, px.
@export var side_switch: float = 60.0
## Run animation above this speed, idle below `idle_speed` (a gap, so the
## animation does not flicker), px/s.
@export var run_speed: float = 90.0
@export var idle_speed: float = 40.0
@export var throw_offset: Vector2 = Vector2(0, -60)
@export var projectile_frames: int = 4
@export var hit_fx: StringName = &"proj_splat"

var hero: Hero
var enemies: EnemyManager
var projectiles: Projectiles
var fx: FxPool
var stats: HeroStats

var _cooldown: float = 0.0
var _side: float = -1.0
var _velocity: Vector2 = Vector2.ZERO
var _running: bool = false
var _shot: Projectiles.Shot = Projectiles.Shot.new()

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	visible = false
	set_process(false)
	_shot.hit_fx = hit_fx
	_shot.hit_fx_size = 1.5
	_shot.frames = projectile_frames


## Appears next to the hero in a puff, in the given skin.
func appear(skin: SkinData) -> void:
	_sprite.sprite_frames = skin.frames
	_shot.texture = skin.projectile
	# Behind the hero's back.
	_side = 1.0 if hero.velocity.x < -1.0 else -1.0
	_velocity = Vector2.ZERO
	_running = false
	global_position = hero.global_position + Vector2(side_offset.x * _side, side_offset.y)
	visible = true
	set_process(true)
	_sprite.play(&"idle")
	if fx != null:
		fx.play(&"poof", global_position + Vector2(0, -40), 1.6)


func vanish() -> void:
	if not visible:
		return
	if fx != null:
		fx.play(&"poof", global_position + Vector2(0, -40), 1.6)
	visible = false
	set_process(false)


func _place() -> Vector2:
	var dx: float = global_position.x - hero.global_position.x
	if absf(dx) > side_switch and signf(dx) != _side:
		_side = signf(dx)
	return hero.global_position + Vector2(side_offset.x * _side, side_offset.y)


func _process(delta: float) -> void:
	var to: Vector2 = _place() - global_position
	var top: float = maxf(stats.speed, hero.velocity.length()) * max_speed_mult
	var want: Vector2 = (hero.velocity * hero_share + to * follow_gain).limit_length(top)
	_velocity = _velocity.lerp(want, 1.0 - exp(-accel * delta))
	global_position += _velocity * delta
	var speed: float = _velocity.length()
	if _running and speed < idle_speed:
		_running = false
	elif not _running and speed > run_speed:
		_running = true
	if _running and absf(_velocity.x) > idle_speed:
		_sprite.flip_h = _velocity.x < 0.0
	_cooldown -= delta
	if _cooldown <= 0.0:
		var target: int = enemies.find_nearest(global_position, stats.attack_radius)
		if target >= 0:
			_cooldown = 1.0 / stats.attacks_per_second
			_shot.damage = stats.damage
			_shot.speed = stats.projectile_speed
			projectiles.fire(global_position + throw_offset, target, _shot)
			if not _running:
				_sprite.play(&"throw")
				_sprite.flip_h = enemies.position_at(target).x < global_position.x
	var throwing: bool = _sprite.animation == &"throw" and _sprite.is_playing()
	if _running:
		_sprite.play(&"run")
	elif not throwing:
		_sprite.play(&"idle")
