"""Levels 1–12 (level 1: scene only, its waves are hand-tuned) (CODE_PROMPT "Уровни"): scenes and data from the plans below.

Writes tower-defense/scenes/levels/level_NN.tscn and data/levels/level_NN.tres
(level 1 is hand-tuned and left alone). OVERWRITES those files: after hand
edits in the editor, change the plan here or stop using the script.
Then lay the tiles: "$G" --headless --path . -s res://dev/rebuild_level.gd -- <scene>

Plans are in 64 px cells on a 30×30 field with the carrot bed at the bottom
left; `mirror` flips a level left-right. Roads: corner cells, the first on
the field edge, the last next to the bed (right of it (9,23), above (6,21),
left of it (3,23)). Plots: grid corners (a plot covers the 2×2 cells around
it). Fences: road cells. The script checks the plan and places the decor.
"""
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "tower-defense"
N = 30
CELL = 64
BASE = (416, 1504)          # bed centre, px (level 1)
BASE_CELLS = {(x, y) for x in range(4, 9) for y in range(22, 26)}
HERO = (10, 21)             # hero start cell

DEFENDER_UNLOCK = [("goose", 1), ("frog", 2), ("beaver", 5), ("hive", 8)]  # Twody: a new tower on level 2
ENEMY_HP = {"beetle": 16, "caterpillar": 60, "mole": 35, "crow": 20}
# Type: (first level, share of the wave HP once it is in).
ENEMY_MIX = {"caterpillar": (2, 0.30), "mole": (4, 0.22), "crow": (6, 0.18)}
# Boss share of the full fox (1500 HP) in the last wave; full at 5, 10, 12.
FOX_SCALE = {2: 0.18, 3: 0.25, 4: 0.35, 5: 1.0, 6: 0.45, 7: 0.55, 8: 0.65, 9: 0.75, 10: 1.0, 11: 0.85, 12: 1.0}
# Wave HP budget: first wave, then × growth so the last is ~4.5× the first.
FIRST_WAVE_HP = 190.0
FIRST_WAVE_GROWTH = 0.15    # per level
LAST_OVER_FIRST = 4.5

PLANS = {
    1: dict(biome="farm", waves=5, mirror=False, data=False,
            roads=[[(21, 0), (21, 7), (8, 7), (8, 15), (20, 15), (20, 23), (9, 23)]]),
    2: dict(biome="farm", waves=5, mirror=False,
            roads=[[(29, 5), (14, 5), (14, 11), (25, 11), (25, 18), (13, 18), (13, 23), (9, 23)]]),
    3: dict(biome="farm", waves=6, mirror=True,
            roads=[[(18, 0), (18, 4), (26, 4), (26, 10), (11, 10), (11, 16), (24, 16), (24, 23), (9, 23)]]),
    4: dict(biome="farm", waves=6, mirror=False,
            roads=[[(29, 3), (15, 3), (15, 9), (23, 9), (23, 17), (16, 17), (16, 23), (9, 23)],
                   [(0, 8), (9, 8), (9, 15), (6, 15), (6, 21)]]),
    5: dict(biome="farm", waves=6, mirror=True,
            roads=[[(22, 0), (22, 5), (12, 5), (12, 11), (25, 11), (25, 19), (14, 19), (14, 23), (9, 23)],
                   [(0, 12), (8, 12), (8, 17), (3, 17), (3, 23)]]),
    6: dict(biome="wheat", waves=7, mirror=False,
            roads=[[(29, 6), (18, 6), (18, 13), (24, 13), (24, 20), (15, 20), (15, 23), (9, 23)],
                   [(10, 0), (10, 7), (3, 7), (3, 16), (6, 16), (6, 21)]]),
    7: dict(biome="wheat", waves=7, mirror=True,
            roads=[[(20, 0), (20, 4), (27, 4), (27, 12), (16, 12), (16, 17), (22, 17), (22, 23), (9, 23)],
                   [(0, 5), (9, 5), (9, 13), (6, 13), (6, 21)]]),
    8: dict(biome="wheat", waves=7, mirror=False,
            roads=[[(29, 14), (20, 14), (20, 6), (13, 6), (13, 17), (18, 17), (18, 23), (9, 23)],
                   [(4, 0), (4, 10), (9, 10), (9, 16), (6, 16), (6, 21)]]),
    9: dict(biome="wheat", waves=7, mirror=True,
            roads=[[(15, 0), (15, 3), (25, 3), (25, 9), (17, 9), (17, 14), (26, 14), (26, 20), (14, 20), (14, 23), (9, 23)],
                   [(0, 4), (7, 4), (7, 9), (11, 9), (11, 15), (6, 15), (6, 21)]]),
    10: dict(biome="lake", waves=8, mirror=False,
             roads=[[(29, 9), (19, 9), (19, 3), (11, 3), (11, 12), (22, 12), (22, 19), (13, 19), (13, 23), (9, 23)],
                    [(0, 6), (6, 6), (6, 16), (3, 16), (3, 23)]]),
    11: dict(biome="lake", waves=8, mirror=True,
             roads=[[(29, 4), (20, 4), (20, 10), (27, 10), (27, 18), (17, 18), (17, 23), (9, 23)],
                    [(12, 0), (12, 13), (6, 13), (6, 21)],
                    [(0, 9), (3, 9), (3, 23)]]),
    12: dict(biome="lake", waves=8, mirror=False,
             roads=[[(29, 17), (23, 17), (23, 5), (16, 5), (16, 12), (19, 12), (19, 20), (13, 20), (13, 23), (9, 23)],
                    [(8, 0), (8, 9), (11, 9), (11, 16), (6, 16), (6, 21)],
                    [(0, 4), (3, 4), (3, 23)]]),
}

# Decor: name → (resource kind, path or animation, sprite offset y, footprint cells w, h, block rect or None)
# kind "tex" = Sprite2D, "anim" = AnimatedSprite2D from env.tres.
# No apple trees in the decor (Twody: an apple tree with apples you cannot
# pick looks broken) — apple trees are only the crops (place_crops).
DECOR = {
    "pine": ("anim", "env_tree_pine_sway", -62, 2, 2),
    "bush": ("tex", "env_bush", -38, 1, 1),
    "rocks": ("tex", "env_rocks", -28, 1, 1),
    "stump": ("tex", "env_stump", -30, 1, 1),
    "haystack": ("tex", "env_farm_haystack", -46, 1, 1),
    "barrow": ("tex", "env_farm_wheelbarrow", -44, 1, 1),
    "scarecrow": ("anim", "env_farm_scarecrow_sway", -62, 1, 2),
    "sunflower": ("anim", "env_sunflower_sway", -48, 1, 1),
    "fence_decor": ("tex", "env_fence_decor", -30, 2, 1),
    "ears": ("anim", "env_wheat_ears_sway", -26, 1, 1),
    "sheaf": ("tex", "env_wheat_sheaf", -40, 1, 1),
    "cart": ("tex", "env_wheat_cart", -54, 2, 2),
    "reeds": ("anim", "env_lake_reeds_sway", -40, 1, 1),
}
BIOME_DECOR = {
    "farm": ["pine", "bush", "pine", "pine", "bush", "bush", "rocks", "haystack", "scarecrow", "sunflower",
             "sunflower", "stump", "barrow", "bush", "bush", "rocks"],
    "wheat": ["ears", "ears", "ears", "ears", "ears", "sheaf", "sheaf", "cart", "scarecrow", "pine", "bush",
              "rocks", "stump", "sunflower", "sunflower", "ears"],
    "lake": ["reeds", "reeds", "reeds", "pine", "pine", "pine", "bush", "bush", "rocks", "stump", "sunflower",
             "reeds", "pine", "bush"],
}
# Landmark footprints (cells around the node cell: x0, y0, x1, y1 inclusive) and spots to try.
LANDMARK = {
    "farm": ("barn", (-2, -4, 1, 0)),
    "wheat": ("mill", (-1, -3, 1, 0)),
    "lake": ("lake", (-3, -2, 3, 2)),
}
LANDMARK_SPOTS = [(4, 5), (25, 5), (25, 26), (15, 27), (4, 12), (26, 26), (14, 2), (26, 15)]


def mirror_plan(p: dict) -> dict:
    q = dict(p)
    q["roads"] = [[(N - 1 - x, y) for x, y in r] for r in p["roads"]]
    return q


def road_cells(road: list) -> list:
    cells = []
    for (x0, y0), (x1, y1) in zip(road, road[1:]):
        if x0 != x1 and y0 != y1:
            raise ValueError(f"diagonal segment {(x0, y0)}→{(x1, y1)}")
        dx, dy = (x1 > x0) - (x1 < x0), (y1 > y0) - (y1 < y0)
        c = (x0, y0)
        while c != (x1, y1):
            cells.append(c)
            c = (c[0] + dx, c[1] + dy)
    cells.append(road[-1])
    return cells


# Plots: 5 + level/2; fences: 2 per road from level 2 (Twody: towers by the
# corners and close together, fences next to towers).
def plot_target(level: int) -> int:
    return 5 + level // 2


def corners(road: list) -> list:
    """Turn cells with the unit directions to the previous and next corner."""
    out = []
    for prev, c, nxt in zip(road, road[1:], road[2:]):
        a = ((prev[0] > c[0]) - (prev[0] < c[0]), (prev[1] > c[1]) - (prev[1] < c[1]))
        b = ((nxt[0] > c[0]) - (nxt[0] < c[0]), (nxt[1] > c[1]) - (nxt[1] < c[1]))
        out.append((c, a, b))
    return out


def layout(level: int, p: dict, mirrored: bool) -> dict:
    """Plots by road corners (inside the turn first, it covers both legs;
    then outside), nearest to the carrots first; fences on straight road
    cells next to plots."""
    q = dict(p)
    base_cells = {(N - 1 - x, y) for x, y in BASE_CELLS} if mirrored else BASE_CELLS
    hero = (N - 1 - HERO[0], HERO[1]) if mirrored else HERO
    road = set()
    for r in p["roads"]:
        road |= set(road_cells(r))
    busy = road | base_cells | {hero}
    spots = []
    for side in (1, -1):
        for r in p["roads"]:
            for i, (c, a, b) in enumerate(reversed(corners(r))):
                d = ((a[0] + b[0]) * side, (a[1] + b[1]) * side)
                xs = (c[0] + d[0], c[0] + 2 * d[0])
                ys = (c[1] + d[1], c[1] + 2 * d[1])
                spots.append((0 if side == 1 else 1, i, (max(xs), max(ys))))
    spots.sort()
    plots = []
    for _, _, (cx, cy) in spots:
        cover = {(cx - 1, cy - 1), (cx, cy - 1), (cx - 1, cy), (cx, cy)}
        if not all(1 <= x < N - 1 and 1 <= y < N - 1 for x, y in cover) or cover & busy:
            continue
        if any(((cx - px_) ** 2 + (cy - py_) ** 2) ** 0.5 < 2.5 for px_, py_ in plots):
            continue
        plots.append((cx, cy))
        busy |= cover
        if len(plots) >= plot_target(level):
            break
    q["plots"] = plots
    fences = []
    if level >= 2:
        for r in p["roads"]:
            cells = road_cells(r)
            turn = {c for c, _, _ in corners(r)}
            cand = []
            for k, c in enumerate(cells[3:-3], start=3):
                if c in turn or any(abs(c[0] - t[0]) + abs(c[1] - t[1]) <= 1 for t in turn):
                    continue
                near = min(((c[0] + 0.5 - x) ** 2 + (c[1] + 0.5 - y) ** 2) ** 0.5 for x, y in plots)
                if near <= 2.6:
                    cand.append((k / len(cells), c))
            picked = []
            for mark in (0.45, 0.8):
                left = [x for x in cand if all(abs(x[0] - y[0]) > 0.15 for y in picked)]
                if left:
                    picked.append(min(left, key=lambda x: abs(x[0] - mark)))
            fences += [c for _, c in picked]
    q["fences"] = fences
    return q


def check(level: int, p: dict, mirrored: bool) -> dict:
    """Plan rules; returns occupied cells for the decor."""
    base_cells = {(N - 1 - x, y) for x, y in BASE_CELLS} if mirrored else BASE_CELLS
    ends = {(N - 1 - x, y) for x, y in [(9, 23), (6, 21), (3, 23)]} if mirrored else {(9, 23), (6, 21), (3, 23)}
    road = set()
    for r in p["roads"]:
        cells = road_cells(r)
        x, y = r[0]
        assert x in (0, N - 1) or y in (0, N - 1), f"L{level}: road starts inside {r[0]}"
        assert r[-1] in ends, f"L{level}: road ends at {r[-1]}, not next to the bed"
        for c in cells:
            assert c not in base_cells, f"L{level}: road through the bed at {c}"
        road |= set(cells)
    for f in p["fences"]:
        assert f in road, f"L{level}: fence {f} not on a road"
    busy = set(road) | base_cells
    for cx, cy in p["plots"]:
        cover = {(cx - 1, cy - 1), (cx, cy - 1), (cx - 1, cy), (cx, cy)}
        hit = cover & busy
        assert not hit, f"L{level}: plot {(cx, cy)} on {sorted(hit)}"
        # Goose radius 220 px ≈ 3.4 cells from the plot centre (a grid corner).
        near = min(((a + 0.5 - cx) ** 2 + (b + 0.5 - cy) ** 2) ** 0.5 for a, b in road)
        assert near <= 3.6, f"L{level}: plot {(cx, cy)} far from roads ({near:.1f})"
        busy |= cover
    hero = (N - 1 - HERO[0], HERO[1]) if mirrored else HERO
    assert hero not in busy, f"L{level}: hero start is busy"
    busy.add(hero)
    # Keep one cell of grass around roads and plots free of decor.
    around = set()
    for x, y in busy:
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                around.add((x + dx, y + dy))
    return {"road": road, "busy": around, "hero": hero}


class Scene:
    def __init__(self) -> None:
        self.ext: list[str] = []
        self.ids: dict[str, str] = {}
        self.subs: list[str] = []
        self.nodes: list[str] = []

    def res(self, kind: str, path: str) -> str:
        if path not in self.ids:
            rid = f"{len(self.ids) + 1}_r"
            self.ids[path] = rid
            self.ext.append(f'[ext_resource type="{kind}" path="{path}" id="{rid}"]')
        return self.ids[path]

    def node(self, name: str, kind: str | None, parent: str | None, props: list[str], instance: str | None = None) -> None:
        head = f'[node name="{name}"'
        if kind:
            head += f' type="{kind}"'
        if parent is not None:
            head += f' parent="{parent}"'
        if instance:
            head += f' instance=ExtResource("{instance}")'
        self.nodes.append(head + "]\n" + "".join(p + "\n" for p in props))

    def text(self) -> str:
        return "[gd_scene format=3]\n\n" + "\n".join(self.ext) + "\n\n" + "\n".join(self.subs) + "\n" + "\n".join(self.nodes)


def px(c: tuple) -> tuple:
    return (c[0] * CELL + CELL // 2, c[1] * CELL + CELL // 2)


def v(p: tuple) -> str:
    return f"Vector2({p[0]:g}, {p[1]:g})"


def sprite(s: Scene, name: str, parent: str, kind: str, what: str, pos: tuple, off: float, frame: int = 0, extra=None) -> None:
    props = [f"position = {v(pos)}"]
    if kind == "anim":
        props += [f'sprite_frames = ExtResource("{s.res("SpriteFrames", "res://art/frames/env.tres")}")',
                  f'animation = &"{what}"', f'autoplay = "{what}"', f"frame = {frame}"]
        t = "AnimatedSprite2D"
    else:
        props.append(f'texture = ExtResource("{s.res("Texture2D", f"res://art/env/{what}.png")}")')
        t = "Sprite2D"
    props.append(f"offset = Vector2(0, {off:g})")
    s.node(name, t, parent, props + (extra or []))


def block(s: Scene, parent: str, size: tuple, at: tuple, sid: str) -> None:
    s.subs.append(f'[sub_resource type="RectangleShape2D" id="{sid}"]\nsize = {v(size)}\n')
    s.node("Block", "StaticBody2D", parent, [])
    s.node("Shape", "CollisionShape2D", f"{parent}/Block", [f"position = {v(at)}", f'shape = SubResource("{sid}")'])


def landmark(s: Scene, biome: str, cell: tuple) -> None:
    pos = px(cell)
    if biome == "farm":
        sprite(s, "Barn", "Decor", "tex", "env_farm_barn", pos, -108)
        block(s, "Decor/Barn", (180, 236), (0, -98), "Rect_landmark")
        s.node("Flag", "AnimatedSprite2D", "Decor/Barn", [
            f'sprite_frames = ExtResource("{s.res("SpriteFrames", "res://art/frames/env.tres")}")',
            'animation = &"env_farm_barn_flag"', 'autoplay = "env_farm_barn_flag"', "offset = Vector2(0, -108)"])
    elif biome == "wheat":
        sprite(s, "Mill", "Decor", "tex", "env_wheat_mill", pos, -108)
        block(s, "Decor/Mill", (110, 150), (0, -70), "Rect_landmark")
        s.node("Blades", "AnimatedSprite2D", "Decor/Mill", [
            f'sprite_frames = ExtResource("{s.res("SpriteFrames", "res://art/frames/env.tres")}")',
            'animation = &"env_wheat_mill_blades"', 'autoplay = "env_wheat_mill_blades"', "offset = Vector2(0, -108)"])
    else:
        # Lying flat: under the pests and the hero, not y-sorted with them.
        s.node("Lake", "Sprite2D", "Decor", [f"z_index = -5", f"position = {v(pos)}", "scale = Vector2(1.2, 1.2)",
                                             f'texture = ExtResource("{s.res("Texture2D", "res://art/env/env_lake_lake.png")}")'])
        block(s, "Decor/Lake", (330, 190), (0, 5), "Rect_landmark")
        s.node("Ripple", "AnimatedSprite2D", "Decor/Lake", [
            f'sprite_frames = ExtResource("{s.res("SpriteFrames", "res://art/frames/env.tres")}")',
            'animation = &"env_lake_ripple"', 'autoplay = "env_lake_ripple"'])
        s.node("Boat", "Sprite2D", "Decor/Lake", ["position = Vector2(60, 30)",
                                                  f'texture = ExtResource("{s.res("Texture2D", "res://art/env/env_lake_boat.png")}")'])


# Crops (CODE_PROMPT "Урожай фермы"): biome → (kind, fruit) by crop number, in turn
# (Twody: the hive by the lake together with the raspberries).
CROP_KIND = {"farm": [("apple_tree", "apple")], "wheat": [("pumpkin", "pumpkin")],
             "lake": [("raspberry", "raspberry"), ("hive", "honeycomb")]}
# The hero's pose at a crop (batch O).
CROP_HERO_ANIM = {"apple_tree": "shake", "raspberry": "shake", "pumpkin": "pick", "hive": "honey"}


# Crop distance from the nearest road cell, cells: min, max.
CROP_ROAD = (2.0, 5.0)


def crop_count(level: int) -> int:
    """From level 1 (Twody: something to find at once, several trees on
    different sides of the map): 3, 4 from level 7."""
    return 3 if level <= 6 else 4


def place_crops(s: Scene, level: int, biome: str, occ: dict) -> None:
    """3–4 crops on free grass, CROP_ROAD cells off the road (Twody: not
    only by it, but not far away either), three cells off the map edge: the first one close to the hero
    start so it is on the first screen, each next one among the free spots
    farthest from those already placed (different sides of the map). Marks
    their cells busy for the decor."""
    rng = random.Random(500 + level)
    scene = s.res("PackedScene", "res://scenes/battle/battle_crop.tscn")
    s.node("Crops", "Node2D", ".", ["y_sort_enabled = true"])
    busy = occ["busy"]
    hx, hy = occ["hero"]
    placed: list[tuple[int, int]] = []
    for i in range(crop_count(level)):
        cells = [(x, y) for y in range(3, N - 2) for x in range(3, N - 2)]
        rng.shuffle(cells)
        free = []
        for c in cells:
            cover = {(c[0] + dx, c[1] + dy) for dx in (-1, 0) for dy in (-1, 0)}
            if cover & busy:
                continue
            near = min(((a - c[0]) ** 2 + (b - c[1]) ** 2) ** 0.5 for a, b in occ["road"])
            if CROP_ROAD[0] <= near <= CROP_ROAD[1]:
                free.append(c)
        if not free:
            raise AssertionError(f"L{level}: no room for crop {i + 1}")
        if i == 0:
            c = min(free, key=lambda c: (c[0] - hx) ** 2 + (c[1] - hy) ** 2)
        else:
            # One of the farthest sixth: apart, but not always the same corners.
            free.sort(key=lambda c: -min((c[0] - a) ** 2 + (c[1] - b) ** 2 for a, b in placed))
            c = rng.choice(free[:max(1, len(free) // 6)])
        placed.append(c)
        kind, fruit = CROP_KIND[biome][i % len(CROP_KIND[biome])]
        empty = s.res("Texture2D", f"res://art/harvest/battle_{kind}_empty.png")
        cover = {(c[0] + dx, c[1] + dy) for dx in (-1, 0) for dy in (-1, 0)}
        s.node(f"Crop{i + 1}", None, "Crops", [f"position = {v((c[0] * CELL, c[1] * CELL + 20))}",
                                               f'kind = &"{kind}"', f'fruit = &"{fruit}"',
                                               f'hero_anim = &"{CROP_HERO_ANIM[kind]}"',
                                               f'empty_texture = ExtResource("{empty}")'], instance=scene)
        busy |= {(x + dx, y + dy) for x, y in cover for dx in (-1, 0, 1) for dy in (-1, 0, 1)}


def place_decor(s: Scene, level: int, biome: str, occ: dict) -> None:
    rng = random.Random(1000 + level)
    busy = set(occ["busy"])
    name, (x0, y0, x1, y1) = LANDMARK[biome]
    for spot in LANDMARK_SPOTS + [(x, y) for y in range(N) for x in range(N)]:
        cover = {(spot[0] + dx, spot[1] + dy) for dx in range(x0, x1 + 1) for dy in range(y0, y1 + 1)}
        if all(1 <= x < N - 1 and 1 <= y < N - 1 for x, y in cover) and not cover & busy:
            landmark(s, biome, spot)
            busy |= {(x + dx, y + dy) for x, y in cover for dx in (-1, 0, 1) for dy in (-1, 0, 1)}
            break
    else:
        raise AssertionError(f"L{level}: no room for the {name}")
    # No bee skeps by the lake (Twody: what looks collectible is collectible — the hive is a crop).
    counts: dict[str, int] = {}
    for key in BIOME_DECOR[biome]:
        kind, what, off, w, h = DECOR[key]
        for _ in range(300):
            c = (rng.randrange(0, N - w + 1), rng.randrange(1, N))
            cover = {(c[0] + dx, c[1] - dy) for dx in range(w) for dy in range(h)}
            if cover & busy:
                continue
            counts[key] = counts.get(key, 0) + 1
            p = (c[0] * CELL + w * CELL // 2, c[1] * CELL + CELL - 8)
            sprite(s, f"{key.title().replace('_', '')}{counts[key]}", "Decor", kind, what, p, off, rng.randrange(3))
            busy |= {(x + dx, y + dy) for x, y in cover for dx in (-1, 0, 1) for dy in (-1, 0, 1)}
            break


def make_scene(level: int, p: dict, occ: dict, mirrored: bool) -> str:
    s = Scene()
    s.res("Script", "res://scenes/levels/level.gd")
    data = s.res("Resource", f"res://data/levels/level_{level:02d}.tres")
    tiles = s.res("TileSet", f"res://art/tiles/tiles_{p['biome']}.tres")
    base = s.res("PackedScene", "res://scenes/battle/base.tscn")
    plot = s.res("PackedScene", "res://scenes/battle/build_plot.tscn")
    env = s.res("SpriteFrames", "res://art/frames/env.tres")
    s.node(f"Level{level:02d}", "Node2D", None, ["y_sort_enabled = true", 'script = ExtResource("1_r")', f'data = ExtResource("{data}")'])
    s.node("Ground", "TileMapLayer", ".", ["z_index = -10", f'tile_set = ExtResource("{tiles}")'])
    s.node("Roads", "Node2D", ".", [])
    for i, r in enumerate(p["roads"]):
        pts = []
        for c in r:
            x, y = px(c)
            pts += ["0.0", "0.0", "0.0", "0.0", f"{x}.0", f"{y}.0"]
        s.subs.append(f'[sub_resource type="Curve2D" id="Curve2D_road{i + 1}"]\n_data = {{\n"points": PackedVector2Array({", ".join(pts)})\n}}\npoint_count = {len(r)}\n')
        s.node(f"Road{i + 1}", "Path2D", "Roads", [f'curve = SubResource("Curve2D_road{i + 1}")'])
    for i, r in enumerate(p["roads"]):
        x, y = px(r[0])
        # The burrow sits on the field edge where the road comes in.
        y = max(y, 44)
        s.node("Spawn" if i == 0 else f"Spawn{i + 1}", "AnimatedSprite2D", ".", [
            f"position = {v((x, y))}", f'sprite_frames = ExtResource("{env}")', 'animation = &"spawn_burrow_idle"',
            "offset = Vector2(0, -38)"])
    bx = N * CELL - BASE[0] if mirrored else BASE[0]
    s.node("Base", None, ".", [f"position = {v((bx, BASE[1]))}"], instance=base)
    s.node("HeroStart", "Marker2D", ".", [f"position = {v(px(occ['hero']))}"])
    s.node("Plots", "Node2D", ".", ["y_sort_enabled = true"])
    for i, (cx, cy) in enumerate(p["plots"]):
        s.node(f"Plot{i + 1}", None, "Plots", [f"position = {v((cx * CELL, cy * CELL))}"], instance=plot)
    for i, f in enumerate(p["fences"]):
        s.node(f"FencePlot{i + 1}", None, "Plots", [f"position = {v(px(f))}", "fence_plot = true"], instance=plot)
    place_crops(s, level, p["biome"], occ)
    s.node("Decor", "Node2D", ".", ["y_sort_enabled = true"])
    place_decor(s, level, p["biome"], occ)
    return s.text()


def make_data(level: int, p: dict) -> str:
    rng = random.Random(level)
    ext = ['[ext_resource type="Script" path="res://data/types/level_data.gd" id="1_level"]',
           '[ext_resource type="Script" path="res://data/types/wave_data.gd" id="2_wave"]',
           '[ext_resource type="Script" path="res://data/types/wave_group.gd" id="3_group"]',
           '[ext_resource type="Script" path="res://data/types/defender_data.gd" id="4_def"]']
    for e in list(ENEMY_HP) + ["fox"]:
        ext.append(f'[ext_resource type="Resource" path="res://data/enemies/{e}.tres" id="e_{e}"]')
    defenders = [d for d, lv in DEFENDER_UNLOCK if lv <= level]
    for d in defenders:
        ext.append(f'[ext_resource type="Resource" path="res://data/defenders/{d}.tres" id="d_{d}"]')
    roads = len(p["roads"])
    waves = p["waves"]
    growth = LAST_OVER_FIRST ** (1.0 / (waves - 1))
    first = FIRST_WAVE_HP * (1.0 + FIRST_WAVE_GROWTH * (level - 1))
    subs: list[str] = []
    wave_ids: list[str] = []
    for w in range(1, waves + 1):
        budget = first * growth ** (w - 1)
        # Types in play: a type new on this level joins from wave 2.
        mix = {k: share for k, (lv, share) in ENEMY_MIX.items() if lv < level or (lv == level and w >= 2)}
        mix["beetle"] = 1.0 - sum(mix.values())
        groups: list[str] = []
        spread = 12.0 + 2.0 * w
        k = 0
        for enemy, share in mix.items():
            total = max(1, round(budget * share / ENEMY_HP[enemy]))
            per_road = [total // roads + (1 if i < total % roads else 0) for i in range(roads)]
            for road, count in enumerate(per_road):
                if count <= 0:
                    continue
                gid = f"G_{w}_{len(groups) + 1}"
                interval = min(1.2, max(0.25, spread / count))
                subs.append(f'[sub_resource type="Resource" id="{gid}"]\nscript = ExtResource("3_group")\n'
                            f'enemy = ExtResource("e_{enemy}")\ncount = {count}\ninterval = {interval:.2f}\n'
                            f'road = {road}\ndelay = {3.0 * k + rng.uniform(0.0, 1.5):.1f}\n')
                groups.append(gid)
            k += 1
        if w == waves:
            gid = f"G_{w}_boss"
            subs.append(f'[sub_resource type="Resource" id="{gid}"]\nscript = ExtResource("3_group")\n'
                        f'enemy = ExtResource("e_fox")\ncount = 1\ninterval = 1.0\nroad = {rng.randrange(roads)}\n'
                        f'delay = {spread + 4.0:.1f}\nhp_scale = {FOX_SCALE[level]}\n')
            groups.append(gid)
        wid = f"W_{w}"
        subs.append(f'[sub_resource type="Resource" id="{wid}"]\nscript = ExtResource("2_wave")\n'
                    f'groups = Array[ExtResource("3_group")]([{", ".join(f"SubResource(\"{g}\")" for g in groups)}])\n')
        wave_ids.append(wid)
    start_coins = 10 + 5 * (roads - 1)
    res = ("[resource]\nscript = ExtResource(\"1_level\")\n"
           f"number = {level}\nstart_coins = {start_coins}\ncarrots = 20\n"
           f"defenders = Array[ExtResource(\"4_def\")]([{', '.join(f'ExtResource(\"d_{d}\")' for d in defenders)}])\n"
           f"waves = Array[ExtResource(\"2_wave\")]([{', '.join(f'SubResource(\"{w}\")' for w in wave_ids)}])\n"
           "wave_pause = 20.0\nfirst_pause = 10.0\n")
    return '[gd_resource type="Resource" script_class="LevelData" format=3]\n\n' + "\n".join(ext) + "\n\n" + "\n".join(subs) + "\n" + res


def main() -> int:
    only = [int(a) for a in sys.argv[1:] if a.isdigit()] or sorted(PLANS)
    if "--check" in sys.argv:
        bad = 0
        for level in sorted(PLANS):
            plan = PLANS[level]
            p = layout(level, mirror_plan(plan) if plan["mirror"] else plan, plan["mirror"])
            try:
                check(level, p, plan["mirror"])
            except AssertionError as e:
                print(e)
                bad += 1
        return bad
    for level in only:
        plan = PLANS[level]
        p = layout(level, mirror_plan(plan) if plan["mirror"] else plan, plan["mirror"])
        occ = check(level, p, plan["mirror"])
        (ROOT / "scenes" / "levels" / f"level_{level:02d}.tscn").write_text(make_scene(level, p, occ, plan["mirror"]), encoding="utf-8", newline="\n")
        if plan.get("data", True):
            (ROOT / "data" / "levels" / f"level_{level:02d}.tres").write_text(make_data(level, p), encoding="utf-8", newline="\n")
        print(f"level {level:2d}: {p['biome']}, {len(p['roads'])} roads, {len(p['plots'])} plots, {len(p['fences'])} fences")
    return 0


if __name__ == "__main__":
    sys.exit(main())
