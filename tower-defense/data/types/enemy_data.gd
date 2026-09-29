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
## Fence damage per second while it stands in front of one.
@export var chew_dps: float = 5.0
@export_group("Mole")
## Goes underground now and then: untouchable, not targeted, passes under fences.
@export var can_dive: bool = false
@export var dive_time: float = 2.0
## Walking time between dives, s.
@export var dive_every: float = 4.0

@export_group("Boss")
@export var is_boss: bool = false
## Fence strikes: a fence breaks after this many hits.
@export var fence_hits: int = 2
@export var strike_every: float = 1.5
## Stuns the hero within this radius every `stun_every` seconds.
@export var stun_radius: float = 160.0
@export var stun_every: float = 5.0

@export_group("Look")
## Walk sheet: one row of square frames (design C).
@export var walk_sheet: Texture2D
@export var walk_frames: int = 4
@export var walk_fps: float = 8.0
## Feet are this far below the frame centre, px (sprite drawn up from the feet).
@export var feet_offset: float = 23.0
