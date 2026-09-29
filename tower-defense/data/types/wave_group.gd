class_name WaveGroup
extends Resource
## One group of a wave: `count` pests of one type on one road, one every
## `interval` seconds, starting `delay` seconds after the wave starts.

@export var enemy: EnemyData
@export var count: int = 10
@export var interval: float = 0.6
## Road index (Level/Roads children order).
@export var road: int = 0
@export var delay: float = 0.0
## HP share on top of the level growth (the boss of an early level: 0.12 =
## 180 of the fox's 1500).
@export var hp_scale: float = 1.0


func duration() -> float:
	return delay + interval * float(maxi(count - 1, 0))
