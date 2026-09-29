extends Node
## Single entry point to Yandex Games SDK. Picks a backend at startup:
## web export → PlatformYandex (works offline if the SDK did not load),
## editor and tests → PlatformMock. The rest of the game talks only to this node.

signal rewarded(tag: StringName)
signal rewarded_failed(tag: StringName)
## The game must pause now (ad on screen, SDK pause, tab lost focus).
signal paused
signal resumed
signal initialized

var backend: PlatformBase
## Backend init finished (boot waits for it).
var is_initialized: bool = false

var _unfocused: bool = false
var _hidden: bool = false
var _sdk_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.has_feature("web"):
		backend = PlatformYandex.new()
	else:
		backend = PlatformMock.new()
	add_child(backend)
	backend.rewarded.connect(rewarded.emit)
	backend.rewarded_failed.connect(rewarded_failed.emit)
	backend.paused.connect(_on_backend_paused)
	backend.resumed.connect(_on_backend_resumed)
	backend.hidden_changed.connect(_on_hidden_changed)
	backend.initialized.connect(_on_initialized, CONNECT_ONE_SHOT)
	backend.init()


## Tab or window lost focus: silence at once, ask the battle to pause.
## Sound comes back on focus; the battle stays paused until the player resumes.
## Web only: on the desktop (editor, dev screenshots) focus changes are ignored.
func _notification(what: int) -> void:
	if not OS.has_feature("web"):
		return
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_unfocused = true
		update_mute()
		paused.emit()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_unfocused = false
		update_mute()


## Master is silent while an ad is on screen, the tab is hidden or has no focus.
func update_mute() -> void:
	AudioServer.set_bus_mute(0, _unfocused or _hidden or _sdk_paused)


func ready_to_play() -> void:
	backend.ready_to_play()


func gameplay_start() -> void:
	backend.gameplay_start()


func gameplay_stop() -> void:
	backend.gameplay_stop()


func show_interstitial() -> void:
	backend.show_interstitial()


func show_rewarded(tag: StringName) -> void:
	backend.show_rewarded(tag)


func get_lang() -> String:
	return backend.get_lang()


## Cloud save ({} if none or unavailable). Use with await.
func load_cloud() -> Dictionary:
	var data: Dictionary = await backend.load_cloud()
	return data


func save_cloud(data: Dictionary) -> void:
	backend.save_cloud(data)


func _on_initialized() -> void:
	is_initialized = true
	initialized.emit()


func _on_backend_paused() -> void:
	_sdk_paused = true
	update_mute()
	paused.emit()


func _on_backend_resumed() -> void:
	_sdk_paused = false
	update_mute()
	resumed.emit()


## Tab hidden (visibilitychange): silent and paused like on focus loss.
func _on_hidden_changed(hidden: bool) -> void:
	_hidden = hidden
	update_mute()
	if hidden:
		paused.emit()
