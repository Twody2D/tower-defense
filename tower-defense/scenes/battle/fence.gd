class_name Fence
extends Node2D
## Fence on a road plot. Blocks walking pests through a RoadBlock; the sprite
## frame shows the damage (whole / cracked / broken, design D damage_3f).
## At 0 HP it is destroyed and the plot is free again.

signal destroyed

var data: DefenderData
var level: int = 0
var block: RoadBlock = RoadBlock.new()

@onready var _sprite: Sprite2D = $Sprite
@onready var _stars: Sprite2D = $Stars

@export var star_textures: Array[Texture2D] = []


func _ready() -> void:
	block.hp_changed.connect(_on_hp_changed)
	block.broken.connect(_on_broken)
	set_level(level)


## Registers the fence on the road at the plot position.
func attach(enemies: EnemyManager) -> void:
	block.progress = enemies.progress_of(global_position)
	enemies.add_block(block)


func set_level(new_level: int) -> void:
	level = new_level
	visible = level > 0
	if level <= 0 or data == null:
		block.set_hp(0.0, 0.0)
		return
	_sprite.texture = data.idle_sheet(level)
	_sprite.hframes = data.idle_frames
	_stars.texture = star_textures[clampi(level - 1, 0, star_textures.size() - 1)]
	block.set_hp(data.fence_hp_at(level), data.fence_hp_at(level))


func is_damaged() -> bool:
	return level > 0 and block.hp < block.max_hp


## Share of HP missing (0 = whole, 1 = broken).
func missing_share() -> float:
	if block.max_hp <= 0.0:
		return 0.0
	return 1.0 - block.hp / block.max_hp


func repair(hp: float) -> void:
	block.set_hp(block.hp + hp, block.max_hp)


func _on_hp_changed(hp: float) -> void:
	if level <= 0:
		return
	var share: float = hp / block.max_hp if block.max_hp > 0.0 else 0.0
	_sprite.frame = 0 if share > 0.66 else (1 if share > 0.33 else 2)


func _on_broken() -> void:
	set_level(0)
	destroyed.emit()
