extends GdUnitTestSuite
## Coins: magnet pick-up, lifetime, merging over the cap.


func _make(capacity: int = 150) -> Coins:
	var c: Coins = auto_free(Coins.new())
	c.capacity = capacity
	c.scatter = 0.0
	c._ready()
	return c


func test_magnet_picks_up() -> void:
	var c: Coins = _make()
	var got: Array[int] = [0]
	c.collected.connect(func(v: int) -> void: got[0] += v)
	c.drop(Vector2(100, 0), 3)
	c.step(0.1, Vector2(1000, 0), 120.0)
	assert_int(c.count).is_equal(3)
	for i: int in 60:
		c.step(1.0 / 60.0, Vector2(0, 0), 120.0)
	assert_int(c.count).is_equal(0)
	assert_int(got[0]).is_equal(3)


func test_coins_expire() -> void:
	var c: Coins = _make()
	c.drop(Vector2(0, 0), 2)
	c.step(14.9, Vector2(1000, 0), 120.0)
	assert_int(c.count).is_equal(2)
	c.step(0.2, Vector2(1000, 0), 120.0)
	assert_int(c.count).is_equal(0)


func test_merge_over_capacity_keeps_value() -> void:
	var c: Coins = _make(4)
	c.drop(Vector2(0, 0), 10)
	assert_int(c.count).is_equal(4)
	assert_int(c.total_value()).is_equal(10)
