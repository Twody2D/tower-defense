class_name IntroWindow
extends UiWindow
## "New defender!" / "New pest!" (design I, screens 10–11): the animated
## newcomer on a highlighted card, its name and a hint. One scene each;
## the battle pauses while it is open.

@onready var _defender: AnimatedSprite2D = %Defender
@onready var _pest: SheetSprite = %Pest
@onready var _name: Label = %Name
@onready var _text: Label = %Text
@onready var _ok: Button = %Ok


func _ready() -> void:
	super()
	_ok.pressed.connect(close)
	UiFx.press_spring(_ok)


func show_defender(data: DefenderData) -> void:
	_pest.visible = false
	_defender.visible = true
	_defender.sprite_frames = data.frames
	_defender.play(data.anim_at(1, "idle"))
	_name.text = tr(data.name_key)
	_text.text = tr("DESC_" + String(data.id).to_upper())
	open()


func show_enemy(data: EnemyData) -> void:
	_defender.visible = false
	_pest.visible = true
	_pest.atlas = data.atlas
	_pest.anim = &"walk" if data.atlas.row_of(&"walk") >= 0 else &"fly"
	# The pest fills about 3/4 of the 400 card whatever its frame size.
	var k: float = 300.0 / float(data.atlas.cell)
	_pest.scale = Vector2(k, k)
	_name.text = tr(data.name_key)
	_text.text = tr(data.hint_key)
	open()
