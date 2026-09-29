class_name EnemyCard
extends PanelContainer
## Small pest card (design I, level start): portrait and name.


func show_enemy(data: EnemyData) -> void:
	($Box/Portrait as TextureRect).texture = data.portrait
	($Box/Name as Label).text = tr(data.name_key)
