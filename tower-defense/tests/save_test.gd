extends GdUnitTestSuite
## Save layout: Game ⇄ dictionary round trip, broken data, cloud merge.


func after_test() -> void:
	Game.reset()


func test_round_trip() -> void:
	Game.reset()
	Game.grains = 120
	Game.level_stars[0] = 3
	Game.level_stars[4] = 2
	Game.sound_on = false
	var d: Dictionary = Save.migrate(Game.to_dict())
	# JSON turns ints into floats: the save must survive that.
	var restored: Dictionary = JSON.parse_string(JSON.stringify(d))
	Game.reset()
	Game.from_dict(restored)
	assert_int(Game.grains).is_equal(120)
	assert_int(Game.total_stars()).is_equal(5)
	assert_bool(Game.sound_on).is_false()
	var version: int = d["version"]
	assert_int(version).is_equal(Save.SCHEMA_VERSION)


func test_broken_data_keeps_defaults() -> void:
	Game.from_dict({"grains": "lots", "level_stars": [9, -1, "x"], "music_on": 1})
	assert_int(Game.grains).is_equal(0)
	assert_array(Game.level_stars).has_size(Game.LEVEL_COUNT)
	assert_int(Game.level_stars[0]).is_equal(3)
	assert_int(Game.level_stars[1]).is_equal(0)
	assert_bool(Game.music_on).is_true()


func test_cloud_wins_only_when_ahead() -> void:
	Game.reset()
	Game.level_stars[0] = 2
	Save.merge_cloud({"level_stars": [1], "grains": 999})
	assert_int(Game.total_stars()).is_equal(2)
	assert_int(Game.grains).is_equal(0)
	Save.merge_cloud({"level_stars": [3, 3], "grains": 50})
	assert_int(Game.total_stars()).is_equal(6)
	assert_int(Game.grains).is_equal(50)
