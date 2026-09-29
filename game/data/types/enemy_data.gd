class_name EnemyData
extends Resource
## One pest type (CODE_PROMPT, "Вредители"). HP grows per campaign level in LevelData.

@export var id: StringName = &"beetle"
@export var hp: float = 12.0
## Walk speed along the road, px/s.
@export var speed: float = 70.0
## Coins dropped on defeat.
@export var coins: int = 1
## Carrots taken when it reaches the base.
@export var carrots: int = 1
## Body radius (hit checks and the grey prototype circle), px.
@export var radius: float = 16.0
## Sprite frame size from the design (48 beetle … 192 fox), px.
@export var frame_size: int = 48
## Flies straight to the base, ignores fences.
@export var flying: bool = false
## Grey-prototype colour (the horde is purple in the design).
@export var color: Color = Color("8e44ad")
