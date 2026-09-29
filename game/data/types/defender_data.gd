class_name DefenderData
extends Resource
## One defender type (CODE_PROMPT, "Защитники"). Index in the arrays = level - 1.

@export var id: StringName = &"goose"
## Name key for tr().
@export var name_key: String = "DEF_GOOSE"
## Coin price of levels 1, 2, 3.
@export var prices: Array[int] = [10, 20, 40]
@export var damage: float = 8.0
@export var attacks_per_second: float = 2.0
@export var radius: float = 220.0
## Damage multiplier per level (1, 2, 3). The spec gives only level 1 values.
@export var level_damage: Array[float] = [1.0, 1.5, 2.2]
## Radius multiplier per level.
@export var level_radius: Array[float] = [1.0, 1.1, 1.2]
@export var projectile_speed: float = 800.0
## Hits flying pests (crows).
@export var hits_flying: bool = true
## Grey-prototype colour.
@export var color: Color = Color("9e9e9e")


func price(level: int) -> int:
	return prices[clampi(level - 1, 0, prices.size() - 1)]


func damage_at(level: int) -> float:
	return damage * level_damage[clampi(level - 1, 0, level_damage.size() - 1)]


func radius_at(level: int) -> float:
	return radius * level_radius[clampi(level - 1, 0, level_radius.size() - 1)]


func max_level() -> int:
	return prices.size()
