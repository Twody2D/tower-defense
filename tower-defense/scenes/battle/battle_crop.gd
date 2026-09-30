class_name BattleCrop
extends Node2D
## A crop by the road (CODE_PROMPT "Урожай фермы", design K): apple tree on
## the farm, pumpkins in the field, raspberries by the lake. The hero stands
## next to a ripe one for `shake_after` s (a ring fills) → it shakes, the
## fruits fall and turn into `coins_min`..`coins_max` coins → it is empty and
## grows back over `regrow_time` s (empty, then the two regrow frames).
## Fruits are made with the scene (no instantiate() in battle).

signal harvested(crop: BattleCrop, coins: int)
## Where a fruit turned into coins (the battle drops them there).
signal coin_drop(at: Vector2, coins: int)

enum State { RIPE, SHAKING, GROWING }

## Frames in art/frames/crops.tres: "<kind>_ripe/_shake/_regrow/_highlight".
@export var kind: StringName = &"apple_tree"
## Fruit animation "fruit_<fruit>".
@export var fruit: StringName = &"apple"
@export var empty_texture: Texture2D
## The hero this close (to the base point) shakes it, px.
@export var reach: float = 120.0
@export var shake_after: float = 1.0
@export var coins_min: int = 5
@export var coins_max: int = 10
@export var regrow_time: float = 40.0
## Fruits fall from here (above the base point) onto the ground around it.
@export var fruit_from: Vector2 = Vector2(0, -80)
@export var fruit_spread: Vector2 = Vector2(70, 26)
@export var fruit_fall_time: float = 0.35

var hero: Hero
var state: State = State.RIPE

var _stand: float = 0.0
var _grow: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _empty: Sprite2D = $Empty
@onready var _highlight: AnimatedSprite2D = $Highlight
@onready var _ring: TextureProgressBar = $Ring
@onready var _fruits: Node2D = $Fruits


func _ready() -> void:
	_empty.texture = empty_texture
	for f: Node in _fruits.get_children():
		(f as CanvasItem).visible = false
	_sprite.animation_finished.connect(_on_sprite_finished)
	_set_ripe()


## Ready to be shaken (for the tutorial and pointers).
func is_ripe() -> bool:
	return state == State.RIPE


func _process(delta: float) -> void:
	match state:
		State.RIPE:
			var near: bool = hero != null and not hero.is_stunned() \
					and hero.global_position.distance_to(global_position) <= reach
			_highlight.visible = near
			_stand = _stand + delta if near else 0.0
			_ring.visible = near and _stand > 0.05
			_ring.value = _stand / shake_after
			if _stand >= shake_after:
				_shake()
		State.GROWING:
			_grow += delta
			var k: float = _grow / regrow_time
			if k >= 1.0:
				_set_ripe()
			elif k >= 1.0 / 3.0:
				_empty.visible = false
				_sprite.visible = true
				_sprite.animation = StringName(String(kind) + "_regrow")
				_sprite.frame = 0 if k < 2.0 / 3.0 else 1


func _set_ripe() -> void:
	state = State.RIPE
	_stand = 0.0
	_empty.visible = false
	_sprite.visible = true
	_sprite.play(StringName(String(kind) + "_ripe"))
	_highlight.play(StringName(String(kind) + "_highlight"))
	_highlight.visible = false
	_ring.visible = false


func _shake() -> void:
	state = State.SHAKING
	_highlight.visible = false
	_ring.visible = false
	_sprite.play(StringName(String(kind) + "_shake"))
	Audio.sfx(&"fence_hit", false)
	var total: int = _rng.randi_range(coins_min, coins_max)
	var fruits: Array[Node] = _fruits.get_children()
	for i: int in fruits.size():
		# Coins split between the fruits, the first ones get the remainder.
		var share: int = total / fruits.size() + (1 if i < total % fruits.size() else 0)
		_drop_fruit(fruits[i] as AnimatedSprite2D, share, i * 0.06)
	harvested.emit(self, total)


func _drop_fruit(f: AnimatedSprite2D, coins: int, delay: float) -> void:
	var land: Vector2 = Vector2(_rng.randf_range(-fruit_spread.x, fruit_spread.x),
			_rng.randf_range(-fruit_spread.y, fruit_spread.y) + 10.0)
	f.position = fruit_from + Vector2(land.x * 0.5, 0)
	f.animation = StringName("fruit_" + String(fruit))
	f.frame = 0
	f.stop()
	f.visible = true
	var tw: Tween = f.create_tween()
	tw.tween_interval(delay)
	tw.tween_property(f, ^"position", land, fruit_fall_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void:
		f.frame = 1
		f.play())
	tw.tween_interval(0.25)
	tw.tween_callback(func() -> void:
		f.visible = false
		if coins > 0:
			coin_drop.emit(to_global(land), coins))


func _on_sprite_finished() -> void:
	if state == State.SHAKING:
		state = State.GROWING
		_grow = 0.0
		_sprite.visible = false
		_empty.visible = true
