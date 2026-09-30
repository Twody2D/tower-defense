extends GdUnitTestSuite
## Shop tutorial on the map after level 1: a hint on the Shop button, then
## on a buy button in the shop, done after the first upgrade.


func before_test() -> void:
	Game.reset()


func after_test() -> void:
	Game.reset()


func test_not_before_level_one() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/map/map.tscn")
	var tut: ShopTutorial = runner.find_child("ShopTutorial") as ShopTutorial
	await runner.simulate_frames(3)
	assert_bool(tut.active).is_false()
	assert_bool(tut.layer.visible).is_false()


func test_shop_hint_until_first_upgrade() -> void:
	Game.finish_level(1, 3)
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/map/map.tscn")
	var tut: ShopTutorial = runner.find_child("ShopTutorial") as ShopTutorial
	await runner.simulate_frames(3)
	assert_bool(tut.active).is_true()
	assert_bool(tut.layer.visible).is_true()
	runner.invoke("_open", runner.get_property("shop_window"))
	await runner.simulate_frames(30)
	assert_bool(tut.layer.visible).is_true()
	assert_bool(Game.buy_stat(&"damage")).is_true()
	await runner.simulate_frames(3)
	assert_bool(tut.active).is_false()
	assert_bool(tut.layer.visible).is_false()
	assert_bool(ShopTutorial.DONE in Game.seen).is_true()
