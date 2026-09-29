extends GdUnitTestSuite
## WaveRunner timing, "call now" bonus; mole, crow and boss rules;
## stars by lost carrots.

var _enemies: EnemyManager


func before_test() -> void:
	var curve: Curve2D = Curve2D.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1000, 0))
	curve.add_point(Vector2(1000, 1000))
	_enemies = auto_free(EnemyManager.new())
	_enemies.lateral_spread = 0.0
	_enemies.frames_shader = load("res://shaders/enemy_frames.gdshader")
	_enemies.setup([curve] as Array[Curve2D], Rect2(-200, -200, 1400, 1400))
	add_child(_enemies)


func _data(file: String) -> EnemyData:
	return (load("res://data/enemies/%s.tres" % file) as EnemyData).duplicate()


func _level(counts: Array[int]) -> LevelData:
	var level: LevelData = LevelData.new()
	level.first_pause = 5.0
	level.wave_pause = 20.0
	for c: int in counts:
		var g: WaveGroup = WaveGroup.new()
		g.enemy = _data("beetle")
		g.count = c
		g.interval = 1.0
		var w: WaveData = WaveData.new()
		w.groups = [g] as Array[WaveGroup]
		level.waves.append(w)
	return level


func test_waves_break_spawn_and_call_now() -> void:
	var runner: WaveRunner = auto_free(WaveRunner.new())
	add_child(runner)
	runner.set_process(false)
	runner.start(_level([3, 2] as Array[int]), _enemies)
	assert_bool(runner.in_break()).is_true()
	runner._process(5.1)
	assert_int(runner.wave).is_equal(1)
	# The first pest of a wave comes out on the next tick.
	runner._process(0.0)
	assert_int(_enemies.count).is_equal(1)
	runner._process(2.0)
	assert_int(_enemies.count).is_equal(3)
	# Wave 1 is out: 20 s break; call now after 5 s gives +15.
	runner._process(0.1)
	assert_bool(runner.in_break()).is_true()
	runner._process(5.0)
	assert_int(runner.call_now()).is_equal(15)
	assert_int(runner.wave).is_equal(2)
	runner._process(0.0)
	runner._process(1.1)
	assert_bool(runner.is_done()).is_true()
	assert_int(_enemies.count).is_equal(5)


func test_stars_by_carrots_lost() -> void:
	var level: LevelData = LevelData.new()
	assert_int(level.stars_for(0)).is_equal(3)
	assert_int(level.stars_for(5)).is_equal(2)
	assert_int(level.stars_for(6)).is_equal(1)


func test_mole_dives_under_fence_and_is_untouchable() -> void:
	var mole: EnemyData = _data("mole")
	mole.dive_every = 100.0
	var block: RoadBlock = RoadBlock.new()
	block.progress = 300.0
	block.set_hp(150.0, 150.0)
	_enemies.add_block(block)
	var id: int = _enemies.spawn(mole)
	# 60 px/s: dives at the fence after ~4.4 s, stays under for 2 s.
	for n: int in 55:
		_enemies.step(0.1)
	var i: int = _enemies.index_of(id)
	# Went under the fence: past it, fence untouched, hidden for a while.
	assert_float(_enemies.position_at(i).x).is_greater(300.0)
	assert_float(block.hp).is_equal(150.0)
	assert_bool(_enemies.is_hidden(i)).is_true()
	_enemies.damage(i, 999.0)
	assert_int(_enemies.index_of(id)).is_equal(i)
	assert_int(_enemies.find_nearest(_enemies.position_at(i), 50.0)).is_equal(-1)
	for n: int in 20:
		_enemies.step(0.1)
	assert_bool(_enemies.is_hidden(_enemies.index_of(id))).is_false()


func test_crow_flies_straight_over_fence() -> void:
	var crow: EnemyData = _data("crow")
	var block: RoadBlock = RoadBlock.new()
	block.progress = 300.0
	block.set_hp(150.0, 150.0)
	_enemies.add_block(block)
	var id: int = _enemies.spawn(crow)
	_enemies.step(1.0)
	var p: Vector2 = _enemies.position_at(_enemies.index_of(id))
	# Straight line from (0,0) to the road end (1000,1000).
	assert_float(p.x).is_equal_approx(p.y, 0.5)
	assert_float(p.length()).is_equal_approx(110.0, 1.0)
	var reached: Array[int] = [0]
	_enemies.reached_base.connect(func(_d: EnemyData) -> void: reached[0] += 1)
	for n: int in 20:
		_enemies.step(1.0)
	assert_int(reached[0]).is_equal(1)
	assert_float(block.hp).is_equal(150.0)


func test_boss_breaks_fence_in_two_hits_and_stuns_hero() -> void:
	var fox: EnemyData = _data("fox")
	var block: RoadBlock = RoadBlock.new()
	block.progress = 200.0
	block.set_hp(600.0, 600.0)
	_enemies.add_block(block)
	var hero: Node2D = auto_free(Node2D.new())
	add_child(hero)
	_enemies.hero = hero
	var struck: Array[int] = [0]
	_enemies.hero_struck.connect(func() -> void: struck[0] += 1)
	var id: int = _enemies.spawn(fox)
	hero.global_position = Vector2(2000, 2000)
	# Walk to the fence (~ 100 px at 35 px/s), then two strikes 1.5 s apart.
	for n: int in 45:
		_enemies.step(0.1)
	assert_bool(block.is_up()).is_true()
	for n: int in 20:
		_enemies.step(0.1)
	assert_bool(block.is_up()).is_false()
	hero.global_position = _enemies.position_at(_enemies.index_of(id)) + Vector2(50, 0)
	for n: int in 60:
		_enemies.step(0.1)
	assert_int(struck[0]).is_between(1, 2)
