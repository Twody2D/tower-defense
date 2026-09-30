class_name Parcel
extends Node2D
## "Посылка от фермера" on the field (design F): falls on a parachute, lands,
## glows and waits; blinks before it is gone. The hero walks up to it →
## `picked` (the battle opens the bonus pick). One node, reused every time.

signal picked

## Height the parcel falls from and the fall time.
@export var fall_height: float = 520.0
@export var fall_time: float = 1.4
## Animations of the Sprite frames: falling, landing ("" = none), waiting,
## opening ("" = a puff, then gone). The free gift uses its own.
@export var fall_anim: StringName = &"parcel_fall"
@export var land_anim: StringName = &"parcel_land"
@export var idle_anim: StringName = &"parcel_glow"
@export var open_anim: StringName = &"parcel_open"

var hero: Node2D
var fx: FxPool
## Seconds the parcel lies; it blinks during the last `blink`, picked up
## closer than `pickup` px (AdRewards).
var lifetime: float = 12.0
var blink: float = 3.0
var pickup: float = 80.0

var _left: float = 0.0
var _landed: bool = false
var _opening: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _shadow: Sprite2D = $Shadow


func _ready() -> void:
	visible = false
	set_process(false)
	_sprite.animation_finished.connect(_on_animation_finished)


func is_waiting() -> bool:
	return visible and _landed


## Falling or lying on the field (not opened, not gone).
func is_out() -> bool:
	return visible and not _opening


## Falls onto `at` (world).
func drop(at: Vector2) -> void:
	global_position = at
	visible = true
	modulate.a = 1.0
	_landed = false
	_opening = false
	_left = lifetime
	_sprite.process_mode = Node.PROCESS_MODE_INHERIT
	_sprite.position.y = -fall_height
	_sprite.play(fall_anim)
	_shadow.scale = Vector2(0.3, 0.3)
	var tw: Tween = create_tween()
	tw.tween_property(_sprite, ^"position:y", 0.0, fall_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_shadow, ^"scale", Vector2.ONE, fall_time)
	tw.tween_callback(_land)
	set_process(true)


func hide_now() -> void:
	visible = false
	_landed = false
	_opening = false
	set_process(false)


func _land() -> void:
	_landed = true
	_sprite.play(land_anim if land_anim != &"" else idle_anim)
	if fx != null:
		fx.play(&"dust", global_position, 2.0)


func _on_animation_finished() -> void:
	if land_anim != &"" and _sprite.animation == land_anim:
		_sprite.play(idle_anim)
	elif open_anim != &"" and _sprite.animation == open_anim and _opening:
		hide_now()


func _process(delta: float) -> void:
	if not _landed:
		return
	_left -= delta
	if _left <= 0.0:
		if fx != null:
			fx.play(&"poof", global_position + Vector2(0, -40), 1.6)
		hide_now()
		return
	# Blinks faster and faster before it is gone.
	modulate.a = 0.35 if _left < blink and fmod(_left, 0.3) < 0.12 else 1.0
	if hero != null and hero.global_position.distance_to(global_position) <= pickup:
		_open()


## Opens with a puff (plays on while the game is paused for the pick).
func _open() -> void:
	_landed = false
	_opening = true
	modulate.a = 1.0
	set_process(false)
	if open_anim == &"":
		if fx != null:
			fx.play(&"poof", global_position + Vector2(0, -40), 1.6)
		hide_now()
	else:
		_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
		_sprite.play(open_anim)
	picked.emit()
