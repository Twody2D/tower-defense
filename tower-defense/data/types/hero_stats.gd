class_name HeroStats
extends Resource
## Hero base stats (CODE_PROMPT, "Герой"). Meta upgrades multiply them later.

## Run speed, px/s.
@export var speed: float = 220.0
## On the road the hero runs this much faster (Twody: paths are for running).
@export var road_speed_mult: float = 1.4
## Damage of one thrown apple.
@export var damage: float = 10.0
## Throws per second.
@export var attacks_per_second: float = 1.5
## Auto-attack reach, px.
@export var attack_radius: float = 180.0
## Coins inside this radius fly to the hero, px.
@export var magnet_radius: float = 120.0
## Stun time when a pest touches the hero (or the fox strikes), s.
@export var stun_time: float = 1.5
## Untouchable time after a stun, s.
@export var invulnerable_time: float = 1.0
## Flight speed of the thrown apple, px/s.
@export var projectile_speed: float = 700.0
## Body radius for collisions and plot checks, px.
@export var body_radius: float = 26.0
