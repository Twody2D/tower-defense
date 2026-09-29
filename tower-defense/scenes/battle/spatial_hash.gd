class_name SpatialHash
extends RefCounted
## Uniform grid over the level for "who is near this point" queries
## (CODE_PROMPT: cell 128 px). Rebuilt from a position array with a counting
## sort into flat arrays: no per-item allocations, O(items + cells).

var cell: float = 128.0
var origin: Vector2 = Vector2.ZERO
var cols: int = 1
var rows: int = 1

## Items of cell c are _items[_start[c] .. _start[c + 1] - 1].
var _start: PackedInt32Array = PackedInt32Array()
var _items: PackedInt32Array = PackedInt32Array()
var _cell_of: PackedInt32Array = PackedInt32Array()


## Grid covering `bounds` plus one cell of margin on every side.
func setup(bounds: Rect2, cell_size: float = 128.0) -> void:
	cell = cell_size
	origin = bounds.position - Vector2(cell, cell)
	cols = int(ceilf(bounds.size.x / cell)) + 2
	rows = int(ceilf(bounds.size.y / cell)) + 2
	_start.resize(cols * rows + 1)


## Puts items 0..count-1 into cells; items with skip[i] == 1 are left out.
func rebuild(pos: PackedVector2Array, count: int, skip: PackedByteArray) -> void:
	var cells: int = cols * rows
	_start.fill(0)
	if _cell_of.size() < count:
		_cell_of.resize(count)
		_items.resize(count)
	for i: int in count:
		if skip[i] == 1:
			_cell_of[i] = -1
			continue
		var c: int = _cell_index(pos[i])
		_cell_of[i] = c
		_start[c + 1] += 1
	for c: int in cells:
		_start[c + 1] += _start[c]
	# Second pass: fill; _start[c] is used as a write cursor, then restored.
	for i: int in count:
		var c: int = _cell_of[i]
		if c < 0:
			continue
		_items[_start[c]] = i
		_start[c] += 1
	for c: int in range(cells, 0, -1):
		_start[c] = _start[c - 1]
	_start[0] = 0


## Items in the cells touching the circle (callers still check the distance).
func query(center: Vector2, radius: float) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	var x0: int = clampi(int((center.x - radius - origin.x) / cell), 0, cols - 1)
	var x1: int = clampi(int((center.x + radius - origin.x) / cell), 0, cols - 1)
	var y0: int = clampi(int((center.y - radius - origin.y) / cell), 0, rows - 1)
	var y1: int = clampi(int((center.y + radius - origin.y) / cell), 0, rows - 1)
	for y: int in range(y0, y1 + 1):
		for x: int in range(x0, x1 + 1):
			var c: int = y * cols + x
			for k: int in range(_start[c], _start[c + 1]):
				out.append(_items[k])
	return out


func _cell_index(p: Vector2) -> int:
	var x: int = clampi(int((p.x - origin.x) / cell), 0, cols - 1)
	var y: int = clampi(int((p.y - origin.y) / cell), 0, rows - 1)
	return y * cols + x
