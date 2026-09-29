class_name MapNode
extends TextureButton
## One level point on the farm map (design I: 128 px, locked / open /
## current / done with 0–3 stars). The current one carries the hero avatar
## bobbing above it.

@export var level: int = 1
@export var tex_locked: Texture2D
@export var tex_open: Texture2D
@export var tex_current: Texture2D
@export var tex_done: Texture2D
@export var star_full: Texture2D
@export var star_empty: Texture2D

var _time: float = 0.0

@onready var _number: Label = $Number
@onready var _lock: TextureRect = $Lock
@onready var _stars: Array[TextureRect] = [$Stars/Star1, $Stars/Star2, $Stars/Star3]
@onready var _avatar: Control = $Avatar
@onready var _avatar_face: TextureRect = $Avatar/Face


func _ready() -> void:
	_number.text = str(level)
	UiFx.press_spring(self)


## state: "locked", "open", "current", "done"; stars for "done".
func show_state(state: String, stars: int, avatar: Texture2D = null) -> void:
	disabled = state == "locked"
	texture_normal = {"locked": tex_locked, "open": tex_open, "current": tex_current, "done": tex_done}.get(state, tex_open)
	texture_disabled = tex_locked
	_lock.visible = state == "locked"
	_number.visible = not _lock.visible
	($Stars as Control).visible = state == "done"
	for i: int in 3:
		_stars[i].texture = star_full if i < stars else star_empty
	_avatar.visible = state == "current"
	if avatar != null:
		_avatar_face.texture = avatar


func _process(delta: float) -> void:
	if _avatar.visible:
		_time += delta
		_avatar.position.y = -110.0 + roundf(sin(_time * 1000.0 / 220.0) * 6.0)
