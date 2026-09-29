extends Node
## Ad rules on top of YandexSdk. Fullscreen: only on "level → map" and not
## after the first levels (the SDK itself limits the frequency). Rewarded: the
## bonus is given only when the video was watched to the reward point.
## Amounts and limits: data/ad_rewards.tres (Game.ADS).

## A rewarded video is on screen (buttons wait for it).
var busy: bool = false

signal _rewarded_done(tag: StringName, ok: bool)


func _ready() -> void:
	YandexSdk.rewarded.connect(func(tag: StringName) -> void: _rewarded_done.emit(tag, true))
	YandexSdk.rewarded_failed.connect(func(tag: StringName) -> void: _rewarded_done.emit(tag, false))


## Called on the way from a finished level back to the farm map.
func on_level_exit(level: int) -> void:
	if level > Game.ADS.no_fullscreen_until_level:
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
