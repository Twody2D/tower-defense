extends GdUnitTestSuite
## Defender kinds on a straight test road: one target, slow area, splash,
## damage over time, flying filter; fence blocks, breaks and gets repaired.

var _enemies: EnemyManager
var _projectiles: Projectiles


func before_test() -> void:
	var curve: Curve2D = Curve2D.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(3000, 0))
	_enemies = auto_free(EnemyManager.new())
	_enemies.lateral_spread = 0.0
	_enemies.frames_shader = load("res://shaders/enemy_frames.gdshader")
	_enemies.setup(curve)
	add_child(_enemies)
	_projectiles = auto_free(Projectiles.new())
	_projectiles.projectile_scene = load("res://scenes/battle/projectile.tscn")
	_projectiles.enemies = _enemies
	add_child(_projectiles)


## A pest standing still at `x` on the road.
func _pest(x: float, file: String = "beetle", hp: float = 1000.0, speed: float = 0.0) -> int:
	var d: EnemyData = (load("res://data/enemies/%s.tres" % file) as EnemyData).duplicate()
	d.hp = hp
	d.speed = speed
	var id: int = _enemies.spawn(d)
	_enemies.step(0.0)
	var i: int = _enemies.index_of(id)
	_enemies._progress[i] = x
	_enemies._place(i)
	return id


func _defender(file: String, level: int, at: Vector2) -> Defender:
	var scene: PackedScene = load("res://scenes/battle/defender.tscn")
	var d: Defender = auto_free(scene.instantiate())
	d.data = load("res://data/defenders/%s.tres" % file)
	d.enemies = _enemies
	d.projectiles = _projectiles
	d.position = at
	add_child(d)
	d.set_level(level)
	return d


func _hp(id: int) -> float:
	return _enemies.hp_at(_enemies.index_of(id))


func _wait(seconds: float) -> void:
	await await_millis(int(seconds * 1000.0))


func test_goose_hits_one_target() -> void:
	var near: int = _pest(100)
	var far: int = _pest(160)
	_defender("goose", 1, Vector2(100, -100))
	await _wait(1.2)
	assert_float(_hp(near)).is_less(1000.0)
	assert_float(_hp(far)).is_equal(1000.0)


func test_sprinkler_slows_everyone_in_range() -> void:
	var a: int = _pest(100)
	var b: int = _pest(150)
	var out: int = _pest(600)
	_defender("frog", 1, Vector2(120, -60))
	await _wait(0.3)
	assert_bool(_enemies.is_slowed(_enemies.index_of(a))).is_true()
	assert_bool(_enemies.is_slowed(_enemies.index_of(b))).is_true()
	assert_bool(_enemies.is_slowed(_enemies.index_of(out))).is_false()
	assert_float(_hp(a)).is_less(1000.0)


func test_slowed_pest_walks_slower() -> void:
	var slow_id: int = _pest(0, "beetle", 1000.0, 100.0)
	_enemies.apply_slow(_enemies.index_of(slow_id), 0.4, 10.0)
	var before: float = _enemies._progress[_enemies.index_of(slow_id)]
	_enemies.step(1.0)
	assert_float(_enemies._progress[_enemies.index_of(slow_id)] - before).is_equal_approx(60.0, 0.5)


func test_tomato_splash_hits_the_crowd() -> void:
	var a: int = _pest(200)
	var b: int = _pest(230)
	var out: int = _pest(400)
	_defender("beaver", 1, Vector2(200, -150))
	await _wait(1.5)
	assert_float(_hp(a)).is_less(1000.0)
	assert_float(_hp(b)).is_less(1000.0)
	assert_float(_hp(out)).is_equal(1000.0)


func test_hive_damage_over_time() -> void:
	var a: int = _pest(100)
	_defender("hive", 1, Vector2(100, -100))
	await _wait(1.0)
	var after_sting: float = _hp(a)
	assert_float(after_sting).is_less(1000.0)
	await _wait(1.0)
	assert_float(_hp(a)).is_less(after_sting)


func test_only_goose_and_hive_hit_crows() -> void:
	var crow: int = _pest(100, "crow")
	_defender("frog", 3, Vector2(100, -50))
	_defender("beaver", 3, Vector2(100, -50))
	await _wait(2.0)
	assert_float(_hp(crow)).is_equal(1000.0)
	_defender("goose", 1, Vector2(100, -50))
	await _wait(1.0)
	assert_float(_hp(crow)).is_less(1000.0)


func test_level_growth() -> void:
	var goose: DefenderData = load("res://data/defenders/goose.tres")
	assert_float(goose.damage_at(2)).is_equal_approx(12.0, 0.01)
	assert_float(goose.damage_at(3)).is_equal_approx(16.0, 0.01)
	assert_float(goose.radius_at(3)).is_equal_approx(264.0, 0.01)


func test_fence_blocks_breaks_and_repairs() -> void:
	var scene: PackedScene = load("res://scenes/battle/fence.tscn")
	var fence: Fence = auto_free(scene.instantiate())
	fence.data = load("res://data/defenders/fence.tres")
	fence.position = Vector2(500, 0)
	add_child(fence)
	fence.attach(_enemies)
	fence.set_level(1)
	assert_float(fence.block.hp).is_equal(150.0)
	var id: int = _pest(300, "beetle", 1000.0, 200.0)
	# Walks up to the fence and stops in front of it, chewing.
	for n: int in 60:
		_enemies.step(0.05)
	var x: float = _enemies.position_at(_enemies.index_of(id)).x
	assert_float(x).is_less(500.0)
	assert_float(fence.block.hp).is_less(150.0)
	fence.repair(1000.0)
	assert_float(fence.block.hp).is_equal(150.0)
	var destroyed: Array[bool] = [false]
	fence.destroyed.connect(func() -> void: destroyed[0] = true)
	fence.block.hit(1000.0)
	assert_bool(destroyed[0]).is_true()
	assert_int(fence.level).is_equal(0)
	# Broken fence no longer blocks.
	for n: int in 20:
		_enemies.step(0.05)
	assert_float(_enemies.position_at(_enemies.index_of(id)).x).is_greater(500.0)
