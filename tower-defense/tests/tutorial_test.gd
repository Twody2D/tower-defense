extends GdUnitTestSuite
## Level 1 tutorial: the first wave waits; move → plot → pick → build →
## coins, then it is done for good.


func before_test() -> void:
	Game.reset()
	Game.current_level = 1
	for id: StringName in [&"goose", &"beetle", &"fox"]:
		Game.first_meet(id)


func test_level_1_tutorial_flow() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var tut: Tutorial = battle.tutorial
	assert_bool(battle.waves.hold).is_true()
	tut.start(1)
	assert_int(tut.step).is_equal(Tutorial.Step.MOVE)
	# Straight onto a plot: "move" is skipped, the pick is asked.
	var plot: BuildPlot = tut._free_plot()
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(5, 16)
	assert_int(tut.step).is_equal(Tutorial.Step.PICK)
	battle.hud.radial_menu._on_slot_picked(battle.level.data.defenders[0])
	await runner.simulate_frames(3, 16)
	assert_int(tut.step).is_equal(Tutorial.Step.BUILD)
	# 10 coins at 0.05 s after the 0.35 s wait: built, the waves go on.
	await runner.simulate_frames(60, 16)
	assert_int(plot.level).is_equal(1)
	assert_bool(battle.waves.hold).is_false()
	assert_int(tut.step).is_equal(Tutorial.Step.COINS)
	battle.coins.drop(battle.hero.global_position + Vector2(40, 0), 5)
	await runner.simulate_frames(90, 16)
	assert_int(tut.step).is_equal(Tutorial.Step.OFF)
	assert_bool(Game.tutorial_done).is_true()


func test_no_tutorial_after_it_is_done() -> void:
	Game.tutorial_done = true
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	assert_bool(battle.waves.hold).is_false()
	battle.tutorial.start(1)
	assert_int(battle.tutorial.step).is_equal(Tutorial.Step.OFF)


func test_hint_hides_under_the_pause() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	battle.tutorial.start(1)
	await runner.simulate_frames(3, 16)
	assert_bool(battle.tutorial.layer.visible).is_true()
	battle._toggle_pause()
	assert_bool(battle.pause_window.visible).is_true()
	assert_bool(battle.tutorial.layer.visible).is_false()
	battle._toggle_pause()
	assert_bool(battle.tutorial.layer.visible).is_true()
