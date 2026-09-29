class_name Hero
extends CharacterBody2D
## Raccoon farmer: runs from WASD/arrows or the joystick, throws apples at the
## nearest pest on its own (also while running). A pest touching the hero
## stuns it for `stun_time`, then it is untouchable for `invulnerable_time`.
## The battle hands in `enemies` and `projectiles`.

@export var stats: HeroStats
## Level bounds the hero cannot leave (set by the battle from the level).
@export var bounds: Rect2 = Rect2(0, 0, 1920, 1920)
@export_group("Look")
@export var idle_sheet: Texture2D
@export var idle_frames: int = 4
@export var idle_fps: float = 6.0
@export var run_sheet: Texture2D
@export var run_frames: int = 6
@export var run_fps: float = 12.0
@export var projectile_texture: Texture2D
@export var projectile_frames: int = 4
## Where the apple leaves the paw, relative to the feet.
@export var throw_offset: Vector2 = Vector2(0, -60)

## Joystick direction (length 0..1), written by the HUD joystick.
var joystick: Vector2 = Vector2.ZERO
var enemies: EnemyManager
var projectiles: Projectiles
## Damage and attack speed multipliers (meta upgrades, "Rage" bonus).
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0

var _cooldown: float = 0.0
var _stun_left: float = 0.0
var _invulnerable_left: float = 0.0
var _anim_time: float = 0.0
var _running: bool = false
var _shot: Projectiles.Shot = Projectiles.Shot.new()

@onready var _sprite: Sprite2D = $Sprite
@onready var _stars: Node2D = $StunStars


func _ready() -> void:
	_stars.visible = false
	_show_anim(false)
	_shot.texture = projectile_texture
	_shot.frames = projectile_frames


func _physics_process(delta: float) -> void:
	_tick_stun(delta)
	var dir: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if joystick != Vector2.ZERO:
		dir = joystick
	if _stun_left > 0.0:
		dir = Vector2.ZERO
	velocity = dir.limit_length(1.0) * stats.speed
	if absf(velocity.x) > 1.0:
		_sprite.flip_h = velocity.x < 0.0
	move_and_slide()
	var r: float = stats.body_radius
	position = position.clamp(bounds.position + Vector2(r, r), bounds.end - Vector2(r, r))
	_check_touch()
	_attack(delta)
	_animate(delta)


func is_moving() -> bool:
	return velocity.length_squared() > 1.0


func is_stunned() -> bool:
	return _stun_left > 0.0


func is_invulnerable() -> bool:
	return _invulnerable_left > 0.0


## Stun from a pest touch or the fox strike; ignored while untouchable.
func stun() -> void:
	if _stun_left > 0.0 or _invulnerable_left > 0.0:
		return
	_stun_left = stats.stun_time
	_stars.visible = true


func _tick_stun(delta: float) -> void:
	if _stun_left > 0.0:
		_stun_left -= delta
		if _stun_left <= 0.0:
			_stun_left = 0.0
			_invulnerable_left = stats.invulnerable_time
			_stars.visible = false
	elif _invulnerable_left > 0.0:
		_invulnerable_left = maxf(_invulnerable_left - delta, 0.0)
	# Blink while untouchable.
	_sprite.modulate.a = 0.5 if _invulnerable_left > 0.0 and fmod(_invulnerable_left, 0.2) < 0.1 else 1.0


func _check_touch() -> void:
	if enemies == null or _stun_left > 0.0 or _invulnerable_left > 0.0:
		return
	if enemies.find_touching(global_position, stats.body_radius) >= 0:
		stun()


func _attack(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0 or enemies == null or _stun_left > 0.0:
		return
	var target: int = enemies.find_nearest(global_position, stats.attack_radius)
	if target < 0:
		return
	_cooldown = 1.0 / (stats.attacks_per_second * attack_speed_mult)
	_shot.damage = stats.damage * damage_mult
	_shot.speed = stats.projectile_speed
	projectiles.fire(global_position + throw_offset, target, _shot)


## Frame stepping over idle/run sheets (stage 5 moves this to SpriteFrames).
func _animate(delta: float) -> void:
	var running: bool = is_moving()
	if running != _running:
		_show_anim(running)
	_anim_time += delta
	var fps: float = run_fps if _running else idle_fps
	_sprite.frame = int(_anim_time * fps) % _sprite.hframes


func _show_anim(running: bool) -> void:
	_running = running
	_anim_time = 0.0
	_sprite.texture = run_sheet if running else idle_sheet
	_sprite.hframes = run_frames if running else idle_frames
	_sprite.frame = 0
