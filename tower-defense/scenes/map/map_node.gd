class_name MapNode
extends TextureButton
## One level sign on the farm map (design L, 160 px): locked / open /
## current (glows) / done with 1–3 stars above it; levels with the Fox have
## their own sign. The number sits in the white circle; the current one
## carries the hero avatar bobbing above it.

@export var level: int = 1
@export var fox: bool = false
@export var tex_locked: Texture2D
@export var tex_open: Texture2D
@export var tex_done: Texture2D
@export var fox_locked: Texture2D
@export var fox_open: Texture2D
@export var fox_done: Texture2D
@export var star_full: Texture2D
@export var star_empty: Texture2D

var _time: float = 0.0

@onready var _sign: TextureRect = $Sign
@onready var _current: AnimatedSprite2D = $Current
@onready var _number: Label = $Number
@onready var _stars: Control = $Stars
@onready var _star_list: Array[TextureRect] = [$Stars/Star1, $Stars/Star2, $Stars/Star3]
@onready var _avatar: Control = $Avatar
@onready var _avatar_face: TextureRect = $Avatar/Face


func _ready() -> void:
	_number.text = str(level)
	# The Fox sign is taller: its stars sit higher.
	_stars.position.y = -24.0 if fox else 0.0
	UiFx.press_spring(self)


## state: "locked", "open", "current", "done"; stars for "done".
func show_state(state: String, stars: int, avatar: Texture2D = null) -> void:
	disabled = state == "locked"
	var textures: Dictionary = {
		"locked": fox_locked if fox else tex_locked,
		"open": fox_open if fox else tex_open,
		"done": fox_done if fox else tex_done,
	}
	var pic: Texture2D = textures.get(state, textures["open"])
	_sign.texture = pic
	_sign.visible = state != "current"
	_current.visible = state == "current"
	if _current.visible:
		_current.play(&"level_fox_current" if fox else &"level_current")
	_number.visible = state != "locked"
	_stars.visible = state == "done"
	for i: int in 3:
		_star_list[i].texture = star_full if i < stars else star_empty
	_avatar.visible = state == "current"
	if avatar != null:
		_avatar_face.texture = avatar


func _process(delta: float) -> void:
	if _avatar.visible:
		_time += delta
		_avatar.position.y = -130.0 + roundf(sin(_time * 1000.0 / 220.0) * 6.0)
