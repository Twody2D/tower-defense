extends Node
## Save: local file at once (user:// = localStorage on the web), cloud through
## YandexSdk. At boot the cloud save wins if it has more progress.

const PATH := "user://save.json"
## Tests (gdUnit4) reset and save the game a lot: their own file, so the
## progress of the game played on this PC stays.
const TEST_PATH := "user://save_test.json"
## Bump when the save layout changes; migrate() upgrades older saves.
const SCHEMA_VERSION := 1
## Cloud writes are spaced at least this far apart (the last change always
## goes out when the wait ends), s.
const CLOUD_EVERY := 3.0

var path: String = PATH
var _cloud_timer: Timer
var _cloud_pending: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_args():
		if arg.contains("gdUnit4"):
			path = TEST_PATH
	_cloud_timer = Timer.new()
	_cloud_timer.one_shot = true
	_cloud_timer.wait_time = CLOUD_EVERY
	_cloud_timer.timeout.connect(_on_cloud_timer)
	add_child(_cloud_timer)
	# The tab may be closed after it is hidden: send what waits at once.
	(func() -> void: YandexSdk.paused.connect(_on_cloud_timer)).call_deferred()
	load_local()


func load_local() -> void:
	var d: Dictionary = read_file(path)
	if not d.is_empty():
		Game.from_dict(migrate(d))


## Takes the cloud save if it is ahead of the local one (called from boot).
func merge_cloud(cloud: Dictionary) -> void:
	if cloud.is_empty():
		return
	var data: Dictionary = migrate(cloud)
	var local_score: int = Game.progress_score()
	var local: Dictionary = Game.to_dict()
	Game.from_dict(data)
	if Game.progress_score() < local_score:
		Game.from_dict(local)


func save() -> void:
	var d: Dictionary = Game.to_dict()
	d["version"] = SCHEMA_VERSION
	write_file(path, d)
	if _cloud_timer.is_stopped():
		YandexSdk.save_cloud(d)
		_cloud_timer.start()
	else:
		_cloud_pending = true


func _on_cloud_timer() -> void:
	if not _cloud_pending:
		return
	_cloud_pending = false
	var d: Dictionary = Game.to_dict()
	d["version"] = SCHEMA_VERSION
	YandexSdk.save_cloud(d)
	_cloud_timer.start()


## Upgrades an older save to SCHEMA_VERSION (nothing to do for v1 yet).
static func migrate(d: Dictionary) -> Dictionary:
	var out: Dictionary = d.duplicate(true)
	out["version"] = SCHEMA_VERSION
	return out


static func read_file(file: String) -> Dictionary:
	if not FileAccess.file_exists(file):
		return {}
	var text: String = FileAccess.get_file_as_string(file)
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	return {}


static func write_file(file: String, d: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(file, FileAccess.WRITE)
	if f == null:
		push_warning("save: cannot write %s" % file)
		return
	f.store_string(JSON.stringify(d))
