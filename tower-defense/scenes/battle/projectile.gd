class_name Projectile
extends Sprite2D
## One pooled shot (apple, pea, tomato, bee). Projectiles moves and hits;
## this node only keeps the flight state and spins its sheet.

var target_id: int = 0
var target_pos: Vector2 = Vector2.ZERO
var shot: Projectiles.Shot
var age: float = 0.0


func launch(from: Vector2, id: int, at: Vector2, config: Projectiles.Shot) -> void:
	global_position = from
	target_id = id
	target_pos = at
	shot = config
	age = 0.0
	texture = config.texture
	hframes = maxi(config.frames, 1)
	frame = 0
	visible = true


func tick_look(delta: float) -> void:
	age += delta
	if hframes > 1:
		frame = int(age * shot.spin_fps) % hframes
