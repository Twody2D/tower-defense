"""Copies the art the game uses from design/ into tower-defense/art/, packs
biome tiles and enemy sheets into atlases and writes the animation manifest
tower-defense/art/animations.json (CODE_PROMPT section 2).

Frame counts come from the file names (`_<n>f.png`), FPS and loop/once from
the design mockups (`Партия *.dc.html`, the tables of batches B-F).
The manifest is read by tower-defense/tools/import_animations.gd, which makes
SpriteFrames (.tres) and the enemy atlas resources.

Only files listed here get into the project (the web build exports everything
imported). Re-run after the design is updated: files are overwritten in place,
their .import files (and UIDs) stay.

Run: py -3.14 tools/copy_art.py
"""

import json
import shutil
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "design" / "Защити огород дизайн" / "export"
DST = ROOT / "tower-defense" / "art"

# Static pictures: destination folder -> source files (relative to design export/)
FILES: dict[str, list[str]] = {
    "hero": [
        f"b/ui_{kind}_{skin}{suffix}.png"
        for skin in ("raccoon", "corgi", "pig", "rabbit", "chicken")
        for kind, suffix in (("portrait", ""), ("portrait", "_locked"), ("avatar", ""))
    ],
    "enemies": [
        "c/enemy_crow_shadow_1f.png",
        "c/item_carrot_hold.png",
        "c/ui_hp_mini_frame.png",
        "c/ui_hp_mini_fill.png",
    ],
    "defenders": [
        f"d/ui_def_portrait_{d}{s}.png" for d in ("goose", "frog", "beaver", "hive") for s in ("", "_locked")
    ] + [
        "d/proj_pea.png",
        "d/proj_drop.png",
    ],
    "env": [
        "e/base_bed.png",
        "e/base_hole.png",
        "e/spawn_burrow_idle_1f.png",
        "e/pad_normal.png",
        "e/pad_locked.png",
        "e/pad_max.png",
        "e/pad_progress_track.png",
        "e/pad_progress_fill.png",
        "e/ui_def_stars_1.png",
        "e/ui_def_stars_2.png",
        "e/ui_def_stars_3.png",
        "e/ui_def_max_plate.png",
        "e/ui_attack_radius.png",
        "e/env_farm_barn.png",
        "e/env_farm_haystack.png",
        "e/env_farm_wheelbarrow.png",
        "e/env_bush.png",
        "e/env_rocks.png",
        "e/env_stump.png",
        "e/env_fence_decor.png",
    ],
    "fx": [],
    "ui": [
        "h/ui_joystick_base.png",
        "h/ui_joystick_stick.png",
        "h/ui_radial_slot.png",
        "h/ui_radial_slot_locked.png",
        "h/ui_price_tag.png",
        "g/ui_icon_coin.png",
        "g/ui_icon_carrot.png",
        "g/ui_counter_plate.png",
        "g/ui_btn_round_normal.png",
        "g/ui_btn_round_pressed.png",
        "g/ui_icon_pause.png",
        "g/ui_lock.png",
        "h/ui_icon_clock.png",
        "g/ui_btn_green_normal.png",
        "g/ui_btn_green_pressed.png",
        "g/ui_btn_green_disabled.png",
        "g/ui_progress_frame.png",
        "g/ui_progress_fill.png",
    ],
}

# --- Animations -------------------------------------------------------------
# (name, frames, fps, loop). fps 0 = static states picked by code (fence damage).

HERO_ANIMS = [
    ("idle", 4, 6, True), ("run", 6, 12, True), ("throw", 4, 12, False), ("build", 4, 10, True),
    ("hit", 2, 12, False), ("stun", 4, 8, True), ("joy", 6, 10, True), ("sad", 4, 6, True),
]
SKINS = ["raccoon", "corgi", "pig", "rabbit", "chicken"]

PEST_ANIMS = [("walk", 4, 8, True), ("chew", 3, 8, True), ("grab", 3, 10, False), ("defeat", 5, 10, False)]
ENEMIES: dict[str, tuple[str, list[tuple[str, int, int, bool]]]] = {
    "beetle": ("enemy_beetle", PEST_ANIMS),
    "caterpillar": ("enemy_caterpillar", PEST_ANIMS),
    "mole": ("enemy_mole", PEST_ANIMS[:1] + [
        ("dive", 4, 10, False), ("underground", 2, 6, True), ("emerge", 4, 10, False),
    ] + PEST_ANIMS[1:]),
    "crow": ("enemy_crow", [("fly", 4, 10, True), ("swoop", 3, 12, False), ("defeat", 5, 10, False)]),
    "fox": ("boss_fox", [
        ("walk", 6, 10, True), ("appear", 6, 8, False), ("strike", 5, 12, False), ("stun", 4, 8, True),
        ("grab", 4, 8, False), ("defeat", 8, 10, False),
    ]),
}

DEFENDER_ATTACK = {"goose": (4, 12, False), "frog": (4, 10, True), "beaver": (5, 12, False), "hive": (4, 10, False)}

FENCE_ANIMS = [
    ("build", 5, 10, False), ("idle", 1, 0, False), ("damage", 3, 0, False),
    ("hit", 2, 12, False), ("destroy", 6, 12, False), ("repair", 4, 8, False),
]

# set "env": design file base name -> (fps, loop); frames come from the file name
ENV_ANIMS = {
    "base_carrot_idle_2f": (3, True), "base_carrot_pull_4f": (12, False),
    "spawn_burrow_exit_3f": (6, True), "spawn_burrow_idle_1f": (1, True),
    "pad_highlight_3f": (6, True), "pad_unlock_4f": (10, False), "ui_edge_arrow_3f": (6, True),
    "env_farm_barn_flag_4f": (8, True), "env_farm_scarecrow_sway_4f": (4, True),
    "env_wheat_mill_blades_4f": (8, True), "env_wheat_ears_sway_3f": (4, True),
    "env_lake_ripple_4f": (4, True), "env_lake_reeds_sway_3f": (4, True), "env_lake_skep_bees_4f": (10, True),
    "env_sunflower_sway_3f": (4, True), "env_tree_apple_sway_3f": (3, True), "env_tree_pine_sway_3f": (3, True),
}

# set "fx": batch F table (+ the rage aura from batch B)
FX_ANIMS = {
    "fx_poof_5f": (12, False), "fx_stars_head_4f": (8, True), "fx_hit_3f": (15, False),
    "fx_splash_4f": (12, False), "fx_tomato_burst_5f": (12, False), "fx_bee_2f": (16, True),
    "fx_dust_4f": (12, False), "fx_coin_pop_4f": (12, False), "fx_coin_spin_6f": (12, True),
    "fx_coin5_spin_6f": (12, True), "fx_coin_trail_3f": (10, True), "fx_build_flash_5f": (12, False),
    "fx_upgrade_5f": (10, False), "fx_parcel_fall_4f": (6, True), "fx_parcel_land_3f": (10, False),
    "fx_parcel_glow_4f": (8, True), "fx_parcel_open_5f": (10, False), "fx_tractor_4f": (10, True),
    "fx_sleepy_cloud_4f": (6, True), "fx_gold_rain_coin_4f": (12, True), "fx_magnet_aura_4f": (8, True),
    "fx_confetti_6f": (10, False), "fx_rage_aura_4f": (8, True), "proj_splat_3f": (12, False),
}

# set "projectiles": hero throws (by skin) and the tomato
PROJ_ANIMS = {
    "b/proj_apple_spin_4f": (12, True), "b/proj_bone_spin_4f": (12, True), "b/proj_acorn_spin_4f": (12, True),
    "b/proj_carrot_spin_4f": (12, True), "b/proj_egg_spin_4f": (12, True),
    "d/proj_tomato_spin_4f": (12, True),
}

TILE = 64
# Atlas layout: order = atlas cell index (8 columns). level.gd refers to these names.
TILES = [
    "grass_1", "grass_2", "grass_3",
    "road_straight_rl", "road_straight_tb",
    "road_corner_bl", "road_corner_rb", "road_corner_tl", "road_corner_tr",
    "road_end_b", "road_end_l", "road_end_r", "road_end_t",
    "road_t_rbl", "road_t_tbl", "road_t_trb", "road_t_trl",
]
BIOMES = ["farm", "wheat", "lake"]
COLS = 8


def frames_in(name: str) -> int:
    """`fx_poof_5f` -> 5; files without the suffix are one frame."""
    tail = name.rsplit("_", 1)[-1]
    return int(tail[:-1]) if tail.endswith("f") and tail[:-1].isdigit() else 1


def anim_name(base: str) -> str:
    """`env_tree_pine_sway_3f` -> `env_tree_pine_sway`."""
    return base.rsplit("_", 1)[0] if frames_in(base) > 1 or base.endswith("_1f") else base


def copy(rel: str, folder: str) -> str:
    """Copies export/<rel> into art/<folder>/, returns the res:// path."""
    src = SRC / rel
    if not src.is_file():
        raise FileNotFoundError(rel)
    out = DST / folder
    out.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, out / src.name)
    return f"res://art/{folder}/{src.name}"


def entry(path: str, frames: int, fps: int, loop: bool) -> dict:
    return {"file": path, "frames": frames, "fps": fps, "loop": loop}


def build_frames() -> dict[str, dict]:
    """SpriteFrames sets: set name -> animation name -> entry."""
    sets: dict[str, dict] = {}
    for skin in SKINS:
        sets[f"hero_{skin}"] = {
            a: entry(copy(f"b/hero_{skin}_{a}_{n}f.png", "hero"), n, fps, loop) for a, n, fps, loop in HERO_ANIMS
        }
    sets["projectiles"] = {}
    for rel, (fps, loop) in PROJ_ANIMS.items():
        base = rel.split("/")[1]
        name = base.removeprefix("proj_").split("_")[0]
        folder = "hero" if rel.startswith("b/") else "defenders"
        sets["projectiles"][name] = entry(copy(rel + ".png", folder), frames_in(base), fps, loop)
    for d, (an, afps, aloop) in DEFENDER_ATTACK.items():
        s: dict = {}
        for lv in (1, 2, 3):
            s[f"l{lv}_build"] = entry(copy(f"d/def_{d}_l{lv}_build_6f.png", "defenders"), 6, 10, False)
            s[f"l{lv}_idle"] = entry(copy(f"d/def_{d}_l{lv}_idle_4f.png", "defenders"), 4, 6, True)
            s[f"l{lv}_attack"] = entry(copy(f"d/def_{d}_l{lv}_attack_{an}f.png", "defenders"), an, afps, aloop)
        for u in ("1to2", "2to3"):
            s[f"upgrade_{u}"] = entry(copy(f"d/def_{d}_upgrade_{u}_5f.png", "defenders"), 5, 10, False)
        sets[f"def_{d}"] = s
    sets["fence"] = {
        f"l{lv}_{a}": entry(copy(f"d/fence_l{lv}_{a}_{n}f.png", "defenders"), n, fps, loop)
        for lv in (1, 2, 3) for a, n, fps, loop in FENCE_ANIMS
    }
    sets["env"] = {
        anim_name(b): entry(copy(f"e/{b}.png", "env"), frames_in(b), fps, loop) for b, (fps, loop) in ENV_ANIMS.items()
    }
    sets["fx"] = {}
    for b, (fps, loop) in FX_ANIMS.items():
        folder = "b" if b in ("fx_rage_aura_4f", "proj_splat_3f") else "f"
        sets["fx"][anim_name(b).removeprefix("fx_")] = entry(copy(f"{folder}/{b}.png", "fx"), frames_in(b), fps, loop)
    return sets


def build_atlases() -> dict[str, dict]:
    """One atlas per pest: a row per animation, square cells (design C frame size)."""
    atlases: dict[str, dict] = {}
    out = DST / "enemies"
    out.mkdir(parents=True, exist_ok=True)
    for pest, (prefix, anims) in ENEMIES.items():
        sheets = [Image.open(SRC / "c" / f"{prefix}_{a}_{n}f.png").convert("RGBA") for a, n, _, _ in anims]
        cell = sheets[0].height
        cols = max(n for _, n, _, _ in anims)
        atlas = Image.new("RGBA", (cols * cell, len(anims) * cell), (0, 0, 0, 0))
        info: dict = {}
        for row, ((a, n, fps, loop), sheet) in enumerate(zip(anims, sheets)):
            if sheet.size != (n * cell, cell):
                raise ValueError(f"{prefix}_{a}: {sheet.size}, expected {n * cell}x{cell}")
            atlas.paste(sheet, (0, row * cell))
            info[a] = {"row": row, "frames": n, "fps": fps, "loop": loop}
        atlas.save(out / f"atlas_{pest}.png", optimize=True)
        atlases[pest] = {"file": f"res://art/enemies/atlas_{pest}.png", "cell": cell, "columns": cols, "anims": info}
    return atlases


def copy_files() -> int:
    n = 0
    for folder, files in FILES.items():
        for rel in files:
            copy(rel, folder)
            n += 1
    return n


def pack_tiles() -> None:
    out = DST / "tiles"
    out.mkdir(parents=True, exist_ok=True)
    rows = (len(TILES) + COLS - 1) // COLS
    for biome in BIOMES:
        atlas = Image.new("RGBA", (COLS * TILE, rows * TILE), (0, 0, 0, 0))
        for i, name in enumerate(TILES):
            img = Image.open(SRC / "e" / f"tile_{biome}_{name}.png").convert("RGBA")
            atlas.paste(img, ((i % COLS) * TILE, (i // COLS) * TILE))
        atlas.save(out / f"tiles_{biome}.png", optimize=True)


def main() -> int:
    n = copy_files()
    frames = build_frames()
    atlases = build_atlases()
    pack_tiles()
    manifest = {"frames": frames, "atlases": atlases}
    (DST / "animations.json").write_text(json.dumps(manifest, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    sheets = sum(len(s) for s in frames.values())
    print(f"copied {n} pictures, {sheets} animation sheets in {len(frames)} sets, "
          f"{len(atlases)} enemy atlases, {len(BIOMES)} tile atlases")
    return 0


if __name__ == "__main__":
    sys.exit(main())
