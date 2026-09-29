class_name DefenderData
extends Resource
## One defender type (CODE_PROMPT, "Защитники"). Index in the per-level arrays = level - 1.

enum Kind {
	SINGLE, ## one target (goose)
	SLOW_AREA, ## slows everyone in the radius (sprinkler)
	SPLASH, ## shot hurts everyone around the hit point (tomato cannon)
	DOT, ## damage over time (hive)
	FENCE, ## blocks the road, has HP (fence)
}

@export var id: StringName = &"goose"
@export var kind: Kind = Kind.SINGLE
## Name key for tr().
@export var name_key: String = "DEF_GOOSE"
@export var portrait: Texture2D
@export var portrait_locked: Texture2D
## Coin price of levels 1, 2, 3.
@export var prices: Array[int] = [10, 20, 40]
@export var damage: float = 8.0
@export var attacks_per_second: float = 2.0
@export var radius: float = 220.0
## Damage multiplier per level (1, 2, 3): +50% per level (CODE_PROMPT).
@export var level_damage: Array[float] = [1.0, 1.5, 2.0]
## Radius multiplier per level: +10% per level.
@export var level_radius: Array[float] = [1.0, 1.1, 1.2]
@export var projectile_speed: float = 800.0
## Hits flying pests (crows).
@export var hits_flying: bool = false

@export_group("Slow")
## Speed taken away (0.4 = 40% slower).
@export var slow: float = 0.0
## How long a slow lasts after the last splash, s.
@export var slow_time: float = 1.2

@export_group("Splash")
@export var splash_radius: float = 0.0

@export_group("Damage over time")
@export var dot_dps: float = 0.0
@export var dot_time: float = 0.0

@export_group("Fence")
## Fence HP per level.
@export var fence_hp: Array[float] = []
## Full repair costs this share of the current level price.
@export var repair_price_share: float = 0.5

@export_group("Look")
## Animations (art/frames/def_<id>.tres, fence.tres): l<N>_build, l<N>_idle,
## l<N>_attack, upgrade_1to2, upgrade_2to3; the fence has l<N>_damage (3
## states by HP), l<N>_hit, l<N>_destroy, l<N>_repair.
@export var frames: SpriteFrames
## Feet are this far below the frame centre, px.
@export var feet_offset: float = 72.0
@export var projectile_texture: Texture2D
@export var projectile_frames: int = 1
## Effect where the shot lands (fx.tres animation, "" = none); the sprinkler
## splashes (`hit_fx`) on the pests it waters.
@export var hit_fx: StringName = &""
@export var hit_fx_size: float = 1.0
## Where the shot starts, relative to the plot centre.
@export var muzzle: Vector2 = Vector2(0, -90)


func price(level: int) -> int:
	return prices[clampi(level - 1, 0, prices.size() - 1)]


func damage_at(level: int) -> float:
	return damage * level_damage[clampi(level - 1, 0, level_damage.size() - 1)]


func radius_at(level: int) -> float:
	return radius * level_radius[clampi(level - 1, 0, level_radius.size() - 1)]


func dot_dps_at(level: int) -> float:
	return dot_dps * level_damage[clampi(level - 1, 0, level_damage.size() - 1)]


func fence_hp_at(level: int) -> float:
	if fence_hp.is_empty():
		return 0.0
	return fence_hp[clampi(level - 1, 0, fence_hp.size() - 1)]


## Animation name for a level: anim_at(2, "idle") -> "l2_idle".
func anim_at(level: int, anim: String) -> StringName:
	return StringName("l%d_%s" % [clampi(level, 1, max_level()), anim])


func max_level() -> int:
	return prices.size()
