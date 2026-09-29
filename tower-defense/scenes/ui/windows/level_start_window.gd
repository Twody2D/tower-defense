class_name LevelStartWindow
extends UiWindow
## Level start (design I, screen 5), over the map: level number, pests met
## for the first time on this level, ad boosts (coins, starting goose
## level 2), "Fight". Boosts are stored in Game and used by the battle.

@export_file("*.tscn") var battle_scene: String = "res://scenes/battle/battle.tscn"
@export var level_data_pattern: String = "res://data/levels/level_%02d.tres"
@export var enemy_card: PackedScene

@onready var _enemies_block: Control = %EnemiesBlock
@onready var _enemy_cards: HBoxContainer = %EnemyCards
@onready var _coins_ad: AdButton = %CoinsAd
@onready var _defender_ad: AdButton = %DefenderAd
@onready var _fight: Button = %Fight
@onready var _coins_label: Label = %CoinsLabel


func _ready() -> void:
	super()
	var level: int = Game.current_level
	set_title(tr("TITLE_LEVEL") % level)
	Game.boost_coins = false
	Game.boost_defender = false
	_coins_label.text = tr("BOOST_COINS") % Game.ADS.start_coins
	_coins_ad.rewarded.connect(_on_coins)
	_defender_ad.rewarded.connect(_on_defender)
	_fight.pressed.connect(_on_fight)
	UiFx.press_spring(_fight)
	_fill_new_enemies(level)


## Pest types of this level that no earlier level had.
func _fill_new_enemies(level: int) -> void:
	var data: LevelData = _level_data(level)
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
	_enemies_block.visible = shown > 0


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
