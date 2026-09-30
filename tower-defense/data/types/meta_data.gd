class_name MetaData
extends Resource
## Meta balance (CODE_PROMPT "Мета"): grains per level, hero upgrades, skins,
## daily gift, farm crops. The one copy is data/meta.tres.

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
## Grains for days 1..7 (day 7 is the chest); a missed day starts over from
## day 1 of week 1 (Twody: the player must want to come back every day).
@export var daily_gifts: Array[int] = [30, 50, 70, 100, 130, 170, 300]
## Every full week in a row adds this share to all gifts, up to `gift_week_max` weeks.
@export var gift_week_bonus: float = 0.25
@export var gift_week_max: int = 4

@export_group("Farm harvest")
## Crops in map order (CODE_PROMPT "Урожай фермы"): wheat, apple, pumpkin, apiary.
@export var crops: Array[CropData] = []


func level_reward(stars: int) -> int:
	return grains_base + grains_per_star * stars


func crop(crop_id: StringName) -> CropData:
	for c: CropData in crops:
		if c.id == crop_id:
			return c
	return null


func skin(skin_id: StringName) -> SkinData:
	for s: SkinData in skins:
		if s.id == skin_id:
			return s
	return skins[0] if not skins.is_empty() else null
