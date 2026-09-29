extends Node
## Player progress and settings. Save turns it into a dictionary and back;
## the rest of the game reads and changes it only here.

signal settings_changed
signal progress_changed

## Levels in the campaign (farm map).
const LEVEL_COUNT := 12

var music_on: bool = true
var sound_on: bool = true
## Stars per level (0..3), index 0 = level 1.
var level_stars: Array[int] = []
## Meta currency (golden grains).
var grains: int = 0


func _init() -> void:
	reset()


func reset() -> void:
	music_on = true
	sound_on = true
	grains = 0
	level_stars.clear()
	level_stars.resize(LEVEL_COUNT)
	level_stars.fill(0)


func total_stars() -> int:
	var total: int = 0
	for s: int in level_stars:
		total += s
	return total


## Progress score to pick the fresher save (local vs cloud).
func progress_score() -> int:
	return total_stars()


func set_sound(on: bool) -> void:
	sound_on = on
	settings_changed.emit()


func set_music(on: bool) -> void:
	music_on = on
	settings_changed.emit()


func to_dict() -> Dictionary:
	return {
		"music_on": music_on,
		"sound_on": sound_on,
		"level_stars": level_stars.duplicate(),
		"grains": grains,
	}


## Missing or broken keys keep their defaults (old or damaged saves still load).
func from_dict(d: Dictionary) -> void:
	reset()
	var music: Variant = d.get("music_on", music_on)
	if music is bool:
		music_on = music
	var sound: Variant = d.get("sound_on", sound_on)
	if sound is bool:
		sound_on = sound
	var g: Variant = d.get("grains", grains)
	if g is float or g is int:
		var gf: float = g
		grains = maxi(int(gf), 0)
	var stars: Variant = d.get("level_stars", [])
	if stars is Array:
		var arr: Array = stars
		for i: int in mini(arr.size(), LEVEL_COUNT):
			var v: Variant = arr[i]
			if v is float or v is int:
				var vf: float = v
				level_stars[i] = clampi(int(vf), 0, 3)
	settings_changed.emit()
	progress_changed.emit()
