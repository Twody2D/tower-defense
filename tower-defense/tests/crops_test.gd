extends GdUnitTestSuite
## Crops by the road (CODE_PROMPT "Урожай фермы"): the hero stands next to a
## ripe one → it shakes → 5–10 coins fall; it grows back and can be shaken
## again. Every level has 1–3 of them, level 1 has one.


func before_test() -> void:
	Game.reset()
	Game.tutorial_done = true
	for id: StringName in [&"goose", &"frog", &"hive", &"beaver", &"fence",
			&"beetle", &"caterpillar", &"mole", &"crow", &"fox"]:
		Game.first_meet(id)


func test_hero_shakes_a_crop_for_coins() -> void:
	Game.current_level = 1
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var crops: Array[BattleCrop] = battle.level.crops()
	assert_int(crops.size()).is_equal(1)
	var crop: BattleCrop = crops[0]
	crop.regrow_time = 1.0
	# Too short a stop does nothing.
	battle.hero.global_position = crop.global_position + Vector2(40, 0)
	await runner.simulate_frames(20, 16)
	battle.hero.global_position = crop.global_position + Vector2(600, 0)
	await runner.simulate_frames(5, 16)
	assert_bool(crop.is_ripe()).is_true()
	# A full second next to it: shaken, the fruits turn into coins.
	var before: int = battle.coins.total_value() + battle.state.coins
	battle.hero.global_position = crop.global_position + Vector2(40, 0)
	await runner.simulate_frames(90, 16)
	battle.hero.global_position = crop.global_position + Vector2(600, 0)
	await runner.simulate_frames(20, 16)
	assert_bool(crop.is_ripe()).is_false()
	var got: int = battle.coins.total_value() + battle.state.coins - before
	assert_int(got).is_between(crop.coins_min, crop.coins_max)
	# It grows back.
	await runner.simulate_frames(90, 16)
	assert_bool(crop.is_ripe()).is_true()


func test_every_level_has_crops() -> void:
	for n: int in range(1, 13):
		var level: Level = (load("res://scenes/levels/level_%02d.tscn" % n) as PackedScene).instantiate() as Level
		var count: int = level.crops().size()
		assert_int(count).override_failure_message("L%d: %d crops" % [n, count]).is_between(1, 3)
		level.free()
