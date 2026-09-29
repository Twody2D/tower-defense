extends Node
## Ad rules on top of YandexSdk. Fullscreen: only on "level → map" and not
## after levels 1–2 (the SDK itself limits the frequency). Rewarded: the bonus
## is given only when the video was watched to the reward point.
## Reward amounts and limits (AdRewards.tres) come in stage 7.

## Levels after which no fullscreen is shown (the first minutes stay clean).
const NO_FULLSCREEN_UNTIL_LEVEL := 2

## A rewarded video is on screen (buttons wait for it).
var busy: bool = false

signal _rewarded_done(tag: StringName, ok: bool)


func _ready() -> void:
	YandexSdk.rewarded.connect(func(tag: StringName) -> void: _rewarded_done.emit(tag, true))
	YandexSdk.rewarded_failed.connect(func(tag: StringName) -> void: _rewarded_done.emit(tag, false))


## Called on the way from a finished level back to the farm map.
func on_level_exit(level: int) -> void:
	if level > NO_FULLSCREEN_UNTIL_LEVEL:
		YandexSdk.show_interstitial()


## Shows a rewarded video; true = watched, give the bonus. Use with await.
func show_rewarded(tag: StringName) -> bool:
	if busy:
		return false
	busy = true
	YandexSdk.show_rewarded(tag)
	var ok: bool = false
	while true:
		# A signal with several arguments resumes await with an Array of them.
		var result: Array = await _rewarded_done
		var got_tag: StringName = result[0]
		if got_tag == tag:
			ok = result[1]
			break
	busy = false
	return ok
