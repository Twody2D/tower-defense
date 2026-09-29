class_name Hero
extends CharacterBody2D
## Raccoon farmer: runs from WASD/arrows or the joystick, throws apples at the
## nearest pest on its own. The battle hands in `enemies` and `projectiles`.

@export var stats: HeroStats
## Level bounds the hero cannot leave (set by the battle from the level).
@export var bounds: Rect2 = Rect2(0, 0, 2000, 2000)
@export var apple_color: Color = Color("e53935")
@export var apple_size: float = 8.0

## Joystick direction (length 0..1), written by the HUD joystick.
var joystick: Vector2 = Vector2.ZERO
var enemies: EnemyManager
var projectiles: Projectiles
## Damage and attack speed multipliers (meta upgrades, "Rage" bonus).
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0

var _cooldown: float = 0.0
var _stun_left: float = 0.0
var _facing: float = 1.0


func _physics_process(delta: float) -> void:
	_stun_left = maxf(_stun_left - delta, 0.0)
	var dir: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if joystick != Vector2.ZERO:
		dir = joystick
	if _stun_left > 0.0:
		dir = Vector2.ZERO
	velocity = dir.limit_length(1.0) * stats.speed
	if absf(velocity.x) > 1.0:
		_facing = signf(velocity.x)
	move_and_slide()
	var r: float = stats.body_radius
	position = position.clamp(bounds.position + Vector2(r, r), bounds.end - Vector2(r, r))
	_attack(delta)
	queue_redraw()


func is_moving() -> bool:
	return velocity.length_squared() > 1.0


func is_stunned() -> bool:
	return _stun_left > 0.0


func stun() -> void:
	_stun_left = stats.stun_time


func _attack(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0 or enemies == null or _stun_left > 0.0:
		return
	var target: int = enemies.find_nearest(global_position, stats.attack_radius)
	if target < 0:
		return
	_cooldown = 1.0 / (stats.attacks_per_second * attack_speed_mult)
	var from: Vector2 = global_position + Vector2(0, -30)
	projectiles.fire(from, target, stats.damage * damage_mult, stats.projectile_speed, apple_color, apple_size)


## Grey prototype look: body, straw hat, eye on the facing side.
func _draw() -> void:
	var outline: Color = Color("2b2b3a")
	draw_circle(Vector2(0, 26), 24.0, Color(0, 0, 0, 0.2))
	draw_circle(Vector2(0, 0), 26.0, Color("8d8d99"))
	draw_circle(Vector2(0, 0), 26.0, outline, false, 3.0)
	draw_circle(Vector2(12 * _facing, -4), 5.0, Color.WHITE)
	draw_rect(Rect2(-30, -34, 60, 8), Color("e8c56a"))
	draw_rect(Rect2(-16, -48, 32, 16), Color("e8c56a"))
	if _stun_left > 0.0:
		draw_circle(Vector2(0, -60), 8.0, Color("ffc933"))
