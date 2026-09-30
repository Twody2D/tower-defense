class_name CropData
extends Resource
## A farm crop (CODE_PROMPT "Урожай фермы", design K): grows while the player
## is away, gives golden grains when collected, 3 levels bought for grains.
## The product (apple, pumpkin, honey) is only a picture.

@export var id: StringName
@export var name_key: String
## Opens after this campaign level is passed (0: open from the start).
@export var unlock_after: int = 0
## One harvest grows this long, hours.
@export var grow_hours: float = 1.0
## Grains per harvest at levels 1, 2, 3.
@export var yields: PackedInt32Array = PackedInt32Array([25, 40, 60])
## Grains to go from level 1 to 2 and from 2 to 3.
@export var upgrade_prices: PackedInt32Array = PackedInt32Array([80, 120])
## Product icons: 64 (window rows, flying to the counter) and 128.
@export var icon: Texture2D
@export var icon_big: Texture2D
## Ripe look at levels 2 and 3 (level 1 is the "<id>_ripe" animation).
@export var ripe_levels: Array[Texture2D] = []


func max_level() -> int:
	return yields.size()


func yield_at(level: int) -> int:
	return yields[clampi(level, 1, max_level()) - 1]


## Price of the next level (0 at the top).
func upgrade_price(level: int) -> int:
	return upgrade_prices[level - 1] if level >= 1 and level < max_level() else 0
