class_name LevelData
extends Resource
## Level rules. Geometry (road, plots, base) lives in the level scene;
## waves and economy live here.

@export var number: int = 1
## Level coins at the start of the battle.
@export var start_coins: int = 10
## Carrots in the base.
@export var carrots: int = 20
## Defenders the player may build on this level (the rest show a lock).
@export var defenders: Array[DefenderData] = []
## Pest HP grows by this share per campaign level (0.08 = +8%).
@export var hp_growth_per_level: float = 0.08
## Grey prototype: one pest type, endless growing waves (real waves in stage 4).
@export var test_enemy: EnemyData
@export var test_wave_base: int = 12
@export var test_wave_growth: int = 6
@export var test_spawn_interval: float = 0.35
@export var test_wave_pause: float = 12.0


func hp_multiplier() -> float:
	return 1.0 + hp_growth_per_level * float(number - 1)
