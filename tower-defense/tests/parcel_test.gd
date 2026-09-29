extends GdUnitTestSuite
## "Посылка от фермера": the parcel falls, the hero opens it, the fight
## waits for the pick; the bonuses do what they say.


func before_test() -> void:
	Game.reset()
	for id: StringName in [&"goose", &"frog", &"hive", &"beaver", &"fence",
			&"beetle", &"caterpillar", &"mole", &"crow", &"fox"]:
		Game.first_meet(id)


func test_gold_rain_amount_grows_with_waves() -> void:
	var ads: AdRewards = Game.ADS
	assert_int(ads.gold_rain_coins(3)).is_equal(50)
	assert_int(ads.gold_rain_coins(6)).is_equal(100)
	assert_int(ads.gold_rain_coins(1)).is_equal(17)


func test_parcel_open_pick_and_decline() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	battle._drop_parcel()
	assert_bool(battle.parcel.visible).is_true()
	# Falling: not open yet even if the hero stands there.
	await runner.simulate_frames(110, 16)
	assert_bool(battle.parcel.is_waiting()).is_true()
	battle.hero.global_position = battle.parcel.global_position
	await runner.simulate_frames(3, 16)
	assert_bool(battle.parcel_window.visible).is_true()
	assert_bool(battle.get_tree().paused).is_true()
	# The video was watched: the bonus works, the fight goes on.
	battle.parcel_window._on_taken(&"rage")
	assert_bool(battle.get_tree().paused).is_false()
	assert_float(battle.hero.damage_mult).is_equal(Game.ADS.rage_mult)
	assert_bool(battle.bonuses.is_active(&"rage")).is_true()
	# Next parcel, declined: nothing given, the fight goes on.
	battle._drop_parcel()
	await runner.simulate_frames(110, 16)
	battle.hero.global_position = battle.parcel.global_position
	await runner.simulate_frames(3, 16)
	assert_bool(battle.parcel_window.visible).is_true()
	battle.parcel_window._on_declined()
	assert_bool(battle.get_tree().paused).is_false()


func test_parcel_goes_away_after_its_time() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	battle._drop_parcel()
	var frames: int = int((battle.parcel.fall_time + Game.ADS.parcel_lifetime) * 60.0) + 30
	await runner.simulate_frames(frames, 16)
	assert_bool(battle.parcel.visible).is_false()


func test_offer_skips_what_makes_no_sense() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	await runner.simulate_frames(2, 16)
	# Nothing built, no pests yet: no free upgrade, no tractor.
	var ids: Array[StringName] = battle.bonuses.offer(7)
	assert_array(ids).not_contains([&"upgrade", &"tractor"])
	assert_int(ids.size()).is_equal(5)
	battle.bonuses.apply(&"helper", 1)
	assert_array(battle.bonuses.offer(7)).not_contains([&"helper"])
	assert_int(battle.bonuses.offer(2).size()).is_equal(2)


func test_gold_rain_drops_coins() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var before: int = battle.state.coins
	battle.bonuses.apply(&"gold_rain", 3)
	await runner.simulate_frames(150, 16)
	assert_int(battle.state.coins + battle.coins.total_value() - before).is_equal(50)


func test_tractor_blows_pests_away_but_not_the_boss() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var beetle: EnemyData = load("res://data/enemies/beetle.tres")
	var fox: EnemyData = load("res://data/enemies/fox.tres")
	for k: int in 6:
		battle.enemies.spawn(beetle, 1.0, 0)
	var fox_id: int = battle.enemies.spawn(fox, 1.0, 0)
	await runner.simulate_frames(30, 16)
	battle.bonuses.apply(&"tractor", 1)
	# The road is ~3500 px, the tractor goes 650 px/s back towards the burrow.
	await runner.simulate_frames(420, 16)
	assert_int(battle.enemies.index_of(fox_id)).is_greater_equal(0)
	assert_int(battle.enemies.count).is_equal(1)


func test_free_upgrade_and_sleepy_rain() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var plot: BuildPlot = null
	for p: BuildPlot in battle.level.plots():
		if not p.fence_plot and not p.locked:
			plot = p
			break
	plot.prebuild(battle.defender_catalog[0], 1)
	battle.bonuses.apply(&"upgrade", 1)
	assert_int(plot.level).is_equal(2)
	battle.bonuses.apply(&"sleepy_rain", 1)
	assert_float(battle.enemies.global_slow).is_equal(Game.ADS.sleepy_slow)
	battle.bonuses.apply(&"super_magnet", 1)
	assert_float(battle.coins.magnet_radius).is_equal(INF)
