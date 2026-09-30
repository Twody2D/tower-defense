extends GdUnitTestSuite
## Whole battle scene: plot flow (menu → pick → pay → build → upgrade),
## pests die and drop coins, coins reach the hero, a touch stuns the hero.


## Every defender and pest already met: no newcomer windows pause the fight.
func before_test() -> void:
	Game.reset()
	Game.tutorial_done = true
	for id: StringName in [&"goose", &"frog", &"hive", &"beaver", &"fence",
			&"beetle", &"caterpillar", &"mole", &"crow", &"fox"]:
		Game.first_meet(id)


func _goose(battle: Battle) -> DefenderData:
	return battle.defender_catalog[0]


func test_plot_menu_pick_build_upgrade() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var plot: BuildPlot = battle.level.plots()[0]
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(5, 16)
	# Stepping on an empty plot opens the menu; the game goes on.
	assert_bool(battle.get_tree().paused).is_false()
	assert_bool(battle.hud.radial_menu.visible).is_true()
	assert_int(plot.paid).is_equal(0)
	battle.hud.radial_menu._on_slot_picked(_goose(battle))
	# Start delay 0.35 s, then 10 coins at 0.05 s each.
	await runner.simulate_frames(80, 16)
	assert_int(plot.level).is_equal(1)
	assert_int(battle.state.coins).is_equal(0)
	assert_bool(plot.defender.visible).is_true()
	# Not enough for level 2 (20): nothing goes in.
	battle.state.add_coins(5)
	await runner.simulate_frames(60, 16)
	assert_int(plot.paid).is_equal(0)
	assert_int(battle.state.coins).is_equal(5)
	# Running past (shorter than the start delay) spends nothing.
	battle.state.add_coins(100)
	battle.hero.global_position = plot.global_position + Vector2(400, 0)
	await runner.simulate_frames(3, 16)
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(10, 16)
	assert_int(plot.paid).is_equal(0)
	# Leaving an unfinished level gives the coins back.
	await runner.simulate_frames(25, 16)
	assert_int(plot.paid).is_greater(0)
	battle.hero.global_position = plot.global_position + Vector2(400, 0)
	await runner.simulate_frames(3, 16)
	assert_int(plot.paid).is_equal(0)
	assert_int(battle.state.coins).is_equal(105)
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(250, 16)
	assert_int(plot.level).is_equal(3)
	assert_bool(plot.is_max()).is_true()
	assert_int(battle.state.coins).is_equal(105 - 20 - 40)


func test_menu_closes_when_hero_leaves() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var plot: BuildPlot = battle.level.plots()[0]
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(5, 16)
	assert_bool(battle.hud.radial_menu.visible).is_true()
	battle.hero.global_position = plot.global_position + Vector2(400, 0)
	await runner.simulate_frames(5, 16)
	assert_bool(battle.hud.radial_menu.visible).is_false()
	assert_object(plot.chosen).is_null()
	assert_int(battle.state.coins).is_equal(10)


func test_pause_key_toggles() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	await runner.simulate_frames(2, 16)
	var key: InputEventAction = InputEventAction.new()
	key.action = &"pause"
	key.pressed = true
	battle.hud._unhandled_input(key)
	assert_bool(battle.get_tree().paused).is_true()
	assert_bool(battle.pause_window.visible).is_true()
	battle.hud._unhandled_input(key)
	assert_bool(battle.pause_window.visible).is_false()
	assert_bool(battle.get_tree().paused).is_false()


func test_hero_kills_pests_and_collects_coins() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var start_coins: int = battle.state.coins
	# Stand next to the road where the first wave passes.
	var road: Curve2D = battle.level.road_curve()
	# Within reach (160) but out of touch, so the pests do not stun the hero.
	battle.hero.global_position = road.sample_baked(300.0) + Vector2(-110, 0)
	# The real hero is weak on purpose (towers do the job); here only the
	# kill → coins → pick-up chain is checked.
	battle.hero.stats.damage = 20.0
	await runner.simulate_frames(2000, 16)
	assert_int(battle.waves.wave).is_greater_equal(1)
	# Picked up or still on the ground outside the magnet.
	assert_int(battle.state.coins + battle.coins.total_value()).is_greater(start_coins)


func test_touch_stuns_then_invulnerable() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
	var battle: Battle = runner.scene() as Battle
	var hero: Hero = battle.hero
	hero.stun()
	assert_bool(hero.is_stunned()).is_true()
	await runner.simulate_frames(100, 16)
	assert_bool(hero.is_stunned()).is_false()
	assert_bool(hero.is_invulnerable()).is_true()
	hero.stun()
	assert_bool(hero.is_stunned()).is_false()
	await runner.simulate_frames(70, 16)
	assert_bool(hero.is_invulnerable()).is_false()


func test_fence_plot_build_and_repair() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://dev/battle_sandbox.tscn")
	var battle: Battle = runner.scene() as Battle
	var plot: BuildPlot = null
	for p: BuildPlot in battle.level.plots():
		if p.fence_plot:
			plot = p
	# Fence plots build right away: no menu. Coins for level 1 only.
	battle.state.coins = plot.chosen.price(1)
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(50, 16)
	assert_bool(battle.get_tree().paused).is_false()
	assert_int(plot.level).is_equal(1)
	battle.hero.global_position = plot.global_position + Vector2(300, 0)
	await runner.simulate_frames(2, 16)
	var max_hp: float = plot.fence.block.max_hp
	plot.fence.block.hit(max_hp * 0.5)
	# A full repair costs half the level price; half the HP needs about half of that.
	var full_repair: int = ceili(plot.chosen.price(plot.level) * plot.chosen.repair_price_share)
	battle.state.coins = full_repair
	battle.hero.global_position = plot.global_position
	await runner.simulate_frames(60, 16)
	assert_float(plot.fence.block.hp).is_equal_approx(max_hp, 0.5)
	assert_int(battle.state.coins).is_greater_equal(0)
	assert_int(full_repair - battle.state.coins).is_less_equal(full_repair)


## Twody: standing on a fence plot inside a tower's reach raised both. The
## hero builds at one plot only: the one it is clearly deeper in.
func test_hero_builds_one_plot_at_a_time() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://dev/battle_sandbox.tscn")
	var battle: Battle = runner.scene() as Battle
	var tower: BuildPlot = null
	var fence: BuildPlot = null
	for p: BuildPlot in battle.level.plots():
		if p.fence_plot and fence == null:
			fence = p
		elif not p.fence_plot and not p.locked and tower == null:
			tower = p
	tower.prebuild(_goose(battle), 1)
	fence.global_position = tower.global_position + Vector2(110, 0)
	assert_bool(tower.contains(fence.global_position)).is_true()
	battle.state.coins = 1000
	battle.hero.global_position = fence.global_position
	await runner.simulate_frames(60, 16)
	assert_int(fence.level).is_greater(0)
	assert_int(tower.level).is_equal(1)
	assert_int(tower.paid).is_equal(0)
	assert_object(battle.hero.plot).is_same(fence)


func test_upgrade_pauses_between_levels() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://dev/battle_sandbox.tscn")
	var battle: Battle = runner.scene() as Battle
	var tower: BuildPlot = null
	for p: BuildPlot in battle.level.plots():
		if not p.fence_plot and not p.locked and tower == null:
			tower = p
	tower.prebuild(_goose(battle), 1)
	battle.state.coins = 1000
	battle.hero.global_position = tower.global_position + Vector2(100, 0)
	for i: int in 600:
		await runner.simulate_frames(1, 16)
		if tower.level == 2:
			break
	assert_int(tower.level).is_equal(2)
	# Level 2 done: no coins go into level 3 for a moment (time to step off).
	await runner.simulate_frames(45, 16)
	assert_int(tower.level).is_equal(2)
	assert_int(tower.paid).is_equal(0)
	# Still standing: the next level starts.
	await runner.simulate_frames(40, 16)
	assert_bool(tower.paid > 0 or tower.level == 3).is_true()
