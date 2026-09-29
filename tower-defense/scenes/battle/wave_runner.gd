class_name WaveRunner
extends Node
## Runs the level waves: a countdown break, then the wave groups spawn in
## parallel; after the last pest of a wave is out, the next break starts.
## "Call now" ends the break at once for +1 coin per second left.

signal wave_started(number: int, total: int)
## Every wave is out (the battle wins when the field is clear too).
signal all_spawned

var level: LevelData
var enemies: EnemyManager
## Current wave number, 1-based; 0 before the first one.
var wave: int = 0
## Seconds left in the break (0 while a wave is spawning).
var break_left: float = 0.0

var _spawning: bool = false
var _done: bool = false
var _time: float = 0.0
## Pests already spawned per group of the current wave.
var _spawned: PackedInt32Array = PackedInt32Array()


func start(level_data: LevelData, pests: EnemyManager) -> void:
	level = level_data
	enemies = pests
	wave = 0
	_done = level.waves.is_empty()
	_spawning = false
	break_left = level.first_pause
	if _done:
		all_spawned.emit.call_deferred()


func total() -> int:
	return level.waves.size()


func is_done() -> bool:
	return _done


func in_break() -> bool:
	return not _spawning and not _done


## Skips the break; returns the coin bonus (+1 per whole second left).
func call_now() -> int:
	if not in_break():
		return 0
	var bonus: int = int(ceilf(break_left))
	break_left = 0.0
	_start_wave()
	return bonus


func _process(delta: float) -> void:
	if _done or level == null:
		return
	if not _spawning:
		break_left -= delta
		if break_left <= 0.0:
			break_left = 0.0
			_start_wave()
		return
	_time += delta
	var data: WaveData = level.waves[wave - 1]
	var finished: bool = true
	for g: int in data.groups.size():
		var group: WaveGroup = data.groups[g]
		while _spawned[g] < group.count and _time >= group.delay + group.interval * float(_spawned[g]):
			enemies.spawn(group.enemy, level.hp_multiplier() * group.hp_scale, group.road)
			_spawned[g] += 1
		if _spawned[g] < group.count:
			finished = false
	if finished:
		_spawning = false
		if wave >= total():
			_done = true
			all_spawned.emit()
		else:
			break_left = level.wave_pause


func _start_wave() -> void:
	wave += 1
	_spawning = true
	_time = 0.0
	_spawned.resize(level.waves[wave - 1].groups.size())
	_spawned.fill(0)
	wave_started.emit(wave, total())
