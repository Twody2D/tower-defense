@tool
class_name SheetSprite
extends Sprite2D
## A pest on menus and windows: plays one row of its EnemyAtlas (the horde
## atlas, so no extra sheets). Also plays in the editor.

@export var atlas: EnemyAtlas:
	set(value):
		atlas = value
		_setup()
@export var anim: StringName = &"walk":
	set(value):
		anim = value
		_setup()
## Start offset, s (so a row of pests does not step in sync).
@export var phase: float = 0.0

var _row: int = 0
var _time: float = 0.0


func _ready() -> void:
	_setup()


func _setup() -> void:
	if atlas == null:
		return
	atlas.prepare()
	texture = atlas.texture
	hframes = atlas.columns
	vframes = atlas.rows()
	_row = maxi(atlas.row_of(anim), 0)
	_time = phase
	frame = _row * hframes


func _process(delta: float) -> void:
	if atlas == null:
		return
	_time += delta
	frame = _row * hframes + atlas.frame_at(_row, _time)
