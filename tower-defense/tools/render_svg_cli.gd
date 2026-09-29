extends SceneTree
## Rasterises SVG sheets for tools/copy_art.py (big copies of heroes and
## pests for screens): "$G" --headless --path . -s res://tools/render_svg_cli.gd -- <list.json>
## The list: [{"src": "<svg path>", "scale": 3.0, "out": "<png path>"}, …].


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("render_svg: no list")
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	if not parsed is Array:
		push_error("render_svg: bad list " + args[0])
		quit(1)
		return
	var jobs: Array = parsed
	var failed: int = 0
	for item: Variant in jobs:
		var job: Dictionary = item
		var src: String = job["src"]
		var out: String = job["out"]
		var scale: float = job["scale"]
		var img: Image = Image.new()
		var err: Error = img.load_svg_from_buffer(FileAccess.get_file_as_bytes(src), scale)
		if err != OK or img.save_png(out) != OK:
			push_error("render_svg: failed " + src)
			failed += 1
	print("render_svg: %d sheets" % (jobs.size() - failed))
	quit(1 if failed > 0 else 0)
