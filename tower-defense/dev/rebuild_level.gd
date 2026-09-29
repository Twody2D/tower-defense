extends SceneTree
## Rebuilds ground and road tiles of a level scene (same as the "Rebuild
## ground and road" button in the inspector) and writes only the tile data
## and the snapped road points back into the .tscn text, so nothing else in
## the scene file changes.
## "$G" --headless --path . -s res://dev/rebuild_level.gd -- res://scenes/levels/level_01.tscn


func _initialize() -> void:
	var path: String = OS.get_cmdline_user_args()[0]
	var packed: PackedScene = load(path)
	var level: Node = packed.instantiate()
	level.call("rebuild")
	var text: String = FileAccess.get_file_as_string(path)
	var ground: TileMapLayer = level.get_node("Ground")
	text = _set_prop(text, '[node name="Ground"', "tile_map_data",
		'PackedByteArray("%s")' % Marshalls.raw_to_base64(ground.tile_map_data))
	for road: Node in level.get_node("Roads").get_children():
		var path2d: Path2D = road as Path2D
		if path2d == null:
			continue
		text = _set_curve(text, path2d)
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()
	print("rebuilt ", path)
	level.free()
	quit()


## Replaces (or adds after the header) `key = value` in the block that starts with `header`.
static func _set_prop(text: String, header: String, key: String, value: String) -> String:
	var start: int = text.find(header)
	if start < 0:
		push_error("no block " + header)
		return text
	var head_end: int = text.find("\n", start)
	var block_end: int = text.find("\n\n", head_end)
	if block_end < 0:
		block_end = text.length()
	var block: String = text.substr(head_end + 1, block_end - head_end - 1)
	var lines: PackedStringArray = block.split("\n", false)
	var out: PackedStringArray = PackedStringArray()
	var done: bool = false
	for line: String in lines:
		if line.begins_with(key + " = "):
			out.append("%s = %s" % [key, value])
			done = true
		else:
			out.append(line)
	if not done:
		out.insert(0, "%s = %s" % [key, value])
	return text.substr(0, head_end + 1) + "\n".join(out) + text.substr(block_end)


## Finds the Curve2D sub-resource of this road and rewrites its points.
static func _set_curve(text: String, road: Path2D) -> String:
	var node_at: int = text.find('[node name="%s" type="Path2D"' % road.name)
	var curve_at: int = text.find('curve = SubResource("', node_at)
	var id_start: int = curve_at + 'curve = SubResource("'.length()
	var id: String = text.substr(id_start, text.find('"', id_start) - id_start)
	var nums: PackedStringArray = PackedStringArray()
	var c: Curve2D = road.curve
	for i: int in c.point_count:
		for v: Vector2 in [c.get_point_in(i), c.get_point_out(i), c.get_point_position(i)]:
			nums.append(str(v.x))
			nums.append(str(v.y))
	var sub_at: int = text.find('[sub_resource type="Curve2D" id="%s"]' % id)
	var pts_at: int = text.find('"points": PackedVector2Array(', sub_at)
	var pts_end: int = text.find(")", pts_at)
	return text.substr(0, pts_at) + '"points": PackedVector2Array(%s' % ", ".join(nums) + text.substr(pts_end)
