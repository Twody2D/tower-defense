extends Control
## Loading screen (design I, screen 1). The local save is already loaded by
## Save. Loads the main menu in the background (the bar shows it), waits for
## the SDK, takes the cloud save if it is ahead, takes the language from the
## SDK, calls LoadingAPI.ready and opens the menu.

@export_file("*.tscn") var next_scene: String = "res://scenes/ui/main_menu.tscn"
## Tip keys shown under the bar (portrait).
@export var tips: Array[String] = ["TIP_1", "TIP_2", "TIP_3", "TIP_4", "TIP_5"]
## The bar never jumps: it moves to the real progress at this speed, 1/s.
@export var bar_speed: float = 1.5

var _target: float = 0.0

@onready var _status: Label = %Status
@onready var _bar: TextureProgressBar = %Bar
@onready var _tip: Label = %Tip


func _ready() -> void:
	_bar.value = 0.0
	_show_progress()
	# The phone stress build (export preset "WebStress", feature "stress") opens the test at once.
	var scene: String = "res://dev/battle_stress.tscn" if OS.has_feature("stress") else next_scene
	ResourceLoader.load_threaded_request(scene)
	if not YandexSdk.is_initialized:
		await YandexSdk.initialized
	var cloud: Dictionary = await YandexSdk.load_cloud()
	Save.merge_cloud(cloud)
	# Language first, then every text on screen.
	I18n.apply_sdk_lang()
	_tip.text = tr(tips[randi() % tips.size()])
	var packed: PackedScene = await _wait_loaded(scene)
	_target = 1.0
	while _bar.value < 1.0:
		await get_tree().process_frame
	YandexSdk.ready_to_play()
	get_tree().change_scene_to_packed(packed)


func _process(delta: float) -> void:
	_bar.value = move_toward(_bar.value, _target, bar_speed * delta)
	_show_progress()


func _show_progress() -> void:
	_status.text = tr("LOADING") % roundi(_bar.value * 100.0)


func _wait_loaded(scene: String) -> PackedScene:
	var progress: Array = []
	while true:
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene, progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("boot: cannot load " + scene)
			break
		var p: float = progress[0] if not progress.is_empty() else 0.0
		_target = 0.9 * p
		await get_tree().process_frame
	return ResourceLoader.load_threaded_get(scene) as PackedScene
