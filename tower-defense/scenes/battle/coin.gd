class_name Coin
extends Sprite2D
## One pooled coin on the ground. Coins keeps the list; this node keeps the
## coin state and spins its sheet (×1 or the big ×5 coin).

@export var small_sheet: Texture2D
@export var big_sheet: Texture2D
@export var spin_fps: float = 10.0
## Pop on drop: a hop this high, this long (design F coin_pop, done in code).
@export var pop_height: float = 36.0
@export var pop_time: float = 0.35

var age: float = 0.0
var value: int = 1
## 0 = lying, > 0 = flying to the hero at this speed.
var fly: float = 0.0


func drop(at: Vector2) -> void:
	global_position = at
	age = 0.0
	value = 1
	fly = 0.0
	texture = small_sheet
	visible = true


func set_value(v: int, big_from: int) -> void:
	value = v
	texture = big_sheet if v >= big_from else small_sheet


func tick_look(time: float, blinking: bool) -> void:
	frame = int(time * spin_fps + position.x * 0.01) % hframes
	if age < pop_time:
		var t: float = age / pop_time
		offset.y = -sin(t * PI) * pop_height * (1.0 - t * 0.5)
	else:
		offset.y = 0.0
	self_modulate.a = 0.25 if blinking and fmod(time, 0.3) < 0.12 else 1.0
