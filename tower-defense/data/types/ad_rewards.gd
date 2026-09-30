class_name AdRewards
extends Resource
## Every ad number and limit (CODE_PROMPT "Реклама"): what a rewarded video
## gives, daily limits, fullscreen rule, "Посылка от фермера" and its seven
## bonuses. The one copy is data/ad_rewards.tres (Game.ADS).

@export_group("Fullscreen")
## No fullscreen on the way back from levels up to this one.
@export var no_fullscreen_until_level: int = 2

@export_group("Menus and results")
## Victory: grains × this.
@export var win_mult: int = 2
## Level start: coins at the start of the fight.
@export var start_coins: int = 30
## Level start: the starting defender (goose) stands at this level.
@export var start_defender_level: int = 2
## Defeat, once per level: carrots back, the fight goes on.
@export var second_chance_carrots: int = 5
## Shop: the next hero upgrade costs this share less, times a day.
@export var discount_share: float = 0.5
@export var discount_per_day: int = 3
## Daily gift × this, times a day.
@export var gift_mult: int = 2
@export var gift_per_day: int = 1
## Offline harvest × this (every collection).
@export var harvest_mult: int = 3

@export_group("Parcel")
## The parcel falls every this many waves (random in the range).
@export var parcel_every_min: int = 2
@export var parcel_every_max: int = 3
## Seconds after the wave start, so it does not land together with the banner.
@export var parcel_delay: float = 4.0
## Lies this long, blinking at the end, s.
@export var parcel_lifetime: float = 12.0
@export var parcel_blink: float = 3.0
## Lands this far from the hero, px; picked up closer than `parcel_pickup`.
@export var parcel_distance: float = 190.0
@export var parcel_pickup: float = 80.0

@export_group("Free gift")
## Twody: not only ad bonuses. A gift box falls on the waves without the ad
## parcel and gives one of these at once when the hero walks up to it.
@export var gift_bonuses: Array[StringName] = [&"gold_rain", &"rage", &"super_magnet", &"sleepy_rain"]

@export_group("Bonuses")
## Gold rain: base × (wave / divisor) coins around the hero.
@export var gold_rain_base: int = 50
@export var gold_rain_wave_div: float = 3.0
## Coins fall over this time and this far from the hero.
@export var gold_rain_time: float = 1.6
@export var gold_rain_radius: float = 240.0
## Hero rage: damage and attack speed × this.
@export var rage_mult: float = 2.0
@export var rage_time: float = 30.0
## Super magnet: coins from the whole map fly to the hero.
@export var magnet_time: float = 30.0
## Tractor: drives along every road from the carrots to the burrow; pests this
## close are blown away (except the boss).
@export var tractor_speed: float = 650.0
@export var tractor_radius: float = 110.0
## Sleepy rain: every pest slowed by this share.
@export var sleepy_slow: float = 0.6
@export var sleepy_time: float = 15.0
## Helper: a second hero (random other skin) runs along and throws.
@export var helper_time: float = 45.0


func gold_rain_coins(wave: int) -> int:
	return maxi(roundi(gold_rain_base * maxf(wave, 1) / gold_rain_wave_div), 1)
