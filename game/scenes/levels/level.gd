class_name Level
extends Node2D
## Level geometry: road (Path2D at the origin), carrot base, build plots, hero
## start. Rules and waves are in `data`. The battle instances this scene.

@export var data: LevelData
## Walkable area and camera limits, px.
@export var bounds: Rect2 = Rect2(0, 0, 1800, 1800)
@export var road_width: float = 110.0
@export var road_color: Color = Color("e0b77a")
@export var grass_color: Color = Color("4caf50")
@export var grass_dark: Color = Color("3e8e41")

@onready var road: Path2D = $Road
@onready var base: CarrotBase = $Base
@onready var hero_start: Marker2D = $HeroStart
@onready var plots_root: Node2D = $Plots


func _ready() -> void:
	road.visible = false


func plots() -> Array[BuildPlot]:
	var out: Array[BuildPlot] = []
	for child: Node in plots_root.get_children():
		if child is BuildPlot:
			out.append(child as BuildPlot)
	return out


## Road curve in world coordinates (Road stays at the level origin).
func road_curve() -> Curve2D:
	return road.curve


func _draw() -> void:
	draw_rect(bounds, grass_color)
	# Darker grass tufts on a fixed grid (no randomness: same look every run).
	var step: float = 150.0
	var y: float = bounds.position.y + 40.0
	var row: int = 0
	while y < bounds.end.y:
		var x: float = bounds.position.x + 40.0 + (75.0 if row % 2 == 1 else 0.0)
		while x < bounds.end.x:
			draw_circle(Vector2(x, y), 14.0, grass_dark)
			x += step
		y += step
		row += 1
	var pts: PackedVector2Array = road.curve.get_baked_points()
	draw_polyline(pts, Color("c79a5d"), road_width + 12.0, true)
	draw_polyline(pts, road_color, road_width, true)
	for p: Vector2 in [pts[0], pts[pts.size() - 1]]:
		draw_circle(p, (road_width + 12.0) * 0.5, Color("c79a5d"))
		draw_circle(p, road_width * 0.5, road_color)
