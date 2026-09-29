class_name WaveData
extends Resource
## One wave: groups run in parallel, each with its own delay.

@export var groups: Array[WaveGroup] = []


func duration() -> float:
	var d: float = 0.0
	for g: WaveGroup in groups:
		d = maxf(d, g.duration())
	return d


func enemy_count() -> int:
	var n: int = 0
	for g: WaveGroup in groups:
		n += g.count
	return n
