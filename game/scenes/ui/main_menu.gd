extends Control
## Main menu stub (stage 1): title and a disabled Play button.
## The real menu is built from the Claude Design mockups in stage 6.

@onready var _title: Label = %Title
@onready var _play: Button = %Play
@onready var _info: Label = %Info


func _ready() -> void:
	_title.text = tr("GAME_TITLE")
	_play.text = tr("BTN_PLAY")
	_info.text = "%s · %s" % [I18n.lang(), "web" if OS.has_feature("web") else "editor"]
