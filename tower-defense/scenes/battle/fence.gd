class_name Fence
extends Node2D
## Fence on a road plot. Blocks walking pests through a RoadBlock.
## Animations (DefenderData.frames = art/frames/fence.tres): build on a new
## level, then one of 3 damage states by HP (whole / cracked / broken);
## a shake (hit) when pests hurt it, repair on every repair coin, destroy at
## 0 HP — then it is gone and the plot is free again.

signal destroyed

## While pests chew, the hit shake plays at most this often, s.
@export var hit_every: float = 0.5
@export var star_textures: Array[Texture2D] = []

var data: DefenderData
var level: int = 0
var block: RoadBlock = RoadBlock.new()

var _last_hp: float = 0.0
var _hit_cd: float = 0.0
## The destroy animation is still playing (the fence is already down).
var _destroying: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _stars: Sprite2D = $Stars


func _ready() -> void:
	block.hp_changed.connect(_on_hp_changed)
	block.broken.connect(_on_broken)
	_sprite.animation_finished.connect(_on_animation_finished)
	set_level(level)


func _process(delta: float) -> void:
	_hit_cd = maxf(_hit_cd - delta, 0.0)


## Registers the fence on the road at the plot position.
func attach(enemies: EnemyManager) -> void:
	block.road = enemies.nearest_road(global_position)
	block.progress = enemies.progress_of(global_position, block.road)
	enemies.add_block(block)


func set_level(new_level: int) -> void:
	var old: int = level
	level = new_level
	if level <= 0 or data == null:
		block.set_hp(0.0, 0.0)
		visible = _destroying
		return
	_destroying = false
	visible = true
	_sprite.sprite_frames = data.frames
	_stars.visible = true
	_stars.texture = star_textures[clampi(level - 1, 0, star_textures.size() - 1)]
	block.set_hp(data.fence_hp_at(level), data.fence_hp_at(level))
	if old != level:
		_sprite.play(data.anim_at(level, "build"))
	else:
		_show_state()


func is_damaged() -> bool:
	return level > 0 and block.hp < block.max_hp


## Share of HP missing (0 = whole, 1 = broken).
func missing_share() -> float:
	if block.max_hp <= 0.0:
		return 0.0
	return 1.0 - block.hp / block.max_hp


func repair(hp: float) -> void:
	block.set_hp(block.hp + hp, block.max_hp)
	if level > 0 and not _sprite.is_playing():
		_sprite.play(data.anim_at(level, "repair"))


func _on_hp_changed(hp: float) -> void:
	var hurt: bool = hp < _last_hp
	_last_hp = hp
	if level <= 0 or _sprite.is_playing():
		return
	if hurt and _hit_cd <= 0.0:
		_hit_cd = hit_every
		_sprite.play(data.anim_at(level, "hit"))
		return
	_show_state()


## Damage state frame by HP (static, not played).
func _show_state() -> void:
	var share: float = block.hp / block.max_hp if block.max_hp > 0.0 else 0.0
	_sprite.animation = data.anim_at(level, "damage")
	_sprite.frame = 0 if share > 0.66 else (1 if share > 0.33 else 2)


func _on_animation_finished() -> void:
	if _destroying:
		_destroying = false
		visible = false
		return
	if level > 0:
		_show_state()


func _on_broken() -> void:
	_destroying = true
	_stars.visible = false
	_sprite.play(data.anim_at(level, "destroy"))
	set_level(0)
	destroyed.emit()
