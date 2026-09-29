extends Control
## Main menu stub: title and Play. The real menu is built from the
## Claude Design mockups in stage 6.

@export_file("*.tscn") var battle_scene: String = "res://scenes/battle/battle.tscn"

@onready var _title: Label = %Title
@onready var _play: Button = %Play
@onready var _info: Label = %Info


func _ready() -> void:
	_title.text = tr("GAME_TITLE")
	_play.text = tr("BTN_PLAY")
	_info.text = "%s · %s" % [I18n.lang(), "web" if OS.has_feature("web") else "editor"]
	_play.pressed.connect(_on_play)
	_play.grab_focus()


func _on_play() -> void:
	get_tree().change_scene_to_file(battle_scene)
