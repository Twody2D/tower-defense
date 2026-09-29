"""Copies the art the game uses from design/ into tower-defense/art/ and packs
biome tiles into one atlas per biome.

Only files listed here get into the project (the web build exports everything
imported). Re-run after the design is updated: files are overwritten in place,
their .import files (and UIDs) stay.

Run: py -3.14 tools/copy_art.py
"""

import shutil
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "design" / "Защити огород дизайн" / "export"
DST = ROOT / "tower-defense" / "art"

# destination folder -> source files (relative to design export/)
FILES: dict[str, list[str]] = {
    "hero": [
        "b/hero_raccoon_idle_4f.png",
        "b/hero_raccoon_run_6f.png",
        "b/proj_apple_spin_4f.png",
        "b/proj_splat_3f.png",
    ],
    "enemies": [
        "c/enemy_beetle_walk_4f.png",
        "c/enemy_caterpillar_walk_4f.png",
        "c/enemy_mole_walk_4f.png",
        "c/enemy_crow_fly_4f.png",
        "c/boss_fox_walk_6f.png",
    ],
    "defenders": [
        f"d/def_{d}_l{lv}_idle_4f.png" for d in ("goose", "frog", "beaver", "hive") for lv in (1, 2, 3)
    ] + [
        f"d/fence_l{lv}_damage_3f.png" for lv in (1, 2, 3)
    ] + [
        f"d/ui_def_portrait_{d}{s}.png" for d in ("goose", "frog", "beaver", "hive") for s in ("", "_locked")
    ] + [
        "d/proj_pea.png",
        "d/proj_drop.png",
        "d/proj_tomato_spin_4f.png",
        "f/fx_bee_2f.png",
    ],
    "env": [
        "e/base_bed.png",
        "e/base_carrot_idle_2f.png",
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
        "e/env_farm_scarecrow_sway_4f.png",
        "e/env_tree_apple_sway_3f.png",
        "e/env_tree_pine_sway_3f.png",
        "e/env_bush.png",
        "e/env_rocks.png",
        "e/env_stump.png",
        "e/env_sunflower_sway_3f.png",
        "e/env_fence_decor.png",
    ],
    "fx": [
        "f/fx_coin_spin_6f.png",
        "f/fx_coin5_spin_6f.png",
        "f/fx_poof_5f.png",
        "f/fx_stars_head_4f.png",
        "f/fx_hit_3f.png",
    ],
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
    ],
}

TILE = 64
# Atlas layout: order = atlas cell index (8 columns). tiles.gd refers to these names.
TILES = [
    "grass_1", "grass_2", "grass_3",
    "road_straight_rl", "road_straight_tb",
    "road_corner_bl", "road_corner_rb", "road_corner_tl", "road_corner_tr",
    "road_end_b", "road_end_l", "road_end_r", "road_end_t",
    "road_t_rbl", "road_t_tbl", "road_t_trb", "road_t_trl",
]
BIOMES = ["farm", "wheat", "lake"]
COLS = 8


def copy_files() -> int:
    n = 0
    for folder, files in FILES.items():
        out = DST / folder
        out.mkdir(parents=True, exist_ok=True)
        for rel in files:
            src = SRC / rel
            if not src.is_file():
                print("MISSING", rel)
                continue
            shutil.copyfile(src, out / src.name)
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
    pack_tiles()
    print(f"copied {n} files, packed {len(BIOMES)} tile atlases")
    return 0


if __name__ == "__main__":
    sys.exit(main())
