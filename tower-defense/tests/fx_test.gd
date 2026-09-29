extends GdUnitTestSuite
## FxPool: once effects and flying effects go back to the pool; a full pool
## skips effects instead of making new nodes.


func _pool(capacity: int) -> FxPool:
	var fx: FxPool = auto_free(FxPool.new())
	fx.frames = load("res://art/frames/fx.tres")
	fx.capacity = capacity
	add_child(fx)
	return fx


func test_once_effect_returns() -> void:
	var fx: FxPool = _pool(2)
	assert_object(fx.play(&"hit", Vector2(10, 10))).is_not_null()
	assert_int(fx.free_count()).is_equal(1)
	# fx_hit: 3 frames at 15 FPS = 0.2 s.
	await await_millis(500)
	assert_int(fx.free_count()).is_equal(2)


func test_full_pool_skips() -> void:
	var fx: FxPool = _pool(1)
	fx.play(&"poof", Vector2.ZERO)
	assert_object(fx.play(&"poof", Vector2.ZERO)).is_null()
	assert_object(fx.play(&"no_such_effect", Vector2.ZERO)).is_null()
	assert_int(fx.get_child_count()).is_equal(1)


func test_fly_returns_on_arrival() -> void:
	var fx: FxPool = _pool(1)
	fx.fly(&"coin_trail", Vector2.ZERO, Vector2(100, 0), 0.1)
	assert_int(fx.free_count()).is_equal(0)
	await await_millis(400)
	assert_int(fx.free_count()).is_equal(1)
