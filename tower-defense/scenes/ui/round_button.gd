@tool
class_name RoundButton
extends TextureButton
## Round icon button from the UI kit (96 or 112, icon 58%), optional red
## notification dot and a caption under it (design I: menu, map).
## `icon_anim`: an animated icon from art/frames/ui.tres (gift, harvest).

@export var icon: Texture2D:
	set(value):
		icon = value
		_refresh()
@export var icon_anim: StringName = &"":
	set(value):
		icon_anim = value
		_refresh()
@export var label_key: String = "":
	set(value):
		label_key = value
		_refresh()
@export var badge: bool = false:
	set(value):
		badge = value
		_refresh()
## Switched off (music, sound): the icon is crossed out (design O).
@export var off: bool = false:
	set(value):
		off = value
		_refresh()


func _ready() -> void:
	resized.connect(_refresh)
	_refresh()
	if not Engine.is_editor_hint():
		UiFx.press_spring(self)


func _refresh() -> void:
	if not is_node_ready():
		return
	var z: float = size.x
	var iz: float = z * 0.58
	var still: TextureRect = $Icon
	var anim: AnimatedSprite2D = $IconAnim
	still.visible = icon_anim == &""
	still.texture = icon
	still.position = Vector2((z - iz) * 0.5, z * 0.14)
	still.size = Vector2(iz, iz)
	anim.visible = icon_anim != &""
	if anim.visible:
		anim.play(icon_anim)
		anim.position = Vector2(z * 0.5, z * 0.14 + iz * 0.5)
		anim.scale = Vector2.ONE * (iz / 64.0)
	var slash: TextureRect = $Off
	slash.visible = off
	slash.position = still.position
	slash.size = still.size
	var dot: TextureRect = $Badge
	dot.visible = badge
	dot.position = Vector2(z - 30.0, -4.0)
	var caption: Label = $Caption
	caption.visible = label_key != ""
	caption.text = tr(label_key) if label_key != "" else ""
	caption.position = Vector2(-50.0, z + 4.0)
	caption.size = Vector2(z + 100.0, 40.0)
