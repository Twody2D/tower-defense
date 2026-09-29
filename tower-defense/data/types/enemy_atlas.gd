class_name EnemyAtlas
extends Resource
## All animations of one pest in one texture: a row per animation, square
## cells (design C frame size). Made by tools/import_animations.gd from
## art/animations.json; the MultiMesh shader picks row and frame.

@export var texture: Texture2D
## Cell size, px.
@export var cell: int = 48
@export var columns: int = 4
## Animation names; the index is the atlas row.
@export var anims: Array[StringName] = []
@export var frames: PackedInt32Array = PackedInt32Array()
@export var fps: PackedFloat32Array = PackedFloat32Array()
@export var loops: PackedByteArray = PackedByteArray()

## Rows of the states the horde uses, -1 = the pest does not have it (filled
## by prepare()). The crow's fly is its walk, its swoop is its grab.
var walk: int = -1
var chew: int = -1
var grab: int = -1
var defeat: int = -1
var dive: int = -1
var underground: int = -1
var emerge: int = -1
var appear: int = -1
var strike: int = -1


func prepare() -> void:
	walk = maxi(row_of(&"walk"), row_of(&"fly"))
	chew = row_of(&"chew")
	grab = maxi(row_of(&"grab"), row_of(&"swoop"))
	defeat = row_of(&"defeat")
	dive = row_of(&"dive")
	underground = row_of(&"underground")
	emerge = row_of(&"emerge")
	appear = row_of(&"appear")
	strike = row_of(&"strike")


func rows() -> int:
	return anims.size()


## Row of an animation, -1 if this pest does not have it.
func row_of(anim: StringName) -> int:
	return anims.find(anim)


## Play time of a once animation, s.
func length(row: int) -> float:
	return float(frames[row]) / fps[row] if fps[row] > 0.0 else 0.0


func is_loop(row: int) -> bool:
	return loops[row] == 1


## Frame at `t` seconds since the animation started (once: holds the last).
func frame_at(row: int, t: float) -> int:
	var n: int = frames[row]
	var f: int = int(t * fps[row])
	return f % n if loops[row] == 1 else mini(f, n - 1)
