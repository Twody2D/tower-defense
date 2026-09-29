@tool
extends EditorScript
## Editor: File → Run (Ctrl+Shift+X) with this script open. Builds
## SpriteFrames and enemy atlases from art/animations.json (see animation_import.gd).
## Command line: tools/import_animations_cli.gd.

const Importer = preload("res://tools/animation_import.gd")


func _run() -> void:
	Importer.run()
	EditorInterface.get_resource_filesystem().scan()
