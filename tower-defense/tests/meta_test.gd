extends GdUnitTestSuite
## Meta rules in Game: level rewards and unlocks, hero upgrades, skins,
## daily gift streak, offline harvest, daily ad limits, save round trip.


func before_test() -> void:
	Game.reset()


func after_test() -> void:
	Game.reset()


func test_level_reward_and_unlock() -> void:
	assert_bool(Game.is_level_open(1)).is_true()
	assert_bool(Game.is_level_open(2)).is_false()
	# 30 + 10 per star.
	assert_int(Game.finish_level(1, 2)).is_equal(50)
	assert_int(Game.grains).is_equal(50)
	assert_bool(Game.is_level_open(2)).is_true()
	assert_int(Game.last_open_level()).is_equal(2)
	# Replaying with fewer stars keeps the best.
	Game.finish_level(1, 1)
	assert_int(Game.level_stars[0]).is_equal(2)


func test_stat_upgrade_price_and_bonus() -> void:
	# 20 × 1.35^(lvl-1): 20, 27, 36, ...
	assert_int(Game.stat_price(&"damage")).is_equal(20)
	assert_int(Game.stat_price(&"damage", true)).is_equal(10)
	assert_bool(Game.buy_stat(&"damage")).is_false()
	Game.add_grains(100)
	assert_bool(Game.buy_stat(&"damage")).is_true()
	assert_int(Game.grains).is_equal(80)
	assert_int(Game.stat_level(&"damage")).is_equal(2)
	assert_int(Game.stat_price(&"damage")).is_equal(27)
	var base: HeroStats = load("res://data/hero_stats.tres")
	assert_float(Game.hero_stats(base).damage).is_equal_approx(base.damage * 1.1, 0.001)
	assert_float(Game.hero_stats(base).speed).is_equal_approx(base.speed, 0.001)


func test_stat_stops_at_max() -> void:
	Game.stat_levels[&"magnet"] = Game.META.stat_max_level
	Game.add_grains(100000)
	assert_bool(Game.buy_stat(&"magnet")).is_false()


func test_skins() -> void:
	assert_bool(Game.owns_skin(&"raccoon")).is_true()
	assert_bool(Game.select_skin(&"corgi")).is_false()
	Game.add_grains(500)
	assert_bool(Game.buy_skin(&"corgi")).is_true()
	assert_bool(Game.select_skin(&"corgi")).is_true()
	# Rabbit: 5 rewarded views.
	for i: int in 4:
		assert_bool(Game.add_skin_ad(&"rabbit")).is_false()
	assert_bool(Game.add_skin_ad(&"rabbit")).is_true()
	# Chicken: pass level 12.
	Game.finish_level(12, 1)
	assert_bool(Game.owns_skin(&"chicken")).is_true()
	Game.trial_skin = &"pig"
	assert_str(String(Game.battle_skin().id)).is_equal("pig")


func test_daily_gift_streak() -> void:
	var gifts: Array[int] = Game.META.daily_gifts
	assert_int(Game.claim_gift("2026-09-01")).is_equal(gifts[0])
	assert_bool(Game.can_claim_gift("2026-09-01")).is_false()
	assert_int(Game.claim_gift("2026-09-02")).is_equal(gifts[1])
	assert_int(Game.claim_gift("2026-09-03", 2)).is_equal(gifts[2] * 2)
	# A missed day starts over.
	assert_int(Game.claim_gift("2026-09-05")).is_equal(gifts[0])


func test_daily_gift_wraps_after_day_7() -> void:
	for d: int in 7:
		Game.claim_gift("2026-09-%02d" % (d + 1))
	assert_int(Game.gift_day_on("2026-09-08")).is_equal(0)


func test_gift_weeks_in_a_row_grow() -> void:
	var gifts: Array[int] = Game.META.daily_gifts
	for d: int in 7:
		Game.claim_gift("2026-09-%02d" % (d + 1))
	# Week 2: +25%.
	assert_int(Game.claim_gift("2026-09-08")).is_equal(roundi(gifts[0] * 1.25))
	# A missed day: week 1, day 1 again.
	assert_int(Game.claim_gift("2026-09-10")).is_equal(gifts[0])
	assert_int(Game.gift_week).is_equal(0)


func test_farm_crops_grow_collect_upgrade() -> void:
	var wheat: CropData = Game.META.crop(&"wheat")
	var apple: CropData = Game.META.crop(&"apple")
	# Only the wheat is open at the start; the apple tree after level 1.
	assert_bool(Game.crop_open(wheat)).is_true()
	assert_bool(Game.crop_open(apple)).is_false()
	Game.start_harvest(1000)
	assert_float(Game.crop_progress(wheat, 1000 + 1800)).is_equal_approx(0.5, 0.001)
	assert_int(Game.collect_crop(wheat, 1000 + 1800)).is_equal(0)
	var ripe: int = 1000 + int(wheat.grow_hours * 3600.0)
	assert_int(Game.harvest_ready(ripe)).is_equal(wheat.yields[0])
	# Collected: grains in, a new harvest starts growing.
	assert_int(Game.collect_crop(wheat, ripe, 3)).is_equal(wheat.yields[0] * 3)
	assert_int(Game.grains).is_equal(wheat.yields[0] * 3)
	assert_bool(Game.crop_ready(wheat, ripe)).is_false()
	# Level 2 for grains: a bigger harvest.
	Game.add_grains(1000)
	assert_bool(Game.upgrade_crop(wheat)).is_true()
	assert_int(Game.crop_level(wheat)).is_equal(2)
	assert_int(Game.crop_yield(wheat)).is_equal(wheat.yields[1])
	# Level 1 passed: the apple tree is planted on the next visit.
	Game.finish_level(1, 3)
	Game.start_harvest(ripe)
	assert_bool(Game.crop_open(apple)).is_true()
	var both: int = ripe + int(apple.grow_hours * 3600.0)
	assert_int(Game.collect_all(both)).is_equal(wheat.yields[1] + apple.yields[0])


func test_old_harvest_bed_goes_to_wheat() -> void:
	Game.from_dict({"harvest_time": 5000})
	assert_int(Game.crop_planted[&"wheat"]).is_equal(5000)


func test_ad_limits_reset_daily() -> void:
	Game.use_ad(&"upgrade_discount", "2026-09-01")
	Game.use_ad(&"upgrade_discount", "2026-09-01")
	assert_int(Game.ads_used(&"upgrade_discount", "2026-09-01")).is_equal(2)
	assert_int(Game.ads_used(&"upgrade_discount", "2026-09-02")).is_equal(0)


func test_first_meet() -> void:
	assert_bool(Game.first_meet(&"frog")).is_true()
	assert_bool(Game.first_meet(&"frog")).is_false()


func test_meta_round_trip() -> void:
	Game.add_grains(900)
	Game.buy_stat(&"run_speed")
	Game.buy_skin(&"corgi")
	Game.select_skin(&"corgi")
	Game.add_skin_ad(&"rabbit")
	Game.claim_gift("2026-09-01")
	Game.start_harvest(12345)
	Game.add_grains(500)
	Game.upgrade_crop(Game.META.crop(&"wheat"))
	Game.use_ad(&"gift_x2", "2026-09-01")
	Game.first_meet(&"mole")
	Game.tutorial_done = true
	var d: Dictionary = JSON.parse_string(JSON.stringify(Save.migrate(Game.to_dict())))
	Game.reset()
	Game.from_dict(d)
	assert_int(Game.stat_level(&"run_speed")).is_equal(2)
	assert_str(String(Game.skin)).is_equal("corgi")
	assert_int(Game.skin_ad_views(&"rabbit")).is_equal(1)
	assert_str(Game.gift_date).is_equal("2026-09-01")
	assert_int(Game.crop_planted[&"wheat"]).is_equal(12345)
	assert_int(Game.crop_level(Game.META.crop(&"wheat"))).is_equal(2)
	assert_int(Game.ads_used(&"gift_x2", "2026-09-01")).is_equal(1)
	assert_bool(&"mole" in Game.seen).is_true()
	assert_bool(Game.tutorial_done).is_true()
	assert_int(Game.grains_earned).is_greater_equal(Game.grains)
