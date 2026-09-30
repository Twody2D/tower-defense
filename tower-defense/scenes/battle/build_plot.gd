class_name BuildPlot
extends Node2D
## Build plot (design E: pad 128×96, progress ring, price tag).
## Empty plot: the hero steps on → `menu_requested` (the battle shows the
## radial menu, the game goes on; stepping off → `hero_left` closes it) → a
## defender is chosen → after `start_delay` on the plot coins go in one by
## one (`coin_interval`) up to its price → it is built. Standing again
## upgrades it up to level 3. Coins only start going in when the hero can pay
## the whole level; stepping off before it is done gives them back (Twody:
## running past must not spend anything). The choice can change while
## nothing is paid.
## Fence plot (on the road): only the fence; a damaged fence is repaired for
## coins (a full repair = `repair_price_share` of the level price).

signal menu_requested(plot: BuildPlot)
signal hero_left(plot: BuildPlot)
signal built(plot: BuildPlot, level: int)
signal coin_paid(plot: BuildPlot)

## Fence plot: sits on the road, builds only `fence_data`.
@export var fence_plot: bool = false
@export var fence_data: DefenderData
## Not available on this level (grey pad with a lock).
@export var locked: bool = false
## Rhombus half-size (pad 128×96), px.
@export var half_size: Vector2 = Vector2(64, 48)
## One coin goes into the plot every this many seconds (CODE_PROMPT: 0.05).
@export var coin_interval: float = 0.05
## The hero has to stand on the plot this long before coins go in, s.
@export var start_delay: float = 0.35
## A built defender is solid (the hero cannot walk into it), so the hero
## upgrades it from next to it: the plot area becomes an ellipse with these
## half-axes, px (the solid part is only the tower's legs).
@export var built_reach: Vector2 = Vector2(150, 115)
@export var pad_normal: Texture2D
@export var pad_max: Texture2D
@export var pad_locked: Texture2D

## Defenders the player may pick here (the battle sets it from LevelData).
var options: Array[DefenderData] = []
var chosen: DefenderData
var level: int = 0
var paid: int = 0
var hero: Hero
var state: BattleState

var _timer: float = 0.0
var _hero_on: bool = false
var _on_time: float = 0.0
var _repair_paid: int = 0

@onready var defender: Defender = $Defender
@onready var fence: Fence = $Fence
@onready var _pad: Sprite2D = $Pad
@onready var _highlight: AnimatedSprite2D = $Highlight
@onready var _ring: TextureProgressBar = $Ring
@onready var _price: Node2D = $Price
@onready var _price_label: Label = $Price/Label
@onready var _block: CollisionShape2D = $Block/Shape


func _ready() -> void:
	defender.visible = false
	fence.visible = false
	if fence_plot:
		chosen = fence_data
		fence.data = fence_data
		fence.destroyed.connect(_on_fence_destroyed)
	_refresh()


## Called by the battle once the pests exist (fences register on the road).
func attach(enemies: EnemyManager, projectiles: Projectiles, fx: FxPool = null) -> void:
	defender.enemies = enemies
	defender.projectiles = projectiles
	defender.fx = fx
	if fence_plot:
		fence.attach(enemies)


func is_max() -> bool:
	return chosen != null and level >= chosen.max_level()


## Coins still needed for the next level (0 when maxed or nothing chosen).
func next_price() -> int:
	if chosen == null or is_max():
		return 0
	return chosen.price(level + 1)


func contains(world_pos: Vector2) -> bool:
	var d: Vector2 = (world_pos - global_position).abs()
	if level > 0 and not fence_plot:
		# Built: the tower stands in the way, so anywhere around it counts.
		return (d / built_reach).length_squared() <= 1.0
	return d.x / half_size.x + d.y / half_size.y <= 1.0


## Level start boost: a defender already standing at `at_level`.
func prebuild(data: DefenderData, at_level: int) -> void:
	choose(data)
	level = at_level
	paid = 0
	defender.set_level(at_level)
	_refresh()


func can_free_upgrade() -> bool:
	return not locked and not fence_plot and level > 0 and not is_max()


## Parcel bonus: a built defender goes one level up for free (the coins paid
## towards the next level go back to the hero). False if nothing to raise.
func free_upgrade() -> bool:
	if not can_free_upgrade():
		return false
	_refund()
	level += 1
	defender.set_level(level)
	built.emit(self, level)
	_refresh()
	return true


## Radial menu answer. Changing the pick is allowed while nothing is paid.
func choose(data: DefenderData) -> void:
	if level > 0 or paid > 0:
		return
	chosen = data
	defender.data = data
	_timer = coin_interval
	_refresh()


func _process(delta: float) -> void:
	if locked:
		return
	var on: bool = hero != null and contains(hero.global_position) and not hero.is_stunned()
	if on != _hero_on:
		_hero_on = on
		_highlight.visible = on
		_timer = coin_interval
		_on_time = 0.0
		if on and not fence_plot and level == 0 and paid == 0:
			menu_requested.emit(self)
		if not on:
			_refund()
			hero_left.emit(self)
	if not on:
		return
	_on_time += delta
	if _on_time < start_delay:
		return
	_timer -= delta
	while _timer <= 0.0:
		_timer += coin_interval
		if not _pay_one():
			_timer = coin_interval
			break
		hero.mark_building()


## One coin into the plot: towards the next level or a fence repair.
func _pay_one() -> bool:
	if fence_plot and fence.is_damaged():
		return _repair_one()
	if chosen == null or is_max():
		return false
	# A level starts only if the hero can pay all of it.
	if paid == 0 and state.coins < next_price():
		return false
	if not state.spend(1):
		return false
	paid += 1
	coin_paid.emit(self)
	if paid >= next_price():
		paid = 0
		level += 1
		if fence_plot:
			fence.set_level(level)
		else:
			defender.set_level(level)
		built.emit(self, level)
	_refresh()
	return true


## Unfinished level: the coins go back to the hero.
func _refund() -> void:
	if paid <= 0:
		return
	state.add_coins(paid)
	paid = 0
	_refresh()


func _repair_one() -> bool:
	var full_cost: int = maxi(ceili(chosen.price(level) * chosen.repair_price_share), 1)
	if not state.spend(1):
		return false
	coin_paid.emit(self)
	fence.repair(fence.block.max_hp / float(full_cost))
	_refresh()
	return true


func _on_fence_destroyed() -> void:
	level = 0
	paid = 0
	_refresh()


func _refresh() -> void:
	if locked:
		_pad.texture = pad_locked
		_ring.visible = false
		_price.visible = false
		return
	_pad.texture = pad_max if is_max() else pad_normal
	# Deferred: _refresh may run inside a physics callback.
	_block.set_deferred(&"disabled", level == 0 or fence_plot)
	var price: int = next_price()
	_ring.visible = paid > 0
	_ring.max_value = maxf(price, 1)
	_ring.value = paid
	# Empty plot before a pick shows nothing; the menu shows the prices.
	_price.visible = price > 0
	_price_label.text = str(price - paid)
	# Built plot: the price tag moves under the defender.
	_price.position = Vector2(0, 0) if level == 0 else Vector2(0, half_size.y + 6.0)
