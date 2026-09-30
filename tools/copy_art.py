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
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "design" / "Защити огород дизайн" / "export"
DST = ROOT / "tower-defense" / "art"
SVG = ROOT / "design" / "Защити огород дизайн" / "assets"
GODOT = os.environ.get("GODOT", r"C:\PROGRAMS\Godot\Godot_v4.7.2-stable_win64_console.exe")

def frames_in(name: str) -> int:
    """`fx_poof_5f` -> 5; files without the suffix are one frame."""
    tail = name.rsplit("_", 1)[-1]
    return int(tail[:-1]) if tail.endswith("f") and tail[:-1].isdigit() else 1


# Static pictures: destination folder -> source files (relative to design export/)
FILES: dict[str, list[str]] = {
    "hero": [
        f"b/ui_{kind}_{skin}{suffix}.png"
        for skin in ("raccoon", "corgi", "pig", "rabbit", "chicken")
        for kind, suffix in (("portrait", ""), ("portrait", "_locked"), ("avatar", ""))
    ],
    "enemies": [
        "c/enemy_crow_shadow_1f.png",
        "c/ui_enemy_portrait_beetle.png",
        "c/ui_enemy_portrait_caterpillar.png",
        "c/ui_enemy_portrait_mole.png",
        "c/ui_enemy_portrait_crow.png",
        "c/ui_enemy_portrait_fox.png",
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
        # screens: grass and road tiles as pictures, map decor of all biomes
        "e/tile_farm_grass_1.png",
        "e/tile_wheat_grass_1.png",
        "e/tile_lake_grass_1.png",
        "e/tile_farm_road_straight_rl.png",
        "e/tile_farm_road_straight_tb.png",
        "e/tile_farm_road_corner_bl.png",
        "e/env_farm_bed.png",
        "e/env_wheat_mill.png",
        "e/env_wheat_sheaf.png",
        "e/env_wheat_cart.png",
        "e/env_lake_lake.png",
        "e/env_lake_boat.png",
        "e/env_lake_skep.png",
    ],
    "fx": [],
    # The whole UI kit (G) and screen parts (I); animated ones go to UI_ANIMS.
    "ui": sorted(
        f"{d}/{f.name}" for d in ("g", "i") for f in (SRC / d).glob("*.png") if frames_in(f.stem) == 1
    ) + [
        "h/ui_boss_hp_frame.png",
        "h/ui_boss_hp_fill.png",
        "h/ui_ribbon_boss.png",
        "h/ui_icon_parcel.png",
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

# set "ui": batch G animated icons, stars, tutorial
UI_ANIMS = {
    "ui_btn_ad_glint_4f": (8, True), "ui_star_appear_5f": (12, False), "ui_icon_gift_shake_4f": (10, True),
    "ui_icon_harvest_ripe_3f": (6, True), "ui_tut_hand_tap_4f": (8, True), "ui_tut_hand_swipe_6f": (10, True),
    "ui_tut_highlight_3f": (6, True), "ui_tut_arrow_3f": (8, True),
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
    sets["ui"] = {
        anim_name(b).removeprefix("ui_"): entry(copy(f"g/{b}.png", "ui"), frames_in(b), fps, loop)
        for b, (fps, loop) in UI_ANIMS.items()
    }
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


def make_shadow() -> None:
    """Soft ground shadow under heroes on screens (the mockups draw it with CSS):
    ellipse 4:1, #2B2B3A at 22%."""
    w, h = 128, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            d = ((x + 0.5 - w / 2) / (w / 2)) ** 2 + ((y + 0.5 - h / 2) / (h / 2)) ** 2
            if d <= 1.0:
                a = 0.22 * min(1.0, (1.0 - d) * 6.0)
                px[x, y] = (43, 43, 58, round(a * 255))
    img.save(DST / "ui" / "shadow.png", optimize=True)


def make_small_buttons() -> None:
    """Small buttons of the mockups (80 tall, slice 31 31 36 31): the kit
    draws them by scaling the 112 picture with CSS; Godot 9-slice cannot, so
    the pictures are scaled here (ui_btn_<colour>_<state>_sm.png)."""
    k = 80 / 112
    for colour in ("orange", "green", "blue", "ad"):
        for state in ("normal", "pressed", "disabled"):
            src = Image.open(DST / "ui" / f"ui_btn_{colour}_{state}.png").convert("RGBA")
            size = (round(src.width * k), round(src.height * k))
            src.resize(size, Image.Resampling.LANCZOS).save(DST / "ui" / f"ui_btn_{colour}_{state}_sm.png", optimize=True)


# --- Big copies for screens ---------------------------------------------------
# The PNG sheets are drawn for the battle (hero 128, beetle 48); menus and
# windows show them 3–6 times bigger and they blur. These sheets are rendered
# again from the design SVGs at a scale (frame ≈ 250–400 px):
# sets hero_<skin>_ui (idle, sad; the raccoon also joy), ui_hi (gift, harvest icons, parcel glow),
# single pictures art/hi/ui_icon_bonus_*.png, pests_ui (<pest>: walk/fly), defenders_ui (<id>: l1 idle).
HI_HERO = [("idle", 4, 6, True), ("sad", 4, 6, True)]
HI_HERO_EXTRA = {"raccoon": [("joy", 6, 10, True)]}  # the loading screen
HI_HERO_SCALE = 3.0
HI_PESTS = {  # pest: (svg base, frames, fps, scale)
    "beetle": ("enemy_beetle_walk_4f", 4, 8, 5.0),
    "caterpillar": ("enemy_caterpillar_walk_4f", 4, 8, 4.0),
    "mole": ("enemy_mole_walk_4f", 4, 8, 4.0),
    "crow": ("enemy_crow_fly_4f", 4, 10, 4.0),
    "fox": ("boss_fox_walk_6f", 6, 10, 1.5),
}
HI_DEFENDER_SCALE = 2.0
HI_UI = {  # name in ui_hi: (svg base, frames, fps, scale) — gift and harvest windows
    "harvest_ripe": ("ui_icon_harvest_ripe_3f", 3, 6, 4.0),
    "gift_shake": ("ui_icon_gift_shake_4f", 4, 10, 2.0),
    "gift": ("ui_icon_gift", 1, 1, 2.0),
}
# Parcel window (design H): the glowing box and the bonus icons at 128 px.
HI_FX = {"parcel_glow": ("fx_parcel_glow_4f", 4, 8, 2.0)}  # name in ui_hi: (svg base in f/, frames, fps, scale)
HI_ICONS = [f"ui_icon_bonus_{b}" for b in ("gold_rain", "rage", "super_magnet", "upgrade", "tractor", "sleepy_rain", "helper")]
HI_ICON_SCALE = 2.0


def flat_svg(text: str) -> str:
    """A design sheet keeps each frame in a nested <svg x=… y=…>; Godot's
    ThorVG draws only the first. Frames become clipped, shifted groups."""
    text = re.sub(r"<metadata>.*?</metadata>", "", text, flags=re.S)
    root_end = text.index(">") + 1
    head, body = text[:root_end], text[root_end:text.rindex("</svg>")]
    clips: list[str] = []

    def frame(m: re.Match) -> str:
        attrs, inner = m.group(1), m.group(2)

        def num(key: str) -> float:
            found = re.search(r"\b" + key + r'="([-\d.]+)"', attrs)
            return float(found.group(1)) if found else 0.0

        x, y, w, h = num("x"), num("y"), num("width"), num("height")
        cid = f"frame{len(clips)}"
        clips.append(f'<clipPath id="{cid}"><rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}"/></clipPath>')
        return f'<g clip-path="url(#{cid})"><g transform="translate({x:g} {y:g})">{inner}</g></g>'

    body = re.sub(r"<svg\b([^>]*)>(.*?)</svg>", frame, body, flags=re.S)
    return head + "<defs>" + "".join(clips) + "</defs>" + body + "</svg>"


# The fox portrait is cut out of the whole fox: the tip of its tail pokes into
# the bottom-left corner and looks like a stray blot in the round slots.
PORTRAIT_ERASE = {"enemies/ui_enemy_portrait_fox.png": (0, 116, 20, 128)}  # x0, y0, x1, y1


def trim_portraits() -> None:
    from PIL import Image
    for rel, box in PORTRAIT_ERASE.items():
        path = DST / rel
        im = Image.open(path).convert("RGBA")
        im.paste((0, 0, 0, 0), box)
        im.save(path)


# Tractor bonus (Twody: the wheels turn). The design sheet only puffs smoke, so
# the two wheels are cut out of frame 0 as round pictures and turned in the
# scene on top of the drawn ones; tread lugs make the turning visible.
TRACTOR_WHEELS = {  # name: (centre in the 160 frame (pixel edges), outer radius, tire band, lugs)
    "big": ((64.0, 120.0), 30.0, (14.0, 26.0), 8),
    "small": ((124.0, 128.0), 21.0, (9.0, 17.2), 6),
}
TIRE = (59, 63, 78, 255)
TREAD = (88, 94, 114, 255)


def make_tractor_wheels() -> None:
    import math
    from PIL import ImageChops, ImageDraw
    sheet = Image.open(DST / "fx" / "fx_tractor_4f.png").convert("RGBA")
    ss = 4
    for name, ((cx, cy), r, (t0, t1), lugs) in TRACTOR_WHEELS.items():
        size = math.ceil(r) * 2 + 2
        box = (round(cx - size / 2), round(cy - size / 2))
        wheel = sheet.crop((box[0], box[1], box[0] + size, box[1] + size))
        c = (cx - box[0]) * ss, (cy - box[1]) * ss

        def ring(rad: float) -> tuple[float, float, float, float]:
            return c[0] - rad * ss, c[1] - rad * ss, c[0] + rad * ss, c[1] + rad * ss

        # Drawn 4x bigger and scaled down for soft edges: the tire gets one flat
        # colour (its drawn shade would turn with it) and tread lugs.
        big = Image.new("RGBA", (size * ss, size * ss), (0, 0, 0, 0))
        draw = ImageDraw.Draw(big)
        draw.ellipse(ring(t1), fill=TIRE)
        draw.ellipse(ring(t0), fill=(0, 0, 0, 0))
        r0, r1, w = t0 + 1.5, t1 - 0.5, 1.6 * ss
        for k in range(lugs):
            a = 2 * math.pi * k / lugs
            d = math.cos(a), math.sin(a)
            n = -d[1], d[0]
            p = [(c[0] + d[0] * rr * ss + n[0] * s * w, c[1] + d[1] * rr * ss + n[1] * s * w)
                 for rr, s in ((r0, -1), (r1, -1), (r1, 1), (r0, 1))]
            draw.polygon(p, fill=TREAD)
        wheel.alpha_composite(big.resize((size, size), Image.Resampling.LANCZOS))
        # Round cut a pixel inside the outline: only the wheel, not the body
        # behind it (the drawn outline underneath stays).
        mask = Image.new("L", (size * ss, size * ss), 0)
        ImageDraw.Draw(mask).ellipse(ring(r - 1.0), fill=255)
        mask = mask.resize((size, size), Image.Resampling.LANCZOS)
        wheel.putalpha(ImageChops.darker(wheel.getchannel("A"), mask))
        wheel.save(DST / "fx" / f"fx_tractor_wheel_{name}.png", optimize=True)


def make_hi() -> dict[str, dict]:
    """Renders the big sheets into art/hi/ (through Godot) and returns their sets."""
    out = DST / "hi"
    out.mkdir(parents=True, exist_ok=True)
    jobs: list[dict] = []
    sets: dict[str, dict] = {}
    tmp = Path(tempfile.mkdtemp(prefix="hi_svg_"))

    def job(folder: str, base: str, scale: float) -> str:
        src = tmp / f"{base}.svg"
        src.write_text(flat_svg((SVG / folder / f"{base}.svg").read_text(encoding="utf-8")), encoding="utf-8")
        jobs.append({"src": str(src), "scale": scale, "out": str(out / f"{base}.png")})
        return f"res://art/hi/{base}.png"

    for skin in SKINS:
        sets[f"hero_{skin}_ui"] = {
            a: entry(job("b", f"hero_{skin}_{a}_{n}f", HI_HERO_SCALE), n, fps, loop)
            for a, n, fps, loop in HI_HERO + HI_HERO_EXTRA.get(skin, [])
        }
    sets["pests_ui"] = {
        pest: entry(job("c", base, k), n, fps, True) for pest, (base, n, fps, k) in HI_PESTS.items()
    }
    sets["defenders_ui"] = {
        d: entry(job("d", f"def_{d}_l1_idle_4f", HI_DEFENDER_SCALE), 4, 6, True) for d in DEFENDER_ATTACK
    }
    sets["ui_hi"] = {
        name: entry(job("g", base, k), n, fps, True) for name, (base, n, fps, k) in HI_UI.items()
    }
    for name, (base, n, fps, k) in HI_FX.items():
        sets["ui_hi"][name] = entry(job("f", base, k), n, fps, True)
    for base in HI_ICONS:
        job("g", base, HI_ICON_SCALE)
    # The logo carrot's leaves stick out above the plate's box (the PNG cuts
    # them): the plate is rendered with 40 px more on top, 960×480.
    logo = re.sub(r"<metadata>.*?</metadata>", "", (SVG / "i" / "logo_plate.svg").read_text(encoding="utf-8"), flags=re.S)
    logo = logo.replace('height="440" viewBox="0 0 960 440"', 'height="480" viewBox="0 -40 960 480"', 1)
    (tmp / "logo_plate.svg").write_text(logo, encoding="utf-8")
    jobs.append({"src": str(tmp / "logo_plate.svg"), "scale": 1.0, "out": str(DST / "ui" / "logo_plate.png")})
    listing = tmp / "jobs.json"
    listing.write_text(json.dumps(jobs), encoding="utf-8")
    subprocess.run([GODOT, "--headless", "--path", str(ROOT / "tower-defense"), "-s", "res://tools/render_svg_cli.gd",
                    "--", str(listing)], check=True, capture_output=True)
    shutil.rmtree(tmp, ignore_errors=True)
    return sets


def main() -> int:
    n = copy_files()
    trim_portraits()
    make_tractor_wheels()
    make_shadow()
    make_small_buttons()
    frames = build_frames()
    frames.update(make_hi())
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
