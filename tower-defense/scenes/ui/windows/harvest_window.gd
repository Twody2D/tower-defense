class_name HarvestWindow
extends UiWindow
## Farm harvest (design K, replaces screen 15): a row per crop (CropRow) in
## one column in portrait and two in landscape, the total of the ripe ones,
## "Collect all" and "Collect ×3" for an ad (AdRewards). Everything becomes
## golden grains.

signal collected(grains: int)

@export var crop_row: PackedScene

var _rows: Array[CropRow] = []

@onready var _grid: GridContainer = %Grid
@onready var _total: Label = %Total
@onready var _claim: Button = %Claim
@onready var _claim_x3: AdButton = %ClaimX3


func _ready() -> void:
	super()
	for c: CropData in Game.META.crops:
		var row: CropRow = crop_row.instantiate() as CropRow
		_grid.add_child(row)
		row.setup(c)
		row.changed.connect(_refresh)
		_rows.append(row)
	_claim.pressed.connect(_take.bind(1))
	_claim_x3.text = tr("BTN_COLLECT_MULT") % Game.ADS.harvest_mult
	_claim_x3.rewarded.connect(_take.bind(Game.ADS.harvest_mult))
	UiFx.press_spring(_claim)
	Game.grains_changed.connect(func(_g: int) -> void: _refresh())
	_refresh()


func open() -> void:
	Game.start_harvest(Game.now())
	_refresh()
	super()


func _on_layout(portrait: bool) -> void:
	super(portrait)
	if _grid != null:
		_grid.columns = 1 if portrait else 2


func _process(_delta: float) -> void:
	# The growth bars and "ripe in" move while the window is open.
	if visible and Engine.get_process_frames() % 30 == 0:
		_refresh()


func _refresh() -> void:
	for row: CropRow in _rows:
		row.refresh()
	var n: int = Game.harvest_ready(Game.now())
	_total.text = "+%d" % n
	_claim.disabled = n <= 0
	_claim_x3.disabled = n <= 0


func _take(mult: int) -> void:
	var n: int = Game.collect_all(Game.now(), mult)
	if n <= 0:
		return
	Audio.sfx(&"coin", false)
	Save.save()
	Ui.toast(tr("TOAST_GRAINS") % n)
	collected.emit(n)
	_refresh()
