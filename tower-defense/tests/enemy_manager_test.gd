extends GdUnitTestSuite
## EnemyManager: walking the road, damage, defeat, swap-remove keeps ids right.

var _data: EnemyData


func before_test() -> void:
	_data = EnemyData.new()
	_data.hp = 12.0
	_data.speed = 100.0


func _make() -> EnemyManager:
	var curve: Curve2D = Curve2D.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1000, 0))
	var m: EnemyManager = auto_free(EnemyManager.new())
	m.lateral_spread = 0.0
	m.capacity = 16
	m.setup([curve] as Array[Curve2D], Rect2(-200, -200, 1400, 400))
	return m


func test_walks_and_reaches_base() -> void:
	var m: EnemyManager = _make()
	m.spawn(_data)
	var reached: Array[EnemyData] = []
	m.reached_base.connect(func(d: EnemyData) -> void: reached.append(d))
	m.step(5.0)
	assert_float(m.position_at(0).x).is_equal_approx(500.0, 1.0)
	m.step(5.1)
	assert_int(m.count).is_equal(0)
	assert_int(reached.size()).is_equal(1)


func test_damage_defeats_and_keeps_ids() -> void:
	var m: EnemyManager = _make()
	var a: int = m.spawn(_data)
	m.step(1.0)
	var b: int = m.spawn(_data)
	var c: int = m.spawn(_data)
	var defeated: Array[Vector2] = []
	m.defeated.connect(func(p: Vector2, _d: EnemyData) -> void: defeated.append(p))
	m.damage(m.index_of(a), 5.0)
	assert_int(m.count).is_equal(3)
	m.damage(m.index_of(a), 7.0)
	assert_int(m.count).is_equal(2)
	assert_int(defeated.size()).is_equal(1)
	assert_float(defeated[0].x).is_equal_approx(100.0, 1.0)
	assert_int(m.index_of(a)).is_equal(-1)
	# The last pest moved into the freed slot: ids still point at the right rows.
	assert_int(m.id_at(m.index_of(b))).is_equal(b)
	assert_int(m.id_at(m.index_of(c))).is_equal(c)


func test_find_nearest_in_radius() -> void:
	var m: EnemyManager = _make()
	m.spawn(_data)
	m.step(3.0)
	m.spawn(_data)
	assert_int(m.find_nearest(Vector2(290, 0), 50.0)).is_equal(m.index_of(1))
	assert_int(m.find_nearest(Vector2(600, 0), 50.0)).is_equal(-1)
	assert_int(m.find_in_radius(Vector2(150, 0), 200.0).size()).is_equal(2)


func test_capacity() -> void:
	var m: EnemyManager = _make()
	for i: int in 16:
		m.spawn(_data)
	assert_int(m.spawn(_data)).is_equal(0)
	assert_int(m.count).is_equal(16)
