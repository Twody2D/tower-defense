class_name Hero
extends CharacterBody2D
## Raccoon farmer: runs from WASD/arrows or the joystick, throws apples at the
## nearest pest on its own (also while running). A pest touching the hero
## stuns it for `stun_time`, then it is untouchable for `invulnerable_time`.
## The battle hands in `enemies` and `projectiles`.
## Animations (SpriteFrames of the skin, art/frames/hero_*.tres): idle, run,
## throw (standing), build (paying coins into a plot), hit → stun, joy / sad
## at the end of the battle.

@export var stats: HeroStats
## Level bounds the hero cannot leave (set by the battle from the level).
@export var bounds: Rect2 = Rect2(0, 0, 1920, 1920)
@export_group("Look")
## Skin animations (art/frames/hero_<skin>.tres).
@export var skin: SpriteFrames
@export var projectile_texture: Texture2D
## Effect where an apple lands (fx.tres).
@export var hit_fx: StringName = &"proj_splat"
## Tint of the stun flash.
@export var hit_tint: Color = Color(1.0, 0.45, 0.45)
## Dust puff from the feet while running, every this many seconds.
@export var dust_every: float = 0.3
## The puff appears this far behind the feet, px.
@export var dust_back: float = 18.0
@export var projectile_frames: int = 4
## Where the apple leaves the paw, relative to the feet.
@export var throw_offset: Vector2 = Vector2(0, -60)

## Joystick direction (length 0..1), written by the HUD joystick.
var joystick: Vector2 = Vector2.ZERO
var enemies: EnemyManager
var projectiles: Projectiles
var fx: FxPool
## Damage and attack speed multipliers (meta upgrades, "Rage" bonus).
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0

var _cooldown: float = 0.0
var _stun_left: float = 0.0
var _invulnerable_left: float = 0.0
## Build pose lasts this long after the last coin paid, s.
var _build_left: float = 0.0
var _dust_left: float = 0.0
var _dust_next: int = 0
## Battle over: joy / sad only.
var _finished: bool = false
var _shot: Projectiles.Shot = Projectiles.Shot.new()

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _stars: AnimatedSprite2D = $StunStars
@onready var _dust: Node2D = $Dust


func _ready() -> void:
	_stars.visible = false
	for puff: Node in _dust.get_children():
		var a: AnimatedSprite2D = puff as AnimatedSprite2D
		a.animation_finished.connect(a.hide)
	if skin != null:
		_sprite.sprite_frames = skin
	_sprite.play(&"idle")
	_shot.hit_fx = hit_fx
	_shot.hit_fx_size = 1.5
	_shot.texture = projectile_texture
	_shot.frames = projectile_frames


func _physics_process(delta: float) -> void:
	if _finished:
		return
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
	_stars.play(&"stars_head")
	_sprite.play(&"hit")
	# Red flash that fades (tween, not frames).
	_sprite.self_modulate = hit_tint
	_sprite.create_tween().tween_property(_sprite, ^"self_modulate", Color.WHITE, 0.35)


## Skin look and its projectile (before or after _ready).
func set_skin(frames: SpriteFrames, projectile: Texture2D) -> void:
	skin = frames
	projectile_texture = projectile
	_shot.texture = projectile
	if is_node_ready():
		_sprite.sprite_frames = frames
		_sprite.play(&"idle")


## Second chance: back in the fight after finish(false).
func revive() -> void:
	_finished = false
	_sprite.process_mode = Node.PROCESS_MODE_INHERIT
	_sprite.play(&"idle")


## A coin went from the hero into a plot (the plot calls this).
func mark_building() -> void:
	_build_left = 0.15


## End of the battle: jumps for joy or hangs its ears; nothing else runs.
## The tree is paused then, so the sprite keeps animating on its own.
func finish(won: bool) -> void:
	_finished = true
	_stun_left = 0.0
	_invulnerable_left = 0.0
	_stars.visible = false
	velocity = Vector2.ZERO
	_sprite.modulate.a = 1.0
	_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	_sprite.play(&"joy" if won else &"sad")


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
	if not is_moving() and _build_left <= 0.0:
		_sprite.play(&"throw")
		_sprite.flip_h = enemies.position_at(target).x < global_position.x


## Run dust: a puff behind the feet (against the run), drawn behind the hero
## (Dust is before Sprite; the puffs stay where they appeared: top_level).
func _puff() -> void:
	var puff: AnimatedSprite2D = _dust.get_child(_dust_next) as AnimatedSprite2D
	_dust_next = (_dust_next + 1) % _dust.get_child_count()
	puff.global_position = global_position - velocity.normalized() * dust_back
	puff.visible = true
	puff.play(&"dust")


## Picks the animation for the state; once animations (hit, throw) finish first.
func _animate(delta: float) -> void:
	_build_left = maxf(_build_left - delta, 0.0)
	_dust_left -= delta
	if is_moving() and _dust_left <= 0.0:
		_dust_left = dust_every
		_puff()
	var current: StringName = _sprite.animation
	var want: StringName = &"idle"
	if _stun_left > 0.0:
		want = &"stun"
	elif is_moving():
		want = &"run"
	elif _build_left > 0.0:
		want = &"build"
	var once_playing: bool = (current == &"hit" or current == &"throw") and _sprite.is_playing()
	if once_playing and not (current == &"throw" and want != &"idle"):
		return
	if current != want:
		_sprite.play(want)
