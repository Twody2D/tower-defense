extends GdUnitTestSuite
## SpatialHash finds the same items as a brute-force distance check.


func test_matches_brute_force() -> void:
	var h: SpatialHash = SpatialHash.new()
	h.setup(Rect2(0, 0, 1920, 1920))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	var n: int = 300
	var pos: PackedVector2Array = PackedVector2Array()
	var skip: PackedByteArray = PackedByteArray()
	for i: int in n:
		pos.append(Vector2(rng.randf_range(-50, 1970), rng.randf_range(-50, 1970)))
		skip.append(1 if i % 17 == 0 else 0)
	h.rebuild(pos, n, skip)
	for q: int in 50:
		var c: Vector2 = Vector2(rng.randf_range(0, 1920), rng.randf_range(0, 1920))
		var r: float = rng.randf_range(20, 300)
		var got: Array[int] = []
		for i: int in h.query(c, r):
			if pos[i].distance_to(c) <= r:
				got.append(i)
		var want: Array[int] = []
		for i: int in n:
			if skip[i] == 0 and pos[i].distance_to(c) <= r:
				want.append(i)
		got.sort()
		assert_array(got).is_equal(want)
