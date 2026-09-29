extends Node
## Save: local file at once (user:// = localStorage on the web), cloud through
## YandexSdk. At boot the cloud save wins if it has more progress.

const PATH := "user://save.json"
## Bump when the save layout changes; migrate() upgrades older saves.
const SCHEMA_VERSION := 1
## Cloud writes are spaced at least this far apart (the last change always
## goes out when the wait ends), s.
const CLOUD_EVERY := 3.0

var _cloud_timer: Timer
var _cloud_pending: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cloud_timer = Timer.new()
	_cloud_timer.one_shot = true
	_cloud_timer.wait_time = CLOUD_EVERY
	_cloud_timer.timeout.connect(_on_cloud_timer)
	add_child(_cloud_timer)
	# The tab may be closed after it is hidden: send what waits at once.
	(func() -> void: YandexSdk.paused.connect(_on_cloud_timer)).call_deferred()
	load_local()


func load_local() -> void:
	var d: Dictionary = read_file(PATH)
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
	write_file(PATH, d)
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


static func read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	return {}


static func write_file(path: String, d: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_warning("save: cannot write %s" % path)
		return
	f.store_string(JSON.stringify(d))
