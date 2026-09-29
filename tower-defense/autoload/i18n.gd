extends Node
## Language: taken once at boot from the SDK (environment.i18n.lang).
## No in-game switch and not stored in the save (Yandex requirement 2.14).

const LANGS: Array[String] = ["ru", "en"]


func apply_sdk_lang() -> void:
	var lang: String = YandexSdk.get_lang()
	TranslationServer.set_locale(lang if lang in LANGS else "ru")


func lang() -> String:
	return TranslationServer.get_locale().substr(0, 2)
