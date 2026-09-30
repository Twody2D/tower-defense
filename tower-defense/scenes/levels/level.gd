@tool
class_name Level
extends Node2D
## Level scene: ground and road tiles, roads (Path2D), carrot base, spawn,
## build plots, decor, hero start. Rules and waves are in `data`.
##
## Editing in the editor: move the points of the Path2D nodes under Roads
## (keep segments horizontal or vertical), then press "Rebuild ground and
## road" in the inspector: points snap to the 64 px grid, corners get round
## handles, grass and road tiles are laid out from the roads.

const CELL := 64
## Edge bits of a road cell.
const N := 1
const E := 2
const S := 4
const W := 8
## Road tile atlas coords by connected edges (tools/copy_art.py atlas layout).
const ROAD_TILES: Dictionary[int, Vector2i] = {
	E | W: Vector2i(3, 0), N | S: Vector2i(4, 0),
	S | W: Vector2i(5, 0), E | S: Vector2i(6, 0), N | W: Vector2i(7, 0), N | E: Vector2i(0, 1),
	S: Vector2i(1, 1), W: Vector2i(2, 1), E: Vector2i(3, 1), N: Vector2i(4, 1),
	E | S | W: Vector2i(5, 1), N | S | W: Vector2i(6, 1), N | E | S: Vector2i(7, 1), N | E | W: Vector2i(0, 2),
}
const GRASS_TILES: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
## Corner handle length: matches the arc of the corner tiles, px.
const CORNER_HANDLE := 30.0

@export var data: LevelData
## Level size in 64 px cells.
@export var size_cells: Vector2i = Vector2i(30, 30)
## Share of plain grass among grass tiles (the rest: tufts and flowers).
@export_range(0.0, 1.0) var plain_grass: float = 0.8
@export_tool_button("Rebuild ground and road", "TileMapLayer") var rebuild_button: Callable = rebuild


var _road_cells: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var road_tiles: Array[Vector2i] = ROAD_TILES.values()
	var ground: TileMapLayer = $Ground
	for cell: Vector2i in ground.get_used_cells():
		if ground.get_cell_atlas_coords(cell) in road_tiles:
			_road_cells[cell] = true


## A road tile under this world point (the hero runs faster there).
func is_road(world_pos: Vector2) -> bool:
	return _road_cells.has(cell_of(world_pos - global_position))


func bounds() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(size_cells * CELL))


func roads() -> Array[Path2D]:
	var out: Array[Path2D] = []
	for child: Node in $Roads.get_children():
		if child is Path2D:
			out.append(child as Path2D)
	return out


## Road curve in world coordinates (Roads and its paths stay at the origin).
func road_curve(index: int = 0) -> Curve2D:
	return roads()[index].curve


func plots() -> Array[BuildPlot]:
	var out: Array[BuildPlot] = []
	for child: Node in $Plots.get_children():
		if child is BuildPlot:
			out.append(child as BuildPlot)
	return out


func base() -> CarrotBase:
	return $Base as CarrotBase


## Burrows (Spawn, Spawn2, … one per road): pests coming out during a wave,
## still between waves.
func set_spawning(on: bool) -> void:
	var anim: StringName = &"spawn_burrow_exit" if on else &"spawn_burrow_idle"
	for child: Node in get_children():
		var burrow: AnimatedSprite2D = child as AnimatedSprite2D
		if burrow == null or not String(child.name).begins_with("Spawn"):
			continue
		if burrow.animation != anim or not burrow.is_playing():
			burrow.play(anim)


func hero_start() -> Vector2:
	return ($HeroStart as Marker2D).position


func rebuild() -> void:
	var ground: TileMapLayer = $Ground
	ground.clear()
	for y: int in size_cells.y:
		for x: int in size_cells.x:
			ground.set_cell(Vector2i(x, y), 0, _grass_at(x, y))
	var edges: Dictionary[Vector2i, int] = {}
	for road: Path2D in roads():
		_snap_curve(road.curve)
		_collect_edges(road.curve, edges)
	for cell: Vector2i in edges:
		var mask: int = edges[cell]
		var tile: Vector2i = ROAD_TILES.get(mask, ROAD_TILES[E | W] if mask & (E | W) else ROAD_TILES[N | S])
		ground.set_cell(cell, 0, tile)


## Same cell → same grass every rebuild (hash, not random).
func _grass_at(x: int, y: int) -> Vector2i:
	var h: int = absi((x * 73856093) ^ (y * 19349663)) % 1000
	if h < int(plain_grass * 1000.0):
		return GRASS_TILES[0]
	return GRASS_TILES[1] if h % 2 == 0 else GRASS_TILES[2]


static func cell_of(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / CELL), floori(p.y / CELL))


static func cell_center(c: Vector2i) -> Vector2:
	return Vector2(c * CELL) + Vector2(CELL, CELL) * 0.5


## Points to cell centres; corners get handles so pests walk the tile arc.
static func _snap_curve(curve: Curve2D) -> void:
	var n: int = curve.point_count
	for i: int in n:
		curve.set_point_position(i, cell_center(cell_of(curve.get_point_position(i))))
	for i: int in n:
		curve.set_point_in(i, Vector2.ZERO)
		curve.set_point_out(i, Vector2.ZERO)
		if i == 0 or i == n - 1:
			continue
		var p: Vector2 = curve.get_point_position(i)
		var a: Vector2 = (curve.get_point_position(i - 1) - p).normalized()
		var b: Vector2 = (curve.get_point_position(i + 1) - p).normalized()
		if absf(a.dot(b)) < 0.5:
			curve.set_point_in(i, a * CORNER_HANDLE)
			curve.set_point_out(i, b * CORNER_HANDLE)


## Walks each segment cell by cell and marks the edges it crosses.
static func _collect_edges(curve: Curve2D, edges: Dictionary[Vector2i, int]) -> void:
	for i: int in curve.point_count - 1:
		var c: Vector2i = cell_of(curve.get_point_position(i))
		var to: Vector2i = cell_of(curve.get_point_position(i + 1))
		if not edges.has(c):
			edges[c] = 0
		while c != to:
			var step: Vector2i = Vector2i(signi(to.x - c.x), 0) if c.x != to.x else Vector2i(0, signi(to.y - c.y))
			var next: Vector2i = c + step
			edges[c] = edges[c] | _bit(step)
			edges[next] = edges.get(next, 0) | _bit(-step)
			c = next


static func _bit(step: Vector2i) -> int:
	if step == Vector2i.UP:
		return N
	if step == Vector2i.RIGHT:
		return E
	if step == Vector2i.DOWN:
		return S
	return W
