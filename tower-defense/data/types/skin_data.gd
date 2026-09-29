class_name SkinData
extends Resource
## Hero skin (CODE_PROMPT "Мета": looks only, same animations). One of the
## unlock ways is set: grains price, rewarded views, or a campaign level.

@export var id: StringName = &"raccoon"
## Name key for tr().
@export var name_key: String = "SKIN_RACCOON"
## Animations (art/frames/hero_<id>.tres).
@export var frames: SpriteFrames
## Big idle / sad for menus and windows (art/frames/hero_<id>_ui.tres, frame 384).
@export var ui_frames: SpriteFrames
## Shop portrait 256 and its dark placeholder, map avatar 96 (design B).
@export var portrait: Texture2D
@export var portrait_locked: Texture2D
@export var avatar: Texture2D
## What this hero throws (design B: apple, bone, acorn, carrot, egg).
@export var projectile: Texture2D
@export_group("Unlock")
## Owned from the start.
@export var free: bool = false
## Bought for this many golden grains (0 = not for sale).
@export var price_grains: int = 0
## Opens after this many rewarded views (0 = not by ads).
@export var ad_views: int = 0
## Opens when this campaign level is passed (0 = not by level).
@export var unlock_level: int = 0
