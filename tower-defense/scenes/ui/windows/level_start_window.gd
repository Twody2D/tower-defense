class_name LevelStartWindow
extends UiWindow
## Level start (design O, 3a), over the map: "Level N" ribbon (red on a boss
## level), the zone and the best stars, then the pests — the boss card on a
## Fox level (the map's Fox signs; the Fox comes on every level), otherwise
## the pests met for the first time here or "nothing new" — quiet ad boost
## tiles (coins, starting goose level 2) and a big "Fight". Boosts are
## stored in Game and used by the battle.

@export_file("*.tscn") var battle_scene: String = "res://scenes/battle/battle.tscn"
@export var level_data_pattern: String = "res://data/levels/level_%02d.tres"
@export var enemy_card: PackedScene
## Levels with the Fox sign on the map (tools/make_map.py FOX): the boss card.
@export var boss_levels: Array[int] = [5, 10, 12]
## Zones: the first level of each, its name key and its grass tile.
@export var zone_starts: Array[int] = [1, 6, 10]
@export var zone_keys: Array[String] = ["ZONE_FARM", "ZONE_WHEAT", "ZONE_LAKE"]
@export var zone_icons: Array[Texture2D] = []
@export var star_full: Texture2D
@export var star_empty: Texture2D
@export var ribbon_boss: Texture2D
## "Fight" width in portrait / landscape, px.
@export var fight_width: Vector2 = Vector2(760, 720)

@onready var _zone_icon: TextureRect = %ZoneIcon
@onready var _zone_name: Label = %ZoneName
@onready var _stars: HBoxContainer = %Stars
@onready var _enemies_block: Control = %EnemiesBlock
@onready var _enemy_cards: HBoxContainer = %EnemyCards
@onready var _boss_card: Control = %BossCard
@onready var _boss_portrait: TextureRect = %BossPortrait
@onready var _boss_name: Label = %BossName
@onready var _boss_hint: Label = %BossHint
@onready var _no_enemies: Control = %NoEnemies
@onready var _coins_ad: AdButton = %CoinsAd
@onready var _defender_ad: AdButton = %DefenderAd
@onready var _fight: Button = %Fight
@onready var _coins_label: Label = %CoinsLabel


func _ready() -> void:
	var level: int = Game.current_level
	var data: LevelData = _level_data(level)
	var boss: EnemyData = _boss_of(data) if level in boss_levels else null
	if boss != null:
		ribbon_texture = ribbon_boss
	super()
	set_title(tr("TITLE_LEVEL") % level)
	_show_zone(level)
	Game.boost_coins = false
	Game.boost_defender = false
	_coins_label.text = tr("BOOST_COINS") % Game.ADS.start_coins
	_coins_ad.rewarded.connect(_on_coins)
	_defender_ad.rewarded.connect(_on_defender)
	_fight.pressed.connect(_on_fight)
	UiFx.press_spring(_fight)
	_boss_card.visible = boss != null
	if boss != null:
		_boss_portrait.texture = boss.portrait
		_boss_name.text = tr(boss.name_key)
		_boss_hint.text = tr(boss.hint_key)
		_enemies_block.visible = false
		_no_enemies.visible = false
	else:
		var shown: int = _fill_new_enemies(level, data)
		_enemies_block.visible = shown > 0
		_no_enemies.visible = shown == 0


func _on_layout(portrait: bool) -> void:
	super(portrait)
	_fight.custom_minimum_size.x = fight_width.x if portrait else fight_width.y


## Zone name and tile by the level number; the best stars so far.
func _show_zone(level: int) -> void:
	var zone: int = 0
	for i: int in zone_starts.size():
		if level >= zone_starts[i]:
			zone = i
	_zone_name.text = tr(zone_keys[zone])
	if zone < zone_icons.size():
		_zone_icon.texture = zone_icons[zone]
	var best: int = Game.level_stars[level - 1] if level - 1 < Game.level_stars.size() else 0
	for i: int in _stars.get_child_count():
		(_stars.get_child(i) as TextureRect).texture = star_full if i < best else star_empty


func _boss_of(data: LevelData) -> EnemyData:
	if data != null:
		for e: EnemyData in data.enemy_types():
			if e.is_boss:
				return e
	return null


## Pest types of this level that no earlier level had; how many are shown.
func _fill_new_enemies(level: int, data: LevelData) -> int:
	var earlier: Array[StringName] = []
	for n: int in range(1, level):
		var d: LevelData = _level_data(n)
		if d != null:
			for e: EnemyData in d.enemy_types():
				earlier.append(e.id)
	var shown: int = 0
	if data != null:
		for e: EnemyData in data.enemy_types():
			if e.id in earlier or enemy_card == null:
				continue
			var card: EnemyCard = enemy_card.instantiate() as EnemyCard
			_enemy_cards.add_child(card)
			card.show_enemy(e)
			shown += 1
	return shown


func _level_data(level: int) -> LevelData:
	var path: String = level_data_pattern % level
	return load(path) as LevelData if ResourceLoader.exists(path) else null


func _on_coins() -> void:
	Game.boost_coins = true
	_coins_ad.disabled = true


func _on_defender() -> void:
	Game.boost_defender = true
	_defender_ad.disabled = true


func _on_fight() -> void:
	get_tree().change_scene_to_file(battle_scene)
