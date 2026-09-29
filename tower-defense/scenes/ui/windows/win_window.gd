class_name WinWindow
extends UiWindow
## Victory (design I, screen 8): stars appear one by one, grain reward,
## "Reward ×2" for an ad, "Next" back to the map. The battle behind keeps
## the hero's joy and the confetti.

signal next

@onready var _stars: Array[AnimatedSprite2D] = [%Star1, %Star2, %Star3]
@onready var _amount: Label = %Amount
@onready var _double: AdButton = %Double
@onready var _next: Button = %Next

var _reward: int = 0


func _ready() -> void:
	super()
	_double.rewarded.connect(_on_double)
	_next.pressed.connect(func() -> void: next.emit())
	UiFx.press_spring(_next)


## Plays the stars (0.45 s apart, star_appear 12 FPS) and shows the reward.
func show_result(stars: int, reward: int) -> void:
	_reward = reward
	_amount.text = "+%d" % reward
	for s: AnimatedSprite2D in _stars:
		s.visible = false
	open()
	for i: int in stars:
		await get_tree().create_timer(0.3 + 0.15 * i, true, false, true).timeout
		_stars[i].visible = true
		_stars[i].play(&"star_appear")


func _on_double() -> void:
	Game.add_grains(_reward)
	Save.save()
	_amount.text = "+%d" % (_reward * 2)
	UiFx.bump(_amount, 1.4, 0.3)
	_double.disabled = true
