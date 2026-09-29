class_name GiftWindow
extends UiWindow
## Daily gift (design I, screen 14): the 7-day calendar, "Claim" and "Claim
## ×2" for an ad (once a day). Days in a row grow: every full week adds
## +25% (MetaData), a missed day starts over — so the window tells what
## tomorrow brings. Landscape: one row of 7; portrait: 3 + 3 + the wide day 7.

@export var day_card: PackedScene

var _cards: Array[GiftDay] = []

@onready var _streak: Label = %Streak
@onready var _rows: Array[HBoxContainer] = [$Panel/Content/Days/Row1, $Panel/Content/Days/Row2, $Panel/Content/Days/Row3]
@onready var _buttons: HBoxContainer = %Buttons
@onready var _claim: Button = %Claim
@onready var _claim_x2: AdButton = %ClaimX2
@onready var _tomorrow: Label = %Tomorrow


func _ready() -> void:
	for i: int in Game.META.daily_gifts.size():
		var card: GiftDay = day_card.instantiate() as GiftDay
		_rows[0].add_child(card)
		_cards.append(card)
	super()
	_claim.pressed.connect(_take.bind(1))
	_claim_x2.text = tr("BTN_CLAIM_MULT") % Game.ADS.gift_mult
	_claim_x2.rewarded.connect(_take.bind(Game.ADS.gift_mult))
	UiFx.press_spring(_claim)
	_refresh()


func open() -> void:
	_refresh()
	super()


func _on_layout(portrait: bool) -> void:
	super(portrait)
	var last: int = _cards.size() - 1
	for i: int in _cards.size():
		var row: HBoxContainer = _rows[0]
		if portrait:
			row = _rows[mini(floori(i / 3.0), 2)] if i < last else _rows[2]
		if _cards[i].get_parent() != row:
			_cards[i].reparent(row)
		_cards[i].set_layout(portrait, portrait and i == last)
	# Keep the day order inside each row.
	for i: int in _cards.size():
		_cards[i].get_parent().move_child(_cards[i], -1)
	_rows[1].visible = portrait
	_rows[2].visible = portrait


func _refresh() -> void:
	if _cards.is_empty():
		return
	var date: String = Game.today()
	var can: bool = Game.can_claim_gift(date)
	var today: int = Game.gift_day_on(date) if can else Game.gift_day
	var week: int = Game.gift_week_on(date) if can else Game.gift_week
	var last: int = _cards.size() - 1
	for i: int in _cards.size():
		var state: String = "next"
		if i < today or (i == today and not can):
			state = "taken"
		elif i == today:
			state = "today"
		_cards[i].show_day(i, Game.gift_amount(i, week), state, i == last and state != "today")
	var bonus: int = roundi(Game.META.gift_week_bonus * 100.0 * mini(week, Game.META.gift_week_max))
	_streak.text = tr("GIFT_STREAK") % [week + 1, bonus] if week > 0 else tr("GIFT_HINT")
	_buttons.visible = can
	_claim_x2.disabled = Game.ads_used(&"gift_x2", date) >= Game.ADS.gift_per_day
	_tomorrow.visible = not can
	if not can:
		# Tomorrow continues the streak: the next day, a new week after day 7.
		var next_day: int = (today + 1) % _cards.size()
		var next_week: int = week + 1 if today == last else week
		_tomorrow.text = tr("GIFT_TOMORROW") % Game.gift_amount(next_day, next_week)


func _take(mult: int) -> void:
	var date: String = Game.today()
	if mult > 1:
		Game.use_ad(&"gift_x2", date)
	var n: int = Game.claim_gift(date, mult)
	if n <= 0:
		return
	Save.save()
	Ui.toast(tr("TOAST_GRAINS") % n)
	_refresh()
	UiFx.bump(_tomorrow, 1.2, 0.3)
