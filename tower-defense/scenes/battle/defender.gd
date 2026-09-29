class_name Defender
extends Node2D
## A defender standing on a build plot. Grey square in the prototype; the
## per-type logic (slow, splash, damage over time) comes in stage 3.

var data: DefenderData
var level: int = 0
var enemies: EnemyManager
var projectiles: Projectiles

var _cooldown: float = 0.0


func _ready() -> void:
	visible = false


func set_level(new_level: int) -> void:
	level = new_level
	visible = level > 0
	queue_redraw()


func _process(delta: float) -> void:
	if level <= 0 or enemies == null:
		return
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target: int = enemies.find_nearest(global_position, data.radius_at(level))
	if target < 0:
		return
	_cooldown = 1.0 / data.attacks_per_second
	projectiles.fire(global_position + Vector2(0, -50), target, data.damage_at(level), data.projectile_speed, Color("7ed957"), 6.0)


func _draw() -> void:
	if level <= 0:
		return
	var size: float = 44.0 + 10.0 * level
	var rect: Rect2 = Rect2(Vector2(-size * 0.5, -size - 6.0), Vector2(size, size))
	draw_rect(Rect2(rect.position + Vector2(4, 6), rect.size), Color(0, 0, 0, 0.2))
	draw_rect(rect, data.color)
	draw_rect(rect, Color("2b2b3a"), false, 3.0)
	for n: int in level:
		draw_circle(Vector2(-12.0 * (level - 1) * 0.5 + 12.0 * n, -size - 18.0), 5.0, Color("ffc933"))
