extends RefCounted
## Reads art/animations.json (written by tools/copy_art.py) and makes:
## - art/frames/<set>.tres — SpriteFrames (hero skins, defenders, fence, FX,
##   decor, projectiles), one animation per manifest entry, frames cut from
##   the one-row sheet by AtlasTexture regions;
## - art/enemies/atlas_<pest>.tres — EnemyAtlas for the MultiMesh horde.
## Existing files are refilled in place, so their UIDs and links stay.
## Run from the editor (import_animations.gd) or the command line
## (import_animations_cli.gd).

const MANIFEST: String = "res://art/animations.json"
const FRAMES_DIR: String = "res://art/frames"


static func run() -> int:
	var text: String = FileAccess.get_file_as_string(MANIFEST)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("Bad manifest " + MANIFEST)
		return ERR_PARSE_ERROR
	var manifest: Dictionary = parsed
	DirAccess.make_dir_recursive_absolute(FRAMES_DIR)
	var made: int = 0
	var sets: Dictionary = manifest["frames"]
	for set_name: String in sets:
		var anims: Dictionary = sets[set_name]
		if _save_frames(set_name, anims) != OK:
			return FAILED
		made += 1
	var atlases: Dictionary = manifest["atlases"]
	for pest: String in atlases:
		var info: Dictionary = atlases[pest]
		if _save_atlas(pest, info) != OK:
			return FAILED
		made += 1
	print("import_animations: %d resources" % made)
	return OK


static func _save_frames(set_name: String, anims: Dictionary) -> Error:
	var path: String = "%s/%s.tres" % [FRAMES_DIR, set_name]
	var sf: SpriteFrames = null
	if ResourceLoader.exists(path):
		sf = load(path) as SpriteFrames
	if sf == null:
		sf = SpriteFrames.new()
	for old: StringName in sf.get_animation_names():
		if old != &"default":
			sf.remove_animation(old)
	for anim: String in anims:
		var e: Dictionary = anims[anim]
		var file: String = e["file"]
		var sheet: Texture2D = load(file) as Texture2D
		if sheet == null:
			push_error("Missing " + file)
			return ERR_FILE_NOT_FOUND
		# JSON numbers are floats.
		var frames_f: float = e["frames"]
		var n: int = int(frames_f)
		var fps: float = e["fps"]
		var loop: bool = e["loop"]
		var w: float = float(sheet.get_width()) / float(n)
		var h: float = float(sheet.get_height())
		sf.add_animation(anim)
		sf.set_animation_speed(anim, fps if fps > 0.0 else 1.0)
		sf.set_animation_loop(anim, loop)
		for f: int in n:
			var at: AtlasTexture = AtlasTexture.new()
			at.atlas = sheet
			at.region = Rect2(w * f, 0.0, w, h)
			sf.add_frame(anim, at)
	# "default" only stays if the set has nothing else (SpriteFrames needs one).
	if sf.has_animation(&"default") and sf.get_animation_names().size() > 1:
		sf.remove_animation(&"default")
	return ResourceSaver.save(sf, path)


static func _save_atlas(pest: String, info: Dictionary) -> Error:
	var path: String = "res://art/enemies/atlas_%s.tres" % pest
	var atlas: EnemyAtlas = null
	if ResourceLoader.exists(path):
		atlas = load(path) as EnemyAtlas
	if atlas == null:
		atlas = EnemyAtlas.new()
	var file: String = info["file"]
	atlas.texture = load(file) as Texture2D
	if atlas.texture == null:
		push_error("Missing " + file)
		return ERR_FILE_NOT_FOUND
	var cell: float = info["cell"]
	var columns: float = info["columns"]
	atlas.cell = int(cell)
	atlas.columns = int(columns)
	var anims: Dictionary = info["anims"]
	var count: int = anims.size()
	var names: Array[StringName] = []
	names.resize(count)
	atlas.frames.resize(count)
	atlas.fps.resize(count)
	atlas.loops.resize(count)
	for anim: String in anims:
		var e: Dictionary = anims[anim]
		var row_f: float = e["row"]
		var frames_f: float = e["frames"]
		var fps: float = e["fps"]
		var loop: bool = e["loop"]
		var row: int = int(row_f)
		names[row] = StringName(anim)
		atlas.frames[row] = int(frames_f)
		atlas.fps[row] = fps
		atlas.loops[row] = 1 if loop else 0
	atlas.anims = names
	return ResourceSaver.save(atlas, path)
