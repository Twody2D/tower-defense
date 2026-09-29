extends SceneTree
## "$G" --headless --path . -s res://tools/import_animations_cli.gd
## Run --import first so new sheets from tools/copy_art.py are imported.

const Importer = preload("res://tools/animation_import.gd")


func _init() -> void:
	quit(Importer.run())
