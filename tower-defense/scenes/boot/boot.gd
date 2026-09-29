extends Control
## Boot: the local save is already loaded by Save. Wait for the SDK, take the
## cloud save if it is ahead, take the language from the SDK, call
## LoadingAPI.ready and open the main menu.

@export_file("*.tscn") var next_scene: String = "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	if not YandexSdk.is_initialized:
		await YandexSdk.initialized
	var cloud: Dictionary = await YandexSdk.load_cloud()
	Save.merge_cloud(cloud)
	I18n.apply_sdk_lang()
	YandexSdk.ready_to_play()
	get_tree().change_scene_to_file.call_deferred(next_scene)
