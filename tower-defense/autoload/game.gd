extends Node
## Player progress, meta and settings. Save turns it into a dictionary and
## back; the rest of the game reads and changes it only here. Balance numbers
## come from data/meta.tres (MetaData). Dates are "YYYY-MM-DD" strings and
## times are unix seconds, passed in so tests can pick any day.

signal settings_changed
signal progress_changed
signal grains_changed(grains: int)

## Levels in the campaign (farm map).
const LEVEL_COUNT := 12
const META: MetaData = preload("res://data/meta.tres")
const ADS: AdRewards = preload("res://data/ad_rewards.tres")

var music_on: bool = true
var sound_on: bool = true
## Master volume 0..1 (settings slider).
var volume: float = 1.0
## Level start boosts bought with an ad; the battle uses and clears them.
var boost_coins: bool = false
var boost_defender: bool = false
## Stars per level (0..3), index 0 = level 1. 0 = not passed yet.
var level_stars: Array[int] = []
## Meta currency (golden grains) and everything ever earned (save tie-break).
var grains: int = 0
var grains_earned: int = 0
## Hero upgrade levels 1..stat_max_level by stat id.
var stat_levels: Dictionary[StringName, int] = {}
var skins_owned: Array[StringName] = []
var skin: StringName = &""
## Rewarded views watched towards a skin, by skin id.
var skin_ads: Dictionary[StringName, int] = {}
## Daily gift: next calendar day 0..6 and the date of the last claim.
var gift_day: int = 0
var gift_date: String = ""
## Full gift weeks in a row (a missed day sets it back to 0).
var gift_week: int = 0
## Farm crops: level (1..3) and when the current harvest was planted (unix
## s; 0 = not planted yet: closed or never seen).
var crop_levels: Dictionary[StringName, int] = {}
var crop_planted: Dictionary[StringName, int] = {}
## Rewarded uses today by kind ("upgrade_discount", "gift_x2", ...).
var ad_date: String = ""
var ad_used: Dictionary[StringName, int] = {}
## Defenders and pests already introduced ("Новый защитник!" / "Новый враг!").
var seen: Array[StringName] = []
var tutorial_done: bool = false
## Skin tried on for one level (shop "Примерить"); not saved.
var trial_skin: StringName = &""
## Level the player is about to play / plays now, 1-based; not saved.
var current_level: int = 1


func _init() -> void:
	reset()


func reset() -> void:
	music_on = true
	sound_on = true
	volume = 1.0
	boost_coins = false
	boost_defender = false
	grains = 0
	grains_earned = 0
	level_stars.clear()
	level_stars.resize(LEVEL_COUNT)
	level_stars.fill(0)
	stat_levels.clear()
	for id: StringName in META.stats:
		stat_levels[id] = 1
	skins_owned.clear()
	for s: SkinData in META.skins:
		if s.free:
			skins_owned.append(s.id)
	skin = skins_owned[0] if not skins_owned.is_empty() else &""
	skin_ads.clear()
	gift_day = 0
	gift_date = ""
	gift_week = 0
	crop_levels.clear()
	crop_planted.clear()
	ad_date = ""
	ad_used.clear()
	seen.clear()
	tutorial_done = false
	trial_skin = &""
	current_level = 1


static func today() -> String:
	return Time.get_date_string_from_system()


static func now() -> int:
	return int(Time.get_unix_time_from_system())


# --- Levels -------------------------------------------------------------------

func total_stars() -> int:
	var total: int = 0
	for s: int in level_stars:
		total += s
	return total


## Level 1 is open; every next one opens when the previous is passed.
func is_level_open(level: int) -> bool:
	return level == 1 or (level >= 2 and level <= LEVEL_COUNT and level_stars[level - 2] > 0)


## The furthest open level (the map's "current" node).
func last_open_level() -> int:
	var n: int = 1
	while n < LEVEL_COUNT and level_stars[n - 1] > 0:
		n += 1
	return n


## Stores the result, pays the grains; returns the grains given.
func finish_level(level: int, stars: int) -> int:
	var i: int = level - 1
	if i < 0 or i >= LEVEL_COUNT:
		return 0
	level_stars[i] = maxi(level_stars[i], stars)
	var reward: int = META.level_reward(stars)
	add_grains(reward)
	_unlock_level_skins()
	progress_changed.emit()
	return reward


# --- Grains -------------------------------------------------------------------

func add_grains(n: int) -> void:
	if n <= 0:
		return
	grains += n
	grains_earned += n
	grains_changed.emit(grains)


func spend_grains(n: int) -> bool:
	if n < 0 or grains < n:
		return false
	grains -= n
	grains_changed.emit(grains)
	return true


# --- Hero upgrades ------------------------------------------------------------

func stat_level(id: StringName) -> int:
	return stat_levels.get(id, 1)


func is_stat_max(id: StringName) -> bool:
	return stat_level(id) >= META.stat_max_level


## Price of the next level (20 × 1.35^(lvl-1)), less with the ad discount.
func stat_price(id: StringName, discount: bool = false) -> int:
	var p: int = roundi(META.stat_price_base * pow(META.stat_price_growth, stat_level(id) - 1))
	return maxi(ceili(p * (1.0 - ADS.discount_share)), 1) if discount else p


## Stat multiplier: +10% per level above 1.
func stat_mult(id: StringName) -> float:
	return 1.0 + META.stat_step * (stat_level(id) - 1)


func buy_stat(id: StringName, discount: bool = false) -> bool:
	if is_stat_max(id) or not spend_grains(stat_price(id, discount)):
		return false
	stat_levels[id] = stat_level(id) + 1
	progress_changed.emit()
	return true


## The battle's hero: base stats × upgrades.
func hero_stats(base: HeroStats) -> HeroStats:
	var s: HeroStats = base.duplicate()
	s.damage = base.damage * stat_mult(&"damage")
	s.attacks_per_second = base.attacks_per_second * stat_mult(&"attack_speed")
	s.speed = base.speed * stat_mult(&"run_speed")
	s.magnet_radius = base.magnet_radius * stat_mult(&"magnet")
	return s


# --- Skins --------------------------------------------------------------------

func owns_skin(id: StringName) -> bool:
	return id in skins_owned


## Skin for the next battle: the tried-on one, else the selected one.
func battle_skin() -> SkinData:
	return META.skin(trial_skin if trial_skin != &"" else skin)


func select_skin(id: StringName) -> bool:
	if not owns_skin(id):
		return false
	skin = id
	trial_skin = &""
	progress_changed.emit()
	return true


func buy_skin(id: StringName) -> bool:
	var s: SkinData = META.skin(id)
	if s == null or owns_skin(id) or s.price_grains <= 0 or not spend_grains(s.price_grains):
		return false
	skins_owned.append(id)
	progress_changed.emit()
	return true


func skin_ad_views(id: StringName) -> int:
	return skin_ads.get(id, 0)


## One rewarded view towards an ad skin; true when that opened it.
func add_skin_ad(id: StringName) -> bool:
	var s: SkinData = META.skin(id)
	if s == null or owns_skin(id) or s.ad_views <= 0:
		return false
	skin_ads[id] = skin_ad_views(id) + 1
	if skin_ads[id] >= s.ad_views:
		skins_owned.append(id)
	progress_changed.emit()
	return owns_skin(id)


func _unlock_level_skins() -> void:
	for s: SkinData in META.skins:
		if s.unlock_level > 0 and not owns_skin(s.id) and level_stars[s.unlock_level - 1] > 0:
			skins_owned.append(s.id)


# --- Daily gift ---------------------------------------------------------------

## Calendar day (0..6) the gift would give on `date`: the next one after a
## claim yesterday, day 1 after a missed day.
func gift_day_on(date: String) -> int:
	if gift_date == "":
		return 0
	var days: int = _days_between(gift_date, date)
	if days == 1:
		return (gift_day + 1) % META.daily_gifts.size()
	if days <= 0:
		return gift_day
	return 0


func can_claim_gift(date: String) -> bool:
	return gift_date != date


## Week of the streak the gift of `date` belongs to (0 = the first).
func gift_week_on(date: String) -> int:
	if gift_date == "":
		return 0
	var days: int = _days_between(gift_date, date)
	if days <= 0:
		return gift_week
	if days > 1:
		return 0
	# The day after day 7 starts the next week.
	return gift_week + 1 if gift_day == META.daily_gifts.size() - 1 else gift_week


## Grains of calendar day `day` in streak week `week` (without the ad ×2).
func gift_amount(day: int, week: int) -> int:
	var k: float = 1.0 + META.gift_week_bonus * mini(week, META.gift_week_max)
	return roundi(META.daily_gifts[day] * k)


## Claims today's gift (× `mult` for the ad); returns the grains given.
func claim_gift(date: String, mult: int = 1) -> int:
	if not can_claim_gift(date):
		return 0
	gift_week = gift_week_on(date)
	gift_day = gift_day_on(date)
	gift_date = date
	var n: int = gift_amount(gift_day, gift_week) * mult
	add_grains(n)
	progress_changed.emit()
	return n


static func _days_between(a: String, b: String) -> int:
	var ta: int = Time.get_unix_time_from_datetime_string(a + "T00:00:00")
	var tb: int = Time.get_unix_time_from_datetime_string(b + "T00:00:00")
	return roundi((tb - ta) / 86400.0)


# --- Farm harvest -------------------------------------------------------------

func crop_open(c: CropData) -> bool:
	return c.unlock_after <= 0 or (c.unlock_after <= LEVEL_COUNT and level_stars[c.unlock_after - 1] > 0)


func crop_level(c: CropData) -> int:
	return crop_levels.get(c.id, 1)


## Share of the current harvest grown (0 before the crop is planted).
func crop_progress(c: CropData, at: int) -> float:
	var planted: int = crop_planted.get(c.id, 0)
	if planted <= 0 or not crop_open(c):
		return 0.0
	return clampf((at - planted) / (c.grow_hours * 3600.0), 0.0, 1.0)


func crop_ready(c: CropData, at: int) -> bool:
	return crop_progress(c, at) >= 1.0


## Seconds until the crop is ripe.
func crop_left(c: CropData, at: int) -> int:
	return ceili((1.0 - crop_progress(c, at)) * c.grow_hours * 3600.0)


func crop_yield(c: CropData) -> int:
	return c.yield_at(crop_level(c))


## Plants every open crop that is not growing yet (a crop starts when it
## opens; the old single bed carries its time over to the wheat).
func start_harvest(at: int) -> void:
	for c: CropData in META.crops:
		if crop_open(c) and crop_planted.get(c.id, 0) <= 0:
			crop_planted[c.id] = at


## Grains waiting in all ripe crops.
func harvest_ready(at: int) -> int:
	var n: int = 0
	for c: CropData in META.crops:
		if crop_ready(c, at):
			n += crop_yield(c)
	return n


## Takes one ripe crop (× mult for an ad) and plants it again; 0 if not ripe.
func collect_crop(c: CropData, at: int, mult: int = 1) -> int:
	if not crop_ready(c, at):
		return 0
	var n: int = crop_yield(c) * mult
	crop_planted[c.id] = at
	add_grains(n)
	progress_changed.emit()
	return n


func collect_all(at: int, mult: int = 1) -> int:
	var n: int = 0
	for c: CropData in META.crops:
		if crop_ready(c, at):
			n += crop_yield(c) * mult
			crop_planted[c.id] = at
	if n > 0:
		add_grains(n)
		progress_changed.emit()
	return n


## Next crop level for grains (the growing harvest keeps its time).
func upgrade_crop(c: CropData) -> bool:
	var level: int = crop_level(c)
	var price: int = c.upgrade_price(level)
	if price <= 0 or not crop_open(c) or not spend_grains(price):
		return false
	crop_levels[c.id] = level + 1
	progress_changed.emit()
	return true


# --- Daily ad limits ----------------------------------------------------------

func ads_used(kind: StringName, date: String) -> int:
	return ad_used.get(kind, 0) if ad_date == date else 0


func use_ad(kind: StringName, date: String) -> void:
	if ad_date != date:
		ad_date = date
		ad_used.clear()
	ad_used[kind] = ads_used(kind, date) + 1


# --- First meetings, settings -------------------------------------------------

## True the first time an id is met (and remembers it).
func first_meet(id: StringName) -> bool:
	if id in seen:
		return false
	seen.append(id)
	return true


## Progress score to pick the fresher save (local vs cloud).
func progress_score() -> int:
	return total_stars() * 1000000 + grains_earned


func set_sound(on: bool) -> void:
	sound_on = on
	settings_changed.emit()


func set_music(on: bool) -> void:
	music_on = on
	settings_changed.emit()


func set_volume(v: float) -> void:
	volume = clampf(v, 0.0, 1.0)
	settings_changed.emit()


# --- Save layout --------------------------------------------------------------

func to_dict() -> Dictionary:
	return {
		"music_on": music_on,
		"sound_on": sound_on,
		"volume": volume,
		"level_stars": level_stars.duplicate(),
		"grains": grains,
		"grains_earned": grains_earned,
		"stat_levels": _names_to_dict(stat_levels),
		"skins_owned": _names_to_strings(skins_owned),
		"skin": String(skin),
		"skin_ads": _names_to_dict(skin_ads),
		"gift_day": gift_day,
		"gift_date": gift_date,
		"gift_week": gift_week,
		"crop_levels": _names_to_dict(crop_levels),
		"crop_planted": _names_to_dict(crop_planted),
		"ad_date": ad_date,
		"ad_used": _names_to_dict(ad_used),
		"seen": _names_to_strings(seen),
		"tutorial_done": tutorial_done,
	}


## Missing or broken keys keep their defaults (old or damaged saves still load).
func from_dict(d: Dictionary) -> void:
	reset()
	music_on = _bool(d, "music_on", music_on)
	sound_on = _bool(d, "sound_on", sound_on)
	tutorial_done = _bool(d, "tutorial_done", tutorial_done)
	var vol: Variant = d.get("volume", volume)
	if vol is float or vol is int:
		var vf: float = vol
		volume = clampf(vf, 0.0, 1.0)
	grains = maxi(_int(d, "grains", 0), 0)
	grains_earned = maxi(_int(d, "grains_earned", grains), grains)
	gift_day = clampi(_int(d, "gift_day", 0), 0, META.daily_gifts.size() - 1)
	gift_date = _str(d, "gift_date")
	gift_week = maxi(_int(d, "gift_week", 0), 0)
	crop_planted = _dict_to_names(d.get("crop_planted"))
	var levels_c: Dictionary[StringName, int] = _dict_to_names(d.get("crop_levels"))
	for id: StringName in levels_c:
		var c: CropData = META.crop(id)
		if c != null:
			crop_levels[id] = clampi(levels_c[id], 1, c.max_level())
	# Saves before the farm crops had one harvest bed: its time goes to the wheat.
	var old_bed: int = _int(d, "harvest_time", 0)
	if old_bed > 0 and not crop_planted.has(&"wheat"):
		crop_planted[&"wheat"] = old_bed
	ad_date = _str(d, "ad_date")
	var stars: Variant = d.get("level_stars", [])
	if stars is Array:
		var arr: Array = stars
		for i: int in mini(arr.size(), LEVEL_COUNT):
			var v: Variant = arr[i]
			if v is float or v is int:
				var vf: float = v
				level_stars[i] = clampi(int(vf), 0, 3)
	var levels: Dictionary[StringName, int] = _dict_to_names(d.get("stat_levels"))
	for id: StringName in levels:
		if stat_levels.has(id):
			stat_levels[id] = clampi(levels[id], 1, META.stat_max_level)
	for id: StringName in _strings_to_names(d.get("skins_owned")):
		if META.skin(id) != null and META.skin(id).id == id and not owns_skin(id):
			skins_owned.append(id)
	var chosen: StringName = StringName(_str(d, "skin"))
	if owns_skin(chosen):
		skin = chosen
	skin_ads = _dict_to_names(d.get("skin_ads"))
	ad_used = _dict_to_names(d.get("ad_used"))
	seen = _strings_to_names(d.get("seen"))
	settings_changed.emit()
	progress_changed.emit()
	grains_changed.emit(grains)


static func _bool(d: Dictionary, key: String, fallback: bool) -> bool:
	var v: Variant = d.get(key, fallback)
	return v if v is bool else fallback


static func _int(d: Dictionary, key: String, fallback: int) -> int:
	var v: Variant = d.get(key, fallback)
	if v is float or v is int:
		var f: float = v
		return int(f)
	return fallback


static func _str(d: Dictionary, key: String) -> String:
	var v: Variant = d.get(key, "")
	return v if v is String else ""


static func _names_to_strings(names: Array[StringName]) -> Array[String]:
	var out: Array[String] = []
	for n: StringName in names:
		out.append(String(n))
	return out


static func _strings_to_names(v: Variant) -> Array[StringName]:
	var out: Array[StringName] = []
	if v is Array:
		var arr: Array = v
		for item: Variant in arr:
			if item is String:
				var s: String = item
				out.append(StringName(s))
	return out


static func _names_to_dict(d: Dictionary[StringName, int]) -> Dictionary:
	var out: Dictionary = {}
	for k: StringName in d:
		out[String(k)] = d[k]
	return out


static func _dict_to_names(v: Variant) -> Dictionary[StringName, int]:
	var out: Dictionary[StringName, int] = {}
	if v is Dictionary:
		var src: Dictionary = v
		for k: Variant in src:
			var val: Variant = src[k]
			if k is String and (val is float or val is int):
				var ks: String = k
				var f: float = val
				out[StringName(ks)] = maxi(int(f), 0)
	return out
