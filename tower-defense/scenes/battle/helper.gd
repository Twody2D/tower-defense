class_name Helper
extends Node2D
## Parcel "Helper": a second hero in another skin runs next to the hero and
## throws at the nearest pest with the hero's stats. Made with the battle
## scene and only shown for the bonus time (no instantiate() in battle).

## Place next to the hero, behind its back (x is mirrored by the facing), px.
@export var side_offset: Vector2 = Vector2(-90, 16)
## Runs this much faster than the hero, so it keeps up.
@export var speed_mult: float = 1.15
## Closer than this to its place it stands still, px.
@export var stand_distance: float = 24.0
@export var throw_offset: Vector2 = Vector2(0, -60)
@export var projectile_frames: int = 4
@export var hit_fx: StringName = &"proj_splat"

var hero: Hero
var enemies: EnemyManager
var projectiles: Projectiles
var fx: FxPool
var stats: HeroStats

var _cooldown: float = 0.0
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
	global_position = _place()
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
	var facing_left: bool = hero.velocity.x < -1.0
	var o: Vector2 = side_offset
	if facing_left:
		o.x = -o.x
	return hero.global_position + o


func _process(delta: float) -> void:
	var to: Vector2 = _place() - global_position
	var moving: bool = to.length() > stand_distance
	if moving:
		var step: float = stats.speed * speed_mult * delta
		global_position += to.limit_length(step)
		if absf(to.x) > 2.0:
			_sprite.flip_h = to.x < 0.0
	_cooldown -= delta
	if _cooldown <= 0.0:
		var target: int = enemies.find_nearest(global_position, stats.attack_radius)
		if target >= 0:
			_cooldown = 1.0 / stats.attacks_per_second
			_shot.damage = stats.damage
			_shot.speed = stats.projectile_speed
			projectiles.fire(global_position + throw_offset, target, _shot)
			if not moving:
				_sprite.play(&"throw")
				_sprite.flip_h = enemies.position_at(target).x < global_position.x
	var throwing: bool = _sprite.animation == &"throw" and _sprite.is_playing()
	if moving:
		_sprite.play(&"run")
	elif not throwing:
		_sprite.play(&"idle")
