extends GdUnitTestSuite
## All 12 campaign levels: the battle loads the picked one, roads lead to the
## bed, waves use only existing roads, unlocks follow CODE_PROMPT, the last
## wave has the fox.

const UNLOCK: Dictionary[StringName, int] = {&"goose": 1, &"frog": 3, &"beaver": 5, &"hive": 8}
const ENEMY_FROM: Dictionary[StringName, int] = {&"beetle": 1, &"caterpillar": 2, &"mole": 4, &"crow": 6, &"fox": 1}


func before_test() -> void:
	Game.reset()
	Game.tutorial_done = true
	for id: StringName in [&"goose", &"frog", &"hive", &"beaver", &"fence",
			&"beetle", &"caterpillar", &"mole", &"crow", &"fox"]:
		Game.first_meet(id)


func test_level_data() -> void:
	for n: int in range(1, 13):
		var data: LevelData = load("res://data/levels/level_%02d.tres" % n)
		assert_int(data.number).is_equal(n)
		var waves: int = [5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8][n - 1]
		assert_int(data.waves.size()).is_equal(waves)
		for d: DefenderData in data.defenders:
			assert_bool(UNLOCK[d.id] <= n).override_failure_message("L%d: %s too early" % [n, d.id]).is_true()
		assert_int(data.defenders.size()).is_equal(UNLOCK.values().filter(func(v: int) -> bool: return v <= n).size())
		for e: EnemyData in data.enemy_types():
			assert_bool(ENEMY_FROM[e.id] <= n).override_failure_message("L%d: %s too early" % [n, e.id]).is_true()
		var last: WaveData = data.waves[data.waves.size() - 1]
		var boss: bool = false
		for g: WaveGroup in last.groups:
			boss = boss or g.enemy.is_boss
		assert_bool(boss).override_failure_message("L%d: no boss" % n).is_true()


func test_every_level_plays() -> void:
	for n: int in range(1, 13):
		Game.current_level = n
		var runner: GdUnitSceneRunner = scene_runner("res://scenes/battle/battle.tscn")
		var battle: Battle = runner.scene() as Battle
		assert_int(battle.level_number).is_equal(n)
		assert_int(battle.level.data.number).is_equal(n)
		var roads: int = battle.level.roads().size()
		var bed: Vector2 = battle.level.base().global_position
		for r: Path2D in battle.level.roads():
			var end: Vector2 = r.curve.get_point_position(r.curve.point_count - 1)
			assert_float(end.distance_to(bed)).override_failure_message("L%d: road ends far from the bed" % n).is_less(260.0)
		for w: WaveData in battle.level.data.waves:
			for g: WaveGroup in w.groups:
				assert_int(g.road).is_less(roads)
		# The first wave comes out on every road.
		battle.waves.call_now()
		await runner.simulate_frames(240, 16)
		assert_int(battle.waves.wave).is_equal(1)
		assert_int(battle.enemies.count).is_greater(0)
		runner = null
