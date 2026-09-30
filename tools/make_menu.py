"""Main menu scene (design L, "Партия L - Меню и карта.dc.html", menu(P)):
writes tower-defense/scenes/ui/main_menu.tscn — a farm yard (sand, house
with smoke, trees, fences, the wheat and apple crops with "ripe" bubbles,
butterflies), the hero, logo, "Play" and five round buttons. The yard is
drawn once per orientation (Stage metadata "only"); the rest moves by the
Stage "portrait" metadata. Mockup numbers are top-left corners and sizes.

Run: py -3.14 tools/make_menu.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent / "tower-defense"
ART = ROOT / "art"

# Twody: no apple trees with apples just for looks — the yard's apple tree is the crop.
YARD = {
    "Portrait": dict(
        sand=(2, 13, 14, 20), fences=[(150, 700), (790, 700)],
        house=(290, 520, 1.95), trees=[(-24, 640, 176), (936, 660, 150)],
        crops=[("wheat", 30, 1020, 1.15), ("apple", 820, 960, 1.15)],
        props=[("env_farm_haystack", 900, 1250, 130, 130), ("env_farm_wheelbarrow", 640, 1260, 110, 110)],
        sunflowers=[(40, 1270), (100, 1290)], flies=[(760, 900, 120, 40, 0.8, 0.0), (220, 1180, 90, 30, 1.1, 2.0)]),
    "Landscape": dict(
        sand=(12, 8, 29, 16), fences=[(866, 380), (1516, 380)],
        house=(1060, 110, 1.75), trees=[(700, 290, 180), (1676, 320, 160)],
        crops=[("wheat", 760, 610, 1.1), ("apple", 1680, 560, 1.1)],
        props=[("env_farm_haystack", 1560, 860, 130, 130), ("env_rocks", 700, 960, 64, 64)],
        sunflowers=[(40, 900), (110, 920)], flies=[(1500, 520, 120, 40, 0.8, 0.0), (980, 840, 90, 30, 1.1, 2.0)]),
}
# Hero (330 drawn, frames 384) and its shadow: landscape / portrait top-left.
HERO = {"Landscape": (1165, 526), "Portrait": (375, 910)}
HERO_SIZE = 330
# Lowest drawn pixel of the pictures (frame 384 / 256 / 256): shadows go there.
HERO_FEET = 359
HOUSE_BASE = 240
PINE_BASE = 251
LOGO = {"Landscape": (60, 40, 700), "Portrait": (90, 130, 900)}
PLAY = {"Landscape": (150, 400, 520), "Portrait": (300, 1430, 480)}
BUTTONS = [("Shop", "ui_icon_shop", "BTN_SHOP", ""), ("Gift", "ui_icon_gift", "BTN_GIFT", "icon_gift_shake"),
           ("Harvest", "ui_icon_gift", "BTN_HARVEST", "icon_harvest_ripe"),
           ("Settings", "ui_icon_settings", "BTN_SETTINGS", ""), ("HowTo", "ui_icon_howto", "BTN_HOW_TO", "")]
BUTTON_X = {"Landscape": [60, 212, 364, 516, 668], "Portrait": [40, 250, 460, 670, 880]}
BUTTON_Y = {"Landscape": 620, "Portrait": 1640}
BUTTON_SIZE = {"Landscape": 104, "Portrait": 112}
GRAINS = {"Landscape": (1620, 30), "Portrait": (60, 44)}


class Scene:
    def __init__(self) -> None:
        self.ext: list[str] = []
        self.ids: dict[str, str] = {}
        self.nodes: list[str] = []

    def res(self, kind: str, path: str) -> str:
        if path not in self.ids:
            rid = f"{len(self.ids) + 1}_u"
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


def frame_size(path: Path, frames: int = 1) -> tuple[int, int]:
    w, h = Image.open(path).size
    return w // frames, h


def sand_tile(c: int, r: int, c0: int, r0: int, c1: int, r1: int) -> str:
    """The mockup's yard(): outer corners and edges of a sand patch."""
    top, bottom, left, right = r == r0, r == r1, c == c0, c == c1
    if top and left:
        return "outer_br"
    if top and right:
        return "outer_bl"
    if bottom and left:
        return "outer_tr"
    if bottom and right:
        return "outer_tl"
    return "edge_b" if top else "edge_t" if bottom else "edge_r" if left else "edge_l" if right else "fill"


def yard(s: Scene, group: str, d: dict) -> None:
    parent = f"Stage/{group}"
    s.node(group, "Node2D", "Stage", ["y_sort_enabled = true", f'metadata/only = "{group.lower()}"'])
    # The sand lies under everything: its own layer at y 0 sorts first.
    s.node("Sand", "Node2D", parent, [])
    c0, r0, c1, r1 = d["sand"]
    for r in range(r0, r1 + 1):
        for c in range(c0, c1 + 1):
            tex = s.res("Texture2D", f"res://art/env/tile_farm_sand_{sand_tile(c, r, c0, r0, c1, r1)}.png")
            s.node(f"T{c}_{r}", "Sprite2D", f"{parent}/Sand", [f"position = {v(c * 64 + 32, r * 64 + 32)}",
                                                               f'texture = ExtResource("{tex}")'])
    env = s.res("SpriteFrames", "res://art/frames/env.tres")
    frames = s.res("SpriteFrames", "res://art/frames/map.tres")
    # Fences and pines stand on their bottom edge (position = base, the
    # picture above it): the y-sort puts a tree in front of a fence behind it.
    fence = s.res("Texture2D", "res://art/hi/env_fence_decor.png")
    fw, fh = frame_size(ART / "hi" / "env_fence_decor.png")
    for i, (x, y) in enumerate(d["fences"]):
        s.node(f"Fence{i + 1}", "Sprite2D", parent, [f"position = {v(x + 72, y + 96)}", f"scale = {v(144 / fw, 96 / fh)}",
                                                     f'texture = ExtResource("{fence}")', f"offset = {v(0, -fh / 2)}"])
    shadow = s.res("Texture2D", "res://art/ui/shadow.png")
    hx, hy, k = d["house"]
    house = s.res("Texture2D", "res://art/env/env_house.png")
    s.node("House", "Sprite2D", parent, [f"position = {v(hx + 128 * k, hy + 128 * k)}", f"scale = {v(k, k)}",
                                         f'texture = ExtResource("{house}")'])
    # Shadows are children drawn behind their picture (a sibling shadow sorts
    # by its own y and covers the bottom of the house); they sit on the base.
    s.node("Shadow", "Sprite2D", f"{parent}/House", ["show_behind_parent = true", f"position = {v(0, HOUSE_BASE - 128 - 4)}",
                                                    f"scale = {v(220 / 128, 220 * 0.18 / 32)}", f'texture = ExtResource("{shadow}")'])
    s.node("Smoke", "AnimatedSprite2D", parent, [
        f"position = {v(hx + 181 * k, hy + 28 * k - 112 + 57)}", f"scale = {v(76 / 64, 114 / 96)}",
        f'sprite_frames = ExtResource("{frames}")', 'animation = &"chimney_smoke"', 'autoplay = "chimney_smoke"'])
    hi = s.res("SpriteFrames", "res://art/frames/ui_hi.tres")
    pw, _ = frame_size(ART / "hi" / "env_tree_pine_sway_3f.png", 3)
    for i, (x, y, size) in enumerate(d["trees"]):
        s.node(f"Pine{i + 1}", "AnimatedSprite2D", parent, [
            f"position = {v(x + size / 2, y + size)}", f"scale = {v(size / pw, size / pw)}", f"offset = {v(0, -pw / 2)}",
            f'sprite_frames = ExtResource("{hi}")', 'animation = &"pine_sway"', 'autoplay = "pine_sway"',
            f"frame = {i}"])
        s.node("Shadow", "Sprite2D", f"{parent}/Pine{i + 1}", ["show_behind_parent = true", f"position = {v(0, PINE_BASE - pw - 4)}",
                                                              f"scale = {v(140 / 128, 140 * 0.24 / 32)}", f'texture = ExtResource("{shadow}")'])
    for name, x, y, w, h in d["props"]:
        tex = s.res("Texture2D", f"res://art/env/{name}.png")
        tw, th = frame_size(ART / "env" / f"{name}.png")
        s.node(name.removeprefix("env_").title().replace("_", ""), "Sprite2D", parent, [
            f"position = {v(x + w / 2, y + h / 2)}", f"scale = {v(w / tw, h / th)}", f'texture = ExtResource("{tex}")'])
    sw_, sh_ = frame_size(ART / "env" / "env_sunflower_sway_3f.png", 3)
    for i, (x, y) in enumerate(d["sunflowers"]):
        s.node(f"Sunflower{i + 1}", "AnimatedSprite2D", parent, [
            f"position = {v(x + 32, y + 48)}", f"scale = {v(64 / sw_, 96 / sh_)}", f'sprite_frames = ExtResource("{env}")',
            'animation = &"env_sunflower_sway"', 'autoplay = "env_sunflower_sway"', f"frame = {i * 2 % 3}"])
    crop = s.res("PackedScene", "res://scenes/map/map_crop.tscn")
    for cid, x, y, k in d["crops"]:
        s.node(f"Crop{cid.title()}", None, parent, [f"offset_left = {x}.0", f"offset_top = {y}.0",
                                                     f"offset_right = {x + 192}.0", f"offset_bottom = {y + 192}.0",
                                                     f"scale = {v(k, k)}", f'crop_id = &"{cid}"'], instance=crop)
    fly = s.res("Script", "res://scenes/ui/butterfly.gd")
    for i, (cx, cy, rx, ry, sp, off) in enumerate(d["flies"]):
        s.node(f"Butterfly{i + 1}", "AnimatedSprite2D", parent, [
            f'sprite_frames = ExtResource("{frames}")', 'animation = &"butterfly"', f'script = ExtResource("{fly}")',
            f"centre = {v(cx, cy)}", f"radius = {v(rx, ry)}", f"speed = {sp}", f"phase = {off}"])


def main() -> int:
    s = Scene()
    script = s.res("Script", "res://scenes/ui/main_menu.gd")
    windows = {k: s.res("PackedScene", f"res://scenes/ui/windows/{k}.tscn") for k in
               ("settings_window", "shop_window", "gift_window", "how_to_window", "harvest_window")}
    s.node("MainMenu", "Control", None, [f'script = ExtResource("{script}")'] +
           [f'{k} = ExtResource("{r}")' for k, r in windows.items()] +
           ["layout_mode = 3", "anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
            "grow_horizontal = 2", "grow_vertical = 2"])
    grass = s.res("Texture2D", "res://art/env/tile_farm_grass_1.png")
    s.node("Grass", "TextureRect", ".", ["layout_mode = 1", "anchors_preset = 15", "anchor_right = 1.0", "anchor_bottom = 1.0",
                                         "grow_horizontal = 2", "grow_vertical = 2", "mouse_filter = 2",
                                         f'texture = ExtResource("{grass}")', "stretch_mode = 1"])
    stage = s.res("Script", "res://scenes/ui/stage.gd")
    s.node("Stage", "Control", ".", ["layout_mode = 0", "offset_right = 1920.0", "offset_bottom = 1080.0",
                                     "mouse_filter = 2", f'script = ExtResource("{stage}")'])
    for group, d in YARD.items():
        yard(s, group, d)
    # Hero: centre of the 330 box, shadow under the feet.
    lx, ly = HERO["Landscape"]
    px_, py_ = HERO["Portrait"]
    half = HERO_SIZE / 2
    s.node("Hero", "Node2D", "Stage", [f"position = {v(lx + half, ly + half)}",
                                       f"metadata/portrait = {v(px_ + half, py_ + half)}"])
    shadow = s.res("Texture2D", "res://art/ui/shadow.png")
    s.node("Shadow", "Sprite2D", "Stage/Hero", [f"position = {v(0, round((HERO_FEET - 192) * HERO_SIZE / 384) - 6)}", f"scale = {v(170 / 128, 170 * 0.24 / 32)}",
                                                f'texture = ExtResource("{shadow}")'])
    hero = s.res("SpriteFrames", "res://art/frames/hero_raccoon_ui.tres")
    k = HERO_SIZE / 384
    s.node("Sprite", "AnimatedSprite2D", "Stage/Hero", [f"scale = {v(round(k, 4), round(k, 4))}", f'sprite_frames = ExtResource("{hero}")',
                                                        'animation = &"idle"', 'autoplay = "idle"'])
    logo = s.res("PackedScene", "res://scenes/ui/logo.tscn")
    lx, ly, lw = LOGO["Landscape"]
    px_, py_, pw = LOGO["Portrait"]
    s.node("Logo", None, "Stage", ["layout_mode = 0", f"offset_left = {lx}", f"offset_top = {ly}", f"offset_right = {lx + 960}",
                                   f"offset_bottom = {ly + 440}", f"scale = {v(round(lw / 960, 4), round(lw / 960, 4))}",
                                   f"metadata/portrait = Rect2({px_}, {py_}, 960, 440)",
                                   f"metadata/portrait_scale = {v(round(pw / 960, 4), round(pw / 960, 4))}"], instance=logo)
    lx, ly, lw = PLAY["Landscape"]
    px_, py_, pw = PLAY["Portrait"]
    s.node("Play", "Button", "Stage", ["unique_name_in_owner = true", "layout_mode = 0", f"offset_left = {lx}",
                                       f"offset_top = {ly}", f"offset_right = {lx + lw}", f"offset_bottom = {ly + 128}",
                                       "focus_mode = 0", "theme_override_font_sizes/font_size = 56", 'text = "BTN_PLAY"',
                                       f"metadata/portrait = Rect2({px_}, {py_}, {pw}, 128)"])
    rb = s.res("PackedScene", "res://scenes/ui/round_button.tscn")
    for i, (name, icon, label, anim) in enumerate(BUTTONS):
        tex = s.res("Texture2D", f"res://art/ui/{icon}.png")
        lx, px_ = BUTTON_X["Landscape"][i], BUTTON_X["Portrait"][i]
        ks = BUTTON_SIZE["Landscape"] / 112
        props = ["unique_name_in_owner = true", "layout_mode = 0", f"offset_left = {lx}", f"offset_top = {BUTTON_Y['Landscape']}",
                 f"offset_right = {lx + 112}", f"offset_bottom = {BUTTON_Y['Landscape'] + 112}", f"scale = {v(round(ks, 4), round(ks, 4))}",
                 f'icon = ExtResource("{tex}")', f'label_key = "{label}"',
                 f"metadata/portrait = Rect2({px_}, {BUTTON_Y['Portrait']}, 112, 112)", "metadata/portrait_scale = Vector2(1, 1)"]
        if anim:
            props.append(f'icon_anim = &"{anim}"')
        s.node(name, None, "Stage", props, instance=rb)
    counter = s.res("PackedScene", "res://scenes/ui/counter.tscn")
    lx, ly = GRAINS["Landscape"]
    px_, py_ = GRAINS["Portrait"]
    s.node("Grains", None, "Stage", ["unique_name_in_owner = true", "layout_mode = 0", f"offset_left = {lx}", f"offset_top = {ly}",
                                     f"offset_right = {lx + 260}", f"offset_bottom = {ly + 64}", "value = 0",
                                     f"metadata/portrait = Rect2({px_}, {py_}, 260, 64)"], instance=counter)
    out = ROOT / "scenes" / "ui" / "main_menu.tscn"
    out.write_text(s.text(), encoding="utf-8", newline="\n")
    print(f"menu: {len(s.nodes)} nodes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
