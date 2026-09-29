class_name LoseWindow
extends UiWindow
## Defeat (design I, screen 9): sad hero, "Second chance" for an ad (+5
## carrots, the fight goes on; once per level), restart, to the map.

signal second_chance
signal restart
signal to_map

## Carrots given back by the second chance.
@export var chance_carrots: int = 5

@onready var _chance: AdButton = %Chance
@onready var _chance_line: Control = %ChanceLine
@onready var _chance_text: Label = %ChanceText
@onready var _restart: Button = %Restart
@onready var _to_map: Button = %ToMap
@onready var _hero: AnimatedSprite2D = %Hero


func _ready() -> void:
	super()
	_chance_text.text = tr("SECOND_CHANCE_TEXT") % chance_carrots
	_chance.rewarded.connect(func() -> void:
		visible = false
		second_chance.emit())
	_restart.pressed.connect(func() -> void: restart.emit())
	_to_map.pressed.connect(func() -> void: to_map.emit())
	UiFx.press_spring(_restart)
	UiFx.press_spring(_to_map)
	var skin: SkinData = Game.battle_skin()
	if skin != null:
		_hero.sprite_frames = skin.ui_frames
	_hero.play(&"sad")


## `chance_left`: the second chance was not used on this level yet.
func show_result(chance_left: bool) -> void:
	_chance.visible = chance_left
	_chance_line.visible = chance_left
	open()
