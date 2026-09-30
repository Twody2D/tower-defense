# Звуки и музыка — источники

Все файлы — **CC0** (общественное достояние): можно использовать в коммерческой игре, указывать авторов не обязательно (указываем из уважения). Сборка — `tools/import_sounds.py`: скачивает паки в `build/audio_src`, режет, выравнивает громкость, пишет OGG в `tower-defense/audio/`.

| Файл в игре | Источник | Автор |
| --- | --- | --- |
| `music/menu.ogg` | [Happy Clappy Loop](https://opengameart.org/content/happy-clappy-loop) | OwlishMedia |
| `music/battle.ogg` | [Feel Good Island Loop](https://opengameart.org/content/feel-good-island-loop) (CC0 или OGA-BY на выбор, берём CC0) | AntumDeluge по музыке Brandon Morris |
| `sfx/win.ogg`, `sfx/lose.ogg`, `sfx/unlock.ogg` | [Music Jingles](https://kenney.nl/assets/music-jingles) (pizzicato 10, 07, 08) | Kenney |
| `sfx/click.ogg`, `sfx/deny.ogg`, `sfx/buy.ogg`, `sfx/pay.ogg` | [Interface Sounds](https://kenney.nl/assets/interface-sounds) | Kenney |
| `sfx/coin_*.ogg` | [RPG Audio](https://kenney.nl/assets/rpg-audio) | Kenney |
| `sfx/hit_*.ogg`, `sfx/stun.ogg`, `sfx/fence_*.ogg`, `sfx/parcel_land.ogg` | [Impact Sounds](https://kenney.nl/assets/impact-sounds) | Kenney |
| `sfx/throw_*.ogg` | [RPG Sound Pack](https://opengameart.org/content/rpg-sound-pack) | artisticdude |
| `sfx/carrot_*.ogg`, `sfx/boss.ogg`, `sfx/snore.ogg` | [80 CC0 creature SFX](https://opengameart.org/content/80-cc0-creature-sfx) | rubberduck |
| `sfx/pop_*.ogg`, `sfx/build_*.ogg`, `sfx/wave.ogg`, `sfx/parcel_open.ogg`, `sfx/tractor.ogg` | [100 CC0 SFX](https://opengameart.org/content/100-cc0-sfx) | rubberduck |

Заменить звук: поменять строку в `SFX`/`MUSIC` в `tools/import_sounds.py`, запустить его и импорт Godot; несколько файлов на один звук — варианты, игра выбирает случайный. Новое имя звука — добавить в `SFX` в `autoload/audio.gd`.
