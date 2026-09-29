extends GdUnitTestSuite
## Floating joystick: appears under the finger, direction is clamped, release resets.


func test_touch_drag_release() -> void:
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/ui/joystick.tscn")
	var joy: Joystick = runner.scene() as Joystick
	var dirs: Array[Vector2] = []
	joy.changed.connect(func(d: Vector2) -> void: dirs.append(d))

	var down: InputEventScreenTouch = InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = Vector2(200, 300)
	joy._input(down)
	var base: TextureRect = joy.get_node("Base")
	assert_bool(base.visible).is_true()

	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(400, 300)
	joy._input(drag)
	assert_vector(joy.dir).is_equal_approx(Vector2(1, 0), Vector2(0.01, 0.01))

	# A second finger does not steal the stick.
	var other: InputEventScreenTouch = InputEventScreenTouch.new()
	other.index = 1
	other.pressed = true
	other.position = Vector2(600, 100)
	joy._input(other)
	assert_vector(joy.dir).is_equal_approx(Vector2(1, 0), Vector2(0.01, 0.01))

	var up: InputEventScreenTouch = InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	joy._input(up)
	assert_vector(joy.dir).is_equal(Vector2.ZERO)
	assert_bool(base.visible).is_false()
	assert_int(dirs.size()).is_equal(2)
