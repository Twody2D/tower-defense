"""Writes tower-defense/scenes/ui/theme.tres from the UI kit (design G):
9-slice margins from the kit table (top right bottom left), text styles,
button colours as theme type variations (ButtonGreen, ButtonBlue, ButtonAd,
TabActive/TabInactive), panels (WindowPanel, Card, CardHighlight, Toast)
and labels (LabelDark, LabelTitle, LabelGold, LabelSmall).

Run after the kit changes: py -3.14 tools/make_theme.py
"""
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "tower-defense" / "scenes" / "ui" / "theme.tres"
INK = "Color(0.169, 0.169, 0.227, 1)"  # #2B2B3A outlines and dark text
WHITE = "Color(1, 1, 1, 1)"
GOLD = "Color(1, 0.788, 0.2, 1)"
MUTED = "Color(0.42, 0.408, 0.47, 1)"

ext: list[str] = []
subs: list[str] = []
props: list[str] = []


def tex(name: str) -> str:
    rid = f"{len(ext) + 2}_{name}"
    ext.append(f'[ext_resource type="Texture2D" path="res://art/ui/{name}.png" id="{rid}"]')
    return rid


def box(name: str, trbl: tuple[int, int, int, int], content: tuple[int, int, int, int] | None = None,
        modulate: str | None = None) -> str:
    """StyleBoxTexture over art/ui/<name>.png; content margins default to the slice."""
    t, r, b, l = trbl
    ct, cr, cb, cl = content if content else trbl
    sid = f"StyleBox_{name}_{len(subs)}"
    body = [f'[sub_resource type="StyleBoxTexture" id="{sid}"]',
            f'content_margin_left = {cl}.0', f'content_margin_top = {ct}.0',
            f'content_margin_right = {cr}.0', f'content_margin_bottom = {cb}.0',
            f'texture = ExtResource("{tex(name)}")',
            f'texture_margin_left = {l}.0', f'texture_margin_top = {t}.0',
            f'texture_margin_right = {r}.0', f'texture_margin_bottom = {b}.0']
    if l == 0 and r == 0:
        body.append("axis_stretch_horizontal = 0")
    if modulate:
        body.append(f"modulate_color = {modulate}")
    subs.append("\n".join(body))
    return sid


def empty() -> str:
    sid = f"StyleBox_empty_{len(subs)}"
    subs.append(f'[sub_resource type="StyleBoxEmpty" id="{sid}"]')
    return sid


def button(type_name: str, prefix: str, slice_: tuple[int, int, int, int], content: tuple[int, int, int, int],
           font_color: str = WHITE, outline: int = 12, size: int = 44, states: bool = True, sm: bool = False) -> None:
    """`states`: the kit has _normal/_pressed/_disabled pictures (tabs have one).
    `sm`: the small copies (…_sm.png)."""
    suffix = "_sm" if sm else ""
    name = (lambda st: f"{prefix}_{st}{suffix}") if states else (lambda st: prefix)
    n = box(name("normal"), slice_, content)
    shift = 4 if sm else 6
    p = box(name("pressed"), slice_, (content[0] + shift, content[1], content[2] - shift, content[3]) if states else content)
    d = box(name("disabled"), slice_, content)
    f = empty()
    for state, sid in (("normal", n), ("hover", n), ("pressed", p), ("hover_pressed", p), ("disabled", d), ("focus", f)):
        props.append(f'{type_name}/styles/{state} = SubResource("{sid}")')
    for c in ("font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"):
        props.append(f"{type_name}/colors/{c} = {font_color}")
    props.append(f"{type_name}/colors/font_disabled_color = Color(1, 1, 1, 0.75)")
    props.append(f"{type_name}/colors/font_outline_color = {INK}")
    props.append(f"{type_name}/constants/outline_size = {outline}")
    props.append(f"{type_name}/font_sizes/font_size = {size}")


def variation(name: str, base: str) -> None:
    props.append(f'{name}/base_type = &"{base}"')


# Buttons (192×112, slice 44 44 52 44; ad 256×112, 44 44 52 84 — the video icon sits left).
BTN = (44, 44, 52, 44)
button("Button", "ui_btn_orange", BTN, (18, 44, 30, 44))
variation("ButtonGreen", "Button")
button("ButtonGreen", "ui_btn_green", BTN, (18, 44, 30, 44))
variation("ButtonBlue", "Button")
button("ButtonBlue", "ui_btn_blue", BTN, (18, 44, 30, 44))
variation("ButtonAd", "Button")
button("ButtonAd", "ui_btn_ad", (44, 44, 52, 84), (18, 40, 30, 96))
# Small buttons (80 tall, the pictures scaled by copy_art.py: slice 31 31 36 31, ad 59 left).
BTN_SM = (31, 31, 36, 31)
for name, prefix in (("ButtonSmall", "ui_btn_orange"), ("ButtonGreenSmall", "ui_btn_green"),
                     ("ButtonBlueSmall", "ui_btn_blue")):
    variation(name, "Button")
    button(name, prefix, BTN_SM, (12, 20, 22, 20), WHITE, 9, 28, sm=True)
variation("ButtonAdSmall", "Button")
button("ButtonAdSmall", "ui_btn_ad", (31, 31, 36, 59), (12, 12, 22, 54), WHITE, 9, 28, sm=True)
# Tabs 192×88, slice 32 32 8 32.
variation("TabActive", "Button")
button("TabActive", "ui_tab_active", (32, 32, 8, 32), (16, 32, 8, 32), INK, 0, 38, False)
variation("TabInactive", "Button")
button("TabInactive", "ui_tab_inactive", (32, 32, 8, 32), (20, 32, 8, 32), MUTED, 0, 36, False)

# Panels.
props.append(f'PanelContainer/styles/panel = SubResource("{box("ui_panel_main", (56, 56, 56, 56), (64, 56, 56, 56))}")')
props.append('WindowPanel/base_type = &"PanelContainer"')
props.append(f'WindowPanel/styles/panel = SubResource("{box("ui_panel_main", (56, 56, 56, 56), (72, 60, 64, 60))}")')
props.append('Card/base_type = &"PanelContainer"')
props.append(f'Card/styles/panel = SubResource("{box("ui_card", (32, 32, 40, 32), (20, 20, 28, 20))}")')
props.append('CardHighlight/base_type = &"PanelContainer"')
props.append(f'CardHighlight/styles/panel = SubResource("{box("ui_card_highlight", (32, 32, 40, 32), (20, 20, 28, 20))}")')
# Narrow cards (shop skins, 170 wide in portrait): less side padding.
props.append('CardTight/base_type = &"PanelContainer"')
props.append(f'CardTight/styles/panel = SubResource("{box("ui_card", (32, 32, 40, 32), (16, 10, 24, 10))}")')
props.append('CardHighlightTight/base_type = &"PanelContainer"')
props.append(f'CardHighlightTight/styles/panel = SubResource("{box("ui_card_highlight", (32, 32, 40, 32), (16, 10, 24, 10))}")')
props.append('Toast/base_type = &"PanelContainer"')
props.append(f'Toast/styles/panel = SubResource("{box("ui_toast", (0, 40, 0, 40), (16, 48, 20, 48))}")')

# Volume slider (track / fill 256×40, slice 0 20 0 20; knob 56).
props.append(f'HSlider/styles/slider = SubResource("{box("ui_slider_track", (0, 20, 0, 20), (8, 0, 8, 0))}")')
fill = box("ui_slider_fill", (0, 20, 0, 20), (8, 0, 8, 0))
props.append(f'HSlider/styles/grabber_area = SubResource("{fill}")')
props.append(f'HSlider/styles/grabber_area_highlight = SubResource("{fill}")')
knob = tex("ui_slider_knob")
props.append(f'HSlider/icons/grabber = ExtResource("{knob}")')
props.append(f'HSlider/icons/grabber_highlight = ExtResource("{knob}")')
props.append("HSlider/constants/center_grabber = 1")

# Labels: white with ink outline by default (HUD numbers, buttons).
props += [f"Label/colors/font_color = {WHITE}", f"Label/colors/font_outline_color = {INK}",
          "Label/constants/outline_size = 10", "Label/font_sizes/font_size = 40"]
props += ['LabelDark/base_type = &"Label"', f"LabelDark/colors/font_color = {INK}",
          "LabelDark/constants/outline_size = 0", "LabelDark/font_sizes/font_size = 38"]
props += ['LabelSmall/base_type = &"Label"', f"LabelSmall/colors/font_color = {MUTED}",
          "LabelSmall/constants/outline_size = 0", "LabelSmall/font_sizes/font_size = 30"]
props += ['LabelTitle/base_type = &"Label"', f"LabelTitle/colors/font_color = {WHITE}",
          "LabelTitle/constants/outline_size = 14", "LabelTitle/font_sizes/font_size = 52"]
props += ['LabelGold/base_type = &"Label"', f"LabelGold/colors/font_color = {GOLD}",
          "LabelGold/constants/outline_size = 12", "LabelGold/font_sizes/font_size = 56"]

head = f'[gd_resource type="Theme" load_steps={len(ext) + len(subs) + 2} format=3]\n'
text = head + "\n" + '[ext_resource type="FontFile" path="res://fonts/nunito_black.ttf" id="1_font"]\n'
text += "\n".join(ext) + "\n\n" + "\n\n".join(subs) + "\n\n[resource]\n"
text += "default_font = ExtResource(\"1_font\")\ndefault_font_size = 42\n" + "\n".join(props) + "\n"
OUT.write_text(text, encoding="utf-8")
print("theme:", len(subs), "styles")
