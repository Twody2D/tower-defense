"""Farm map scene (design L, "Партия L - Меню и карта.dc.html"): writes
tower-defense/scenes/map/map.tscn from the mockup data below (copied from the
mockup's page code: NODES, ROUTE, DEC, CROPS, clouds). Portrait coordinates,
1080 × 5760, level 1 at the bottom; map.gd moves every piece for landscape.

Run: py -3.14 tools/make_map.py   (then open the scene in the editor to look)
"""
import math
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent / "tower-defense"
ART = ROOT / "art"

NODES = [(300, 5480), (700, 5220), (820, 4880), (460, 4620), (300, 4260), (760, 3560), (420, 3280), (300, 2900),
         (720, 2560), (360, 1560), (740, 1120), (500, 600)]
BRIDGES = [(540, 3846), (540, 1926)]
ROUTE = NODES[:5] + [BRIDGES[0]] + NODES[5:9] + [BRIDGES[1]] + NODES[9:]
FOX = {5, 10, 12}
# (picture: env texture or env.tres animation, centre x, y, drawn w, h, animated)
# Twody: no apple trees with apples just for looks — the map's apple tree is the crop.
DEC = [("env_farm_barn", 900, 5580, 256, 256, False), ("env_farm_barn_flag", 900, 5580, 256, 256, True),
       ("env_farm_scarecrow_sway", 560, 5560, 96, 128, True), ("env_farm_haystack", 960, 5000, 96, 96, False),
       ("env_tree_pine_sway", 110, 4880, 128, 128, True), ("env_farm_bed", 620, 4400, 128, 96, False),
       ("env_bush", 940, 4460, 96, 96, False), ("env_rocks", 160, 5700, 64, 64, False),
       ("env_sunflower_sway", 70, 4130, 64, 96, True), ("env_sunflower_sway", 130, 4150, 64, 96, True),
       ("env_farm_wheelbarrow", 900, 4150, 96, 96, False), ("env_tree_pine_sway", 980, 5260, 128, 128, True),
       ("env_wheat_mill", 200, 3620, 256, 256, False), ("env_wheat_mill_blades", 200, 3620, 256, 256, True),
       ("env_wheat_sheaf", 620, 3120, 96, 96, False), ("env_wheat_cart", 940, 2820, 128, 128, False),
       ("env_wheat_ears_sway", 900, 3300, 64, 64, True), ("env_wheat_ears_sway", 960, 3350, 64, 64, True),
       ("env_wheat_ears_sway", 120, 2380, 64, 64, True), ("env_wheat_ears_sway", 180, 2420, 64, 64, True),
       ("env_wheat_ears_sway", 540, 2760, 64, 64, True), ("env_sunflower_sway", 980, 2300, 64, 96, True),
       ("env_lake_lake", 700, 1560, 384, 256, False), ("env_lake_ripple", 700, 1560, 384, 256, True),
       ("env_lake_reeds_sway", 520, 1440, 64, 96, True), ("env_lake_skep", 150, 1000, 96, 96, False),
       ("env_lake_skep_bees", 150, 1000, 96, 96, True), ("env_tree_pine_sway", 900, 420, 128, 128, True),
       ("env_tree_pine_sway", 160, 300, 128, 128, True), ("env_lake_pier", 880, 1720, 128, 96, False)]
# The pumpkins moved off the level 6 sign (mockup: 900, 3500 — the bubble covered it).
CROPS = [("wheat", 130, 5260), ("apple", 560, 4860), ("pumpkin", 170, 3200), ("apiary", 820, 820)]
# Clouds over a closed zone: (variant, centre x, y); drawn 640 × 320 (512 × 256 × 1.25).
CLOUDS = {
    "CloudsWheat": [(1, 260, 3500), (2, 800, 3280), (1, 300, 2760), (2, 780, 2420), (1, 540, 3040)],
    "CloudsLake": [(1, 260, 1650), (2, 800, 1420), (1, 300, 1000), (2, 820, 700), (1, 240, 360), (2, 700, 180),
                   (1, 560, 1200)],
}
CLOUD_SCALE = 1.25
# Twody: a closed zone is greyer — a haze over its band (shaders/haze.tres)
# under greyish clouds. Zone band: top, bottom (portrait y).
ZONE_BANDS = {"CloudsWheat": (1920, 3840), "CloudsLake": (0, 1920)}
CLOUD_TINT = "Color(0.88, 0.9, 0.95, 1)"


class Scene:
    def __init__(self) -> None:
        self.ext: list[str] = []
        self.ids: dict[str, str] = {}
        self.nodes: list[str] = []

    def res(self, kind: str, path: str) -> str:
        if path not in self.ids:
            rid = f"{len(self.ids) + 1}_m"
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
        return "[gd_scene format=3]\n\n" + "\n".join(self.ext) + "\n\n" + "\n".join(self.nodes)


def v(x: float, y: float) -> str:
    return f"Vector2({x:g}, {y:g})"


def frame_width(name: str, animated: bool) -> int:
    """Width of one frame of an env picture (sheets: <name>_<n>f.png)."""
    if not animated:
        return Image.open(ART / "env" / f"{name}.png").width
    for f in (ART / "env").glob(f"{name}_*f.png"):
        n = int(f.stem.rsplit("_", 1)[1][:-1])
        return Image.open(f).width // n
    raise FileNotFoundError(name)


def main() -> int:
    s = Scene()
    script = s.res("Script", "res://scenes/map/map.gd")
    windows = {k: s.res("PackedScene", f"res://scenes/ui/windows/{k}.tscn") for k in
               ("settings_window", "level_start_window", "shop_window", "gift_window", "harvest_window")}
    s.node("Map", "Control", None, [f'script = ExtResource("{script}")'] +
           [f'{k} = ExtResource("{r}")' for k, r in windows.items()] +
           ["layout_mode = 3", "anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
            "grow_horizontal = 2", "grow_vertical = 2", "mouse_filter = 2"])
    s.node("Sky", "ColorRect", ".", ["layout_mode = 1", "anchors_preset = 15", "anchor_right = 1.0",
                                     "anchor_bottom = 1.0", "mouse_filter = 2", "color = Color(0.298, 0.686, 0.314, 1)"])
    s.node("World", "Node2D", ".", [])
    s.node("Bands", "Node2D", "World", [])
    for name, biome, top, bottom in (("Lake", "lake", 0, 1920), ("Wheat", "wheat", 1920, 3840), ("Farm", "farm", 3840, 5760)):
        tex = s.res("Texture2D", f"res://art/env/tile_{biome}_grass_1.png")
        s.node(name, "TextureRect", "World/Bands", [f"offset_top = {top}.0", "offset_right = 1080.0",
                                                    f"offset_bottom = {bottom}.0", "mouse_filter = 2",
                                                    f'texture = ExtResource("{tex}")', "stretch_mode = 1"])
    # Pieces that turn 90° in landscape: the river strips and the bridges.
    s.node("Turned", "Node2D", "World", [])
    for name, pic, y in (("StripWheatLake", "map_strip_wheat_lake", 1792), ("StripFarmWheat", "map_strip_farm_wheat", 3712)):
        tex = s.res("Texture2D", f"res://art/map/{pic}.png")
        s.node(name, "Sprite2D", "World/Turned", [f"position = {v(540, y + 128)}", f'texture = ExtResource("{tex}")'])
    bridge = s.res("Texture2D", "res://art/map/map_bridge.png")
    for i, (x, y) in enumerate(BRIDGES):
        s.node(f"Bridge{i + 1}", "Sprite2D", "World/Turned", [f"position = {v(x, y)}", f'texture = ExtResource("{bridge}")'])
    # The trodden path: soft patches every 20 px, a stepping stone every 4th.
    s.node("Path", "Node2D", "World", [])
    patch = s.res("Texture2D", "res://art/map/map_path_patch.png")
    stone = s.res("Texture2D", "res://art/map/map_path_stone.png")
    k = 0
    for (ax, ay), (bx, by) in zip(ROUTE, ROUTE[1:]):
        n = math.ceil(math.hypot(bx - ax, by - ay) / 20)
        for j in range(n + (1 if (bx, by) == ROUTE[-1] else 0)):
            q = j / n
            cx, cy = ax + (bx - ax) * q, ay + (by - ay) * q
            k += 1
            s.node(f"P{k}", "Sprite2D", "World/Path", [f"position = {v(round(cx), round(cy))}", f'texture = ExtResource("{patch}")'])
            if j % 4 == 2:
                dx = 16 if (j // 4) % 2 else -16
                s.node(f"S{k}", "Sprite2D", "World/Path", [f"position = {v(round(cx + dx), round(cy))}",
                                                            "scale = Vector2(0.75, 0.75)", f'texture = ExtResource("{stone}")'])
    s.node("Decor", "Node2D", "World", [])
    env = s.res("SpriteFrames", "res://art/frames/env.tres")
    for i, (pic, x, y, w, h, anim) in enumerate(DEC):
        sc = round(w / frame_width(pic, anim), 3)
        props = [f"position = {v(x, y)}", f"scale = {v(sc, sc)}"]
        if anim:
            s.node(f"D{i + 1}", "AnimatedSprite2D", "World/Decor", props + [f'sprite_frames = ExtResource("{env}")',
                                                                            f'animation = &"{pic}"', f'autoplay = "{pic}"',
                                                                            f"frame = {i % 3}"])
        else:
            tex = s.res("Texture2D", f"res://art/env/{pic}.png")
            s.node(f"D{i + 1}", "Sprite2D", "World/Decor", props + [f'texture = ExtResource("{tex}")'])
    s.node("Crops", "Node2D", "World", [])
    crop = s.res("PackedScene", "res://scenes/map/map_crop.tscn")
    for cid, x, y in CROPS:
        s.node(cid.title(), None, "World/Crops", [f"offset_left = {x - 96}.0", f"offset_top = {y - 96}.0",
                                                  f"offset_right = {x + 96}.0", f"offset_bottom = {y + 96}.0",
                                                  f'crop_id = &"{cid}"'], instance=crop)
    s.node("Nodes", "Node2D", "World", [])
    node = s.res("PackedScene", "res://scenes/map/map_node.tscn")
    for i, (x, y) in enumerate(NODES):
        # The sign stands on its point: its box is 40 px higher (mockup).
        cy = y - 40
        props = [f"offset_left = {x - 80}.0", f"offset_top = {cy - 80}.0", f"offset_right = {x + 80}.0",
                 f"offset_bottom = {cy + 80}.0", f"level = {i + 1}"]
        if i + 1 in FOX:
            props.append("fox = true")
        s.node(f"Level{i + 1}", None, "World/Nodes", props, instance=node)
    frames = s.res("SpriteFrames", "res://art/frames/map.tres")
    haze = s.res("Material", "res://shaders/haze.tres")
    for group, clouds in CLOUDS.items():
        s.node(group, "Node2D", "World", [])
        top, bottom = ZONE_BANDS[group]
        s.node("Haze", "ColorRect", f"World/{group}", [f"offset_top = {top}.0", "offset_right = 1080.0",
                                                       f"offset_bottom = {bottom}.0", "mouse_filter = 2",
                                                       f'material = ExtResource("{haze}")'])
        for i, (var, x, y) in enumerate(clouds):
            s.node(f"Cloud{i + 1}", "AnimatedSprite2D", f"World/{group}", [
                f"modulate = {CLOUD_TINT}",
                f"position = {v(x, y)}", f"scale = {v(CLOUD_SCALE, CLOUD_SCALE)}", f'sprite_frames = ExtResource("{frames}")',
                f'animation = &"cloud_{var}_sway"', f'autoplay = "cloud_{var}_sway"', f"frame = {i % 3}"])
    # HUD (design L: grains; shop, settings, gift on the right).
    counter = s.res("PackedScene", "res://scenes/ui/counter.tscn")
    rb = s.res("PackedScene", "res://scenes/ui/round_button.tscn")
    s.node("Grains", None, ".", ["unique_name_in_owner = true", "layout_mode = 0", "offset_left = 44.0",
                                 "offset_top = 40.0", "offset_right = 304.0", "offset_bottom = 104.0"], instance=counter)
    for name, icon, left, extra in (("Shop", "ui_icon_shop", -372, []), ("Settings", "ui_icon_settings", -256, []),
                                    ("Gift", "ui_icon_gift", -140, ['icon_anim = &"icon_gift_shake"', "badge = true"])):
        tex = s.res("Texture2D", f"res://art/ui/{icon}.png")
        s.node(name, None, ".", ["unique_name_in_owner = true", "layout_mode = 1", "anchors_preset = 1",
                                 "anchor_left = 1.0", "anchor_right = 1.0", f"offset_left = {left}.0",
                                 "offset_top = 30.0", f"offset_right = {left + 96}.0", "offset_bottom = 126.0",
                                 "grow_horizontal = 0", f'icon = ExtResource("{tex}")'] + extra, instance=rb)
    out = ROOT / "scenes" / "map" / "map.tscn"
    out.write_text(s.text(), encoding="utf-8", newline="\n")
    print(f"map: {len(s.nodes)} nodes, {k} path patches")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
