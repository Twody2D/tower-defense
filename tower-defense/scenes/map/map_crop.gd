class_name MapCrop
extends TextureButton
## A farm crop on the map and in the main menu (design K/L, 192 px): closed
## (a sign with the level that opens it), growing (3 stages by progress),
## ripe (level 1 sways, levels 2–3 are their own pictures) with a "ripe"
## bubble over it. A tap is handled by the screen: collect when ripe,
## otherwise the harvest window.

const GRAIN: Texture2D = preload("res://art/ui/ui_icon_grain.png")

@export var crop_id: StringName = &"wheat"
## The bubble bobs this much, px, and this fast, rad/s.
@export var bob_height: float = 5.0
@export var bob_speed: float = 3.3

var crop: CropData

var _time: float = 0.0
var _collecting: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _level_pic: TextureRect = $LevelPic
@onready var _locked: Control = $Locked
@onready var _lock_level: Label = $Locked/Level
@onready var _bubble: Control = $Bubble
@onready var _product: TextureRect = $Bubble/Product


func _ready() -> void:
	crop = Game.META.crop(crop_id)
	_product.texture = crop.icon_big
	_sprite.animation_finished.connect(_on_collect_finished)
	UiFx.press_spring(self)
	refresh()


func is_ripe() -> bool:
	return Game.crop_ready(crop, Game.now())


## Collects a ripe crop: the collect animation, the products fly from the
## bubble to `counter` (added to `layer`) and turn into grains. 0 if not ripe.
func collect(layer: Control, counter: Control) -> int:
	var n: int = Game.collect_crop(crop, Game.now())
	if n <= 0:
		return 0
	var from: Vector2 = product_point()
	play_collect()
	Audio.sfx(&"coin", false)
	Save.save()
	UiFx.fly_icons(layer, from, counter.global_position + Vector2(32, 32), crop.icon_big, GRAIN, 5, 72.0,
			func() -> void: UiFx.bump(counter, 1.15, 0.25))
	return n


## Global point the product icons fly from.
func product_point() -> Vector2:
	return _bubble.global_position + _bubble.size * 0.5


func refresh() -> void:
	if crop == null or _collecting:
		return
	var now: int = Game.now()
	var open: bool = Game.crop_open(crop)
	_locked.visible = not open
	_lock_level.text = str(crop.unlock_after)
	var ripe: bool = open and Game.crop_ready(crop, now)
	_bubble.visible = ripe
	var level: int = Game.crop_level(crop)
	_level_pic.visible = ripe and level > 1
	_sprite.visible = open and not _level_pic.visible
	if not open:
		return
	if ripe:
		if level > 1:
			_level_pic.texture = crop.ripe_levels[mini(level - 2, crop.ripe_levels.size() - 1)]
		else:
			_sprite.play(StringName(String(crop_id) + "_ripe"))
	else:
		_sprite.animation = StringName(String(crop_id) + "_grow")
		_sprite.frame = mini(int(Game.crop_progress(crop, now) * 3.0), 2)


## The collect animation, then the new harvest starts growing.
func play_collect() -> void:
	_collecting = true
	_bubble.visible = false
	_level_pic.visible = false
	_sprite.visible = true
	_sprite.play(StringName(String(crop_id) + "_collect"))


func _on_collect_finished() -> void:
	if _collecting:
		_collecting = false
		refresh()


func _process(delta: float) -> void:
	if _bubble.visible:
		_time += delta
		_bubble.position.y = -58.0 + sin(_time * bob_speed) * bob_height
	# Growth stages move on while the screen is open.
	if Engine.get_process_frames() % 60 == 0:
		refresh()
