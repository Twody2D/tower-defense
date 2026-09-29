extends GdUnitTestSuite
## Whole battle scene: the hero on the plot builds and upgrades the defender,
## pests die and drop coins, coins reach the hero.


func test_plot_builds_and_upgrades() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var plot: BuildPlot = battle.level.plots()[0]
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(90, 16)
	assert_int(plot.level).is_equal(1)
	assert_int(battle.state.coins).is_equal(0)
	assert_bool(plot.defender.visible).is_true()
	# Partial payment stays on the plot after the hero leaves.
	battle.state.add_coins(5)
	await runner.simulate_frames(30, 16)
	assert_int(plot.paid).is_equal(5)
	battle.hero.global_position = plot.global_position + Vector2(400, 0)
	battle.state.add_coins(100)
	await runner.simulate_frames(20, 16)
	assert_int(plot.paid).is_equal(5)
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(200, 16)
	assert_int(plot.level).is_equal(3)
	assert_bool(plot.is_max()).is_true()
	assert_int(battle.state.coins).is_equal(105 - 20 - 40)


func test_hero_kills_pests_and_collects_coins() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var start_coins: int = battle.state.coins
	# Stand next to the road where the first wave passes.
	var road: Curve2D = battle.level.road_curve()
	battle.hero.global_position = road.sample_baked(500.0) + Vector2(0, 90)
	await runner.simulate_frames(1500, 16)
	assert_int(battle.wave).is_greater_equal(1)
	assert_int(battle.state.coins).is_greater(start_coins)
