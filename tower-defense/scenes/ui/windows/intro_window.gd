class_name IntroWindow
extends UiWindow
## "New defender!" / "New pest!" (design I, screens 10–11): the animated
## newcomer on a highlighted card, its name and a hint. One scene each;
## the battle pauses while it is open.

@onready var _defender: AnimatedSprite2D = %Defender
@onready var _pest: AnimatedSprite2D = %Pest
@onready var _name: Label = %Name
@onready var _text: Label = %Text
@onready var _ok: Button = %Ok
@onready var _big_defenders: SpriteFrames = _defender.sprite_frames


func _ready() -> void:
	super()
	_ok.pressed.connect(close)
	UiFx.press_spring(_ok)


func show_defender(data: DefenderData) -> void:
	_pest.visible = false
	_defender.visible = true
	# Big copies (art/frames/defenders_ui.tres, frame 256); the battle frames
	# for a defender that has none.
	if _big_defenders.has_animation(data.id):
		_defender.sprite_frames = _big_defenders
		_defender.play(data.id)
	else:
		_defender.sprite_frames = data.frames
		_defender.play(data.anim_at(1, "idle"))
	var frame: Texture2D = _defender.sprite_frames.get_frame_texture(_defender.animation, 0)
	var k: float = 280.0 / float(frame.get_height())
	_defender.scale = Vector2(k, k)
	_name.text = tr(data.name_key)
	_text.text = tr("DESC_" + String(data.id).to_upper())
	open()


func show_enemy(data: EnemyData) -> void:
	_defender.visible = false
	_pest.visible = true
	# Big copies (art/frames/pests_ui.tres): walk, the crow flies.
	_pest.play(data.id)
	# The pest fills about 3/4 of the 400 card whatever its frame size.
	var frame: Texture2D = _pest.sprite_frames.get_frame_texture(data.id, 0)
	var k: float = 300.0 / float(frame.get_height())
	_pest.scale = Vector2(k, k)
	_name.text = tr(data.name_key)
	_text.text = tr(data.hint_key)
	open()
