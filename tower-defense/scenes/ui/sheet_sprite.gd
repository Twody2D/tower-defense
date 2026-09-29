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
	# A region clipped to the cell: scaled up, the filter would otherwise
	# pick up the edge of the neighbour frame (a dark stripe).
	region_enabled = true
	region_filter_clip_enabled = true
	_row = maxi(atlas.row_of(anim), 0)
	_time = phase
	_show_frame(0)


func _process(delta: float) -> void:
	if atlas == null:
		return
	_time += delta
	_show_frame(atlas.frame_at(_row, _time))


func _show_frame(f: int) -> void:
	var c: float = float(atlas.cell)
	region_rect = Rect2(f * c, _row * c, c, c)
