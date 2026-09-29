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


func test_offline_harvest() -> void:
	assert_int(Game.harvest_amount(1000)).is_equal(0)
	Game.start_harvest(1000)
	# 5 per hour, 8 hours max.
	assert_int(Game.harvest_amount(1000 + 3600 * 2)).is_equal(10)
	assert_int(Game.harvest_amount(1000 + 3600 * 20)).is_equal(40)
	assert_int(Game.collect_harvest(1000 + 3600 * 3, 3)).is_equal(45)
	assert_int(Game.harvest_amount(1000 + 3600 * 3)).is_equal(0)


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
	assert_int(Game.harvest_time).is_equal(12345)
	assert_int(Game.ads_used(&"gift_x2", "2026-09-01")).is_equal(1)
	assert_bool(&"mole" in Game.seen).is_true()
	assert_bool(Game.tutorial_done).is_true()
	assert_int(Game.grains_earned).is_greater_equal(Game.grains)
