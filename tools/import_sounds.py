"""Game sounds from CC0 packs (CODE_PROMPT stage 9): downloads the sources,
trims them, evens out the loudness and writes OGG Vorbis into
tower-defense/audio/sfx and tower-defense/audio/music.

Every source is CC0 (public domain) — list and links in docs/AUDIO_CREDITS.md.
Downloads are cached in build/audio_src (not in git). Re-running is safe; the
.import files of the sounds stay (UIDs), run the Godot import after it.

Needs ffmpeg from the pip package imageio-ffmpeg.
Run: py -3.14 tools/import_sounds.py
"""

import subprocess
import urllib.request
import zipfile
from pathlib import Path

import imageio_ffmpeg

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "build" / "audio_src"
OUT = ROOT / "tower-defense" / "audio"
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

OGA = "https://opengameart.org/sites/default/files/"
KENNEY = "https://kenney.nl/media/pages/assets/"
# name -> URL; .zip files are unpacked into a folder of the same name.
SOURCES: dict[str, str] = {
    "kenney_impact.zip": KENNEY + "impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip",
    "kenney_interface.zip": KENNEY + "interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip",
    "kenney_rpg.zip": KENNEY + "rpg-audio/8e99002d76-1677590336/kenney_rpg-audio.zip",
    "kenney_jingles.zip": KENNEY + "music-jingles/f37e530b9e-1677590399/kenney_music-jingles.zip",
    "rpg_pack.zip": OGA + "rpg_sound_pack.zip",
    "creatures.zip": OGA + "80-CC0-creature-SFX_0.zip",
    "sfx100.zip": OGA + "100-CC0-SFX_0.zip",
    "HappyClappyLoop.wav": OGA + "HappyClappyLoop.wav",
    "feel_good_island_loop_0.ogg": OGA + "feel_good_island_loop_0.ogg",
}

PIZZI = "kenney_jingles/Audio/Pizzicato jingles/jingles_PIZZI"

# out name -> list of (source path inside the cache, start sec, max length sec, gain dB).
# Several sources = variants, Audio picks one at random. Frequent battle
# sounds are quiet (−9…−14 dB): a crowd must not be a wall of noise.
SFX: dict[str, list[tuple[str, float, float, float]]] = {
    "click": [("kenney_interface/Audio/click_002.ogg", 0.0, 0.2, -6.0)],
    "deny": [("kenney_interface/Audio/error_004.ogg", 0.0, 0.4, -9.0)],
    # Shop: an upgrade or a skin bought.
    "buy": [("kenney_interface/Audio/confirmation_001.ogg", 0.0, 0.6, -5.0)],
    # A new defender / skin / level opened, a bonus taken.
    "unlock": [(PIZZI + "08.ogg", 0.0, 1.0, -3.0)],
    # Coins picked up by the hero.
    "coin": [("kenney_rpg/Audio/handleCoins.ogg", 0.0, 0.5, -9.0),
             ("kenney_rpg/Audio/handleCoins2.ogg", 0.0, 0.5, -9.0)],
    # One coin goes into a plot (0.05 s apart): a soft tick.
    "pay": [("kenney_interface/Audio/tick_001.ogg", 0.0, 0.15, -14.0)],
    # A defender built or raised a level: hammer on wood.
    "build": [("sfx100/tools_01.ogg", 0.0, 0.5, -4.0), ("sfx100/tools_02.ogg", 0.0, 0.55, -4.0)],
    # The hero (and the helper) throws.
    "throw": [("rpg_pack/RPG Sound Pack/battle/swing.wav", 0.0, 0.3, -14.0),
              ("rpg_pack/RPG Sound Pack/battle/swing2.wav", 0.0, 0.3, -14.0),
              ("rpg_pack/RPG Sound Pack/battle/swing3.wav", 0.0, 0.3, -14.0)],
    # A pest is hit (hero or defender shot).
    "hit": [(f"kenney_impact/Audio/impactSoft_medium_00{i}.ogg", 0.0, 0.3, -14.0) for i in (0, 1, 2)],
    # A pest is beaten: a cute plop.
    "pop": [("sfx100/plop_01.ogg", 0.0, 0.3, -8.0), ("sfx100/plop_02.ogg", 0.0, 0.36, -8.0)],
    # A pest got to the bed and eats a carrot.
    "carrot": [("creatures/eat_01.ogg", 0.0, 0.58, -4.0), ("creatures/eat_02.ogg", 0.0, 0.39, -4.0)],
    # A wave starts: the farm bell.
    "wave": [("sfx100/bell_01.ogg", 0.0, 1.3, -6.0)],
    # The fox (boss) comes out.
    "boss": [("creatures/howl.ogg", 0.0, 0.72, -2.0)],
    # The hero is knocked down.
    "stun": [("kenney_impact/Audio/impactPunch_medium_000.ogg", 0.0, 0.4, -5.0)],
    # Pests chew a fence / it breaks.
    "fence_hit": [(f"kenney_impact/Audio/impactPlank_medium_00{i}.ogg", 0.0, 0.3, -13.0) for i in (0, 1, 2)],
    "fence_break": [("kenney_impact/Audio/impactWood_heavy_000.ogg", 0.0, 0.6, -3.0)],
    # A parcel / gift lands, the hero opens it.
    "parcel_land": [("kenney_impact/Audio/impactSoft_heavy_000.ogg", 0.0, 0.5, -5.0)],
    "parcel_open": [("sfx100/wooded_box_open.ogg", 0.0, 0.37, -4.0)],
    # Bonuses with a voice of their own.
    "tractor": [("sfx100/machine_01.ogg", 0.0, 0.55, -6.0)],
    "snore": [("creatures/snore.ogg", 0.0, 0.44, -6.0)],
    # Results: up in major (10: D-E-F#-G) for a win, down by semitones (07) for a loss.
    "win": [(PIZZI + "10.ogg", 0.0, 1.4, -2.0)],
    "lose": [(PIZZI + "07.ogg", 0.0, 1.6, -2.0)],
}

# out name -> source. Both are made as seamless loops: no cuts, no fades
# (they would dip at the seam); Audio loops them.
MUSIC: dict[str, str] = {
    "menu": "HappyClappyLoop.wav",
    "battle": "feel_good_island_loop_0.ogg",
}


def fetch() -> None:
    CACHE.mkdir(parents=True, exist_ok=True)
    for name, url in SOURCES.items():
        path = CACHE / name
        if not path.exists():
            print("download", url)
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req) as r:
                path.write_bytes(r.read())
        if name.endswith(".zip"):
            folder = CACHE / name.removesuffix(".zip")
            if not folder.exists():
                with zipfile.ZipFile(path) as z:
                    z.extractall(folder)


def find(rel: str) -> Path:
    """Source file by its path; zip folders may have an extra top folder."""
    path = CACHE / rel
    if path.exists():
        return path
    head, _, tail = rel.partition("/")
    hits = [h for h in (CACHE / head).rglob(tail.rsplit("/", 1)[-1]) if "__MACOSX" not in h.parts]
    if not hits:
        raise FileNotFoundError(rel)
    return hits[0]


def peak_db(path: Path, start: float, length: float) -> float:
    out = subprocess.run([FFMPEG, "-hide_banner", "-ss", str(start), "-t", str(length), "-i", str(path),
                          "-af", "volumedetect", "-f", "null", "-"], capture_output=True, text=True).stderr
    for line in out.splitlines():
        if "max_volume:" in line:
            return float(line.split("max_volume:")[1].split("dB")[0])
    return 0.0


def convert(src: Path, dst: Path, filters: list[str], channels: int, quality: float) -> int:
    dst.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([FFMPEG, "-v", "error", "-y", "-i", str(src), "-af", ",".join(filters),
                    "-ac", str(channels), "-ar", "44100", "-c:a", "libvorbis", "-q:a", str(quality), str(dst)],
                   check=True)
    size = dst.stat().st_size
    print(f"{dst.relative_to(ROOT).as_posix()}: {size / 1024:.1f} KB")
    return size


def sfx() -> int:
    wanted: set[str] = set()
    total = 0
    for name, variants in SFX.items():
        for i, (rel, start, length, gain) in enumerate(variants):
            src = find(rel)
            # Peak to -1 dB, then the per-sound gain so the mix is even.
            boost = -1.0 - peak_db(src, start, length) + gain
            fade = min(0.08, length / 4)
            filters = [f"atrim=start={start}:duration={length}", "asetpts=PTS-STARTPTS",
                       "silenceremove=start_periods=1:start_threshold=-45dB",
                       f"volume={boost:.2f}dB", f"afade=t=out:st={max(0.0, length - fade):.3f}:d={fade:.3f}"]
            suffix = f"_{i + 1}" if len(variants) > 1 else ""
            out = OUT / "sfx" / f"{name}{suffix}.ogg"
            wanted.add(out.name)
            total += convert(src, out, filters, 1, 3)
    # Sounds no longer in the list go (with their .import).
    for old in (OUT / "sfx").glob("*.ogg"):
        if old.name not in wanted:
            old.unlink()
            Path(str(old) + ".import").unlink(missing_ok=True)
    return total


def music() -> int:
    total = 0
    for name, rel in MUSIC.items():
        # Same loudness for every track.
        total += convert(find(rel), OUT / "music" / f"{name}.ogg", ["loudnorm=I=-18:TP=-1.5:LRA=11"], 2, 0)
    return total


if __name__ == "__main__":
    fetch()
    s = sfx()
    m = music()
    print(f"sfx {s / 1024:.0f} KB, music {m / 1024:.0f} KB")
