class_name BattleState
extends RefCounted
## Level economy of one battle: coins and carrots. Shared by the battle, plots and HUD.

signal coins_changed(coins: int)
signal carrots_changed(carrots: int)
signal carrots_gone

var coins: int = 0
var carrots: int = 0


func _init(start_coins: int = 0, start_carrots: int = 20) -> void:
	coins = start_coins
	carrots = start_carrots


func add_coins(n: int) -> void:
	coins += n
	coins_changed.emit(coins)


func spend(n: int) -> bool:
	if coins < n:
		return false
	coins -= n
	coins_changed.emit(coins)
	return true


## Second chance: carrots come back.
func give_carrots(n: int) -> void:
	carrots += n
	carrots_changed.emit(carrots)


func take_carrots(n: int) -> void:
	if carrots <= 0:
		return
	carrots = maxi(carrots - n, 0)
	carrots_changed.emit(carrots)
	if carrots == 0:
		carrots_gone.emit()
