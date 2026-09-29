class_name LevelData
extends Resource
## Level rules. Geometry (roads, plots, base) lives in the level scene;
## waves and economy live here.

@export var number: int = 1
## Level coins at the start of the battle (CODE_PROMPT: 10).
@export var start_coins: int = 10
## Carrots in the base.
@export var carrots: int = 20
## Defenders the player may build on this level (the rest show a lock).
@export var defenders: Array[DefenderData] = []
## Pest HP grows by this share per campaign level (0.08 = +8%).
@export var hp_growth_per_level: float = 0.08
@export var waves: Array[WaveData] = []
## Break before each wave, s (CODE_PROMPT: 20). "Call now" skips it for +1 coin per second left.
@export var wave_pause: float = 20.0
## Break before the first wave, s.
@export var first_pause: float = 10.0
## Stars: 3 if no carrot lost, 2 if at most this many lost, else 1.
@export var two_star_loss: int = 5


func hp_multiplier() -> float:
	return 1.0 + hp_growth_per_level * float(number - 1)


## Every pest type the waves use (the battle makes their MultiMesh views).
func enemy_types() -> Array[EnemyData]:
	var out: Array[EnemyData] = []
	for w: WaveData in waves:
		for g: WaveGroup in w.groups:
			if g.enemy != null and not g.enemy in out:
				out.append(g.enemy)
	return out


func stars_for(carrots_lost: int) -> int:
	if carrots_lost <= 0:
		return 3
	if carrots_lost <= two_star_loss:
		return 2
	return 1
