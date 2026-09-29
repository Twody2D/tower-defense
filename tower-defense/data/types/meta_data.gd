class_name MetaData
extends Resource
## Meta balance (CODE_PROMPT "Мета"): grains per level, hero upgrades, skins,
## daily gift, offline harvest. The one copy is data/meta.tres.

@export_group("Grains per level")
@export var grains_base: int = 30
@export var grains_per_star: int = 10

@export_group("Hero upgrades")
## Upgradable stats in shop order: damage, attack_speed, run_speed, magnet.
@export var stats: Array[StringName] = [&"damage", &"attack_speed", &"run_speed", &"magnet"]
@export var stat_max_level: int = 10
## Price of going from level L to L+1: base × growth^(L-1).
@export var stat_price_base: float = 20.0
@export var stat_price_growth: float = 1.35
## Each level above 1 adds this share (+10%).
@export var stat_step: float = 0.1

@export_group("Skins")
## Shop order; the first free one is the default.
@export var skins: Array[SkinData] = []

@export_group("Daily gift")
## Grains for days 1..7; a missed day starts over from day 1.
@export var daily_gifts: Array[int] = [20, 30, 40, 50, 60, 80, 150]

@export_group("Level start boosts")
## Coins at the start of the battle for an ad.
@export var boost_coins: int = 30

@export_group("Ad limits")
## Shop: −50% on a hero upgrade, times a day.
@export var discount_ads_per_day: int = 3

@export_group("Offline harvest")
@export var harvest_per_hour: float = 5.0
@export var harvest_max_hours: float = 8.0


func level_reward(stars: int) -> int:
	return grains_base + grains_per_star * stars


func skin(skin_id: StringName) -> SkinData:
	for s: SkinData in skins:
		if s.id == skin_id:
			return s
	return skins[0] if not skins.is_empty() else null
