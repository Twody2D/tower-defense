# CLAUDE.md — «Защити огород!»

Hybrid-casual «герой + tower defense» на ферме для Яндекс Игр (Godot 4.7, 2D, ПК + телефон, портрет и ландшафт).

## Источники правды

| Файл | Что там |
| --- | --- |
| `CODE_PROMPT.md` | Геймдизайн, баланс, тех. требования, этапы 1–8 |
| `DESIGN_PROMPT.md` | Требования к арту (партии A–J) |
| `design/Защити огород дизайн/` | Готовый арт Claude Design: PNG в `export/<партия>/`, макеты `*.dc.html`. Только читать |
| `docs/PLAN.md` | План и текущий этап |
| `docs/size_log.md` | Размер ZIP после каждого этапа |
| `TODO.md` | Задачи текущего этапа, решения, открытые вопросы — обновлять после каждого шага |

Решения Twody (уже внесены в CODE_PROMPT):
- код, сцены и `.tres` в файлы пишет Claude сам; всё видимое — сценами из узлов со спрайтами, чтобы было видно в редакторе, без `_draw()` (кроме орды в MultiMesh);
- Docker, VPS, WSL не используем; телефон — по локальной сети или черновик Яндекса;
- вес графики пока не урезаем — только если ZIP не влезет в 10 МБ;
- `design/` хранится в git;
- переключателя языка нет: язык только из SDK (скилл `yandex-games`, п. 2.14);
- rewarded-бонус — после `onRewarded` **и** `onClose` (скилл важнее CODE_PROMPT).

## Git

- Conventional Commits, заголовок ≤ 72 символов, по-английски. Scope: `battle`, `hero`, `enemies`, `defenders`, `data`, `save`, `platform`, `ads`, `meta`, `ui`, `art`, `audio`, `i18n`, `balance`, `tools`, `web`.
- **Никаких `Co-Authored-By` и упоминаний Claude.** Хук `.githooks/commit-msg` проверяет.
- Коммит после каждого рабочего шага, перед коммитом смотреть `git status`. **Не пушить.**
- Никаких CI, GitHub Actions, Dependabot.

## Структура

```
tower-defense/   проект Godot (res://)
  autoload/      Game, Save, Audio, YandexSdk, Ads, I18n
  platform/      бэкенды SDK: platform_base / _yandex / _mock
  data/ scenes/ art/ audio/ fonts/ shaders/ i18n/
  tests/         gdUnit4
  web/shell.html страница экспорта с мостом window.YG
tools/           check_build.py, browser_check.py, build_template.ps1
custom.build     профиль облегчённого web-шаблона движка
build/           экспорт (в .gitignore)
```

## Технические правила

- GDScript строго типизирован, `untyped_declaration` и `unsafe_*` — ошибки.
- Макеты дизайна нарисованы под 1080 по короткой стороне, база игры тоже 1080: размеры UI из макетов **1:1** (9-slice углы не ломаются). Камера показывает 1080 px мира по короткой стороне.
- Compatibility, база 1080×1080, stretch `canvas_items` + `expand` (ландшафт → 1920×1080, портрет → 1080×1920). UI на якорях.
- Снимки макетов: `py -3.14 tools/design_shots.py "Партия I - Экраны.dc.html" <папка>` — все вкладки.
- Враги — данные в `EnemyManager`, рисуются `MultiMeshInstance2D`. В бою без `instantiate()`/`queue_free()` — пулы.
- Баланс — только в `.tres` в `tower-defense/data/`. Тексты — `tr("KEY")`, `i18n/translations.csv`.
- SDK — только через `YandexSdk`, реклама — через `Ads`.
- Новый тип узла — проверить, что он не вырезан в `custom.build` (иначе «Cannot get class» в браузере).

## Команды (Git Bash, из `tower-defense/`)

```bash
G="/c/PROGRAMS/Godot/Godot_v4.7.2-stable_win64_console.exe"
"$G" --headless --path . --import
"$G" --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests --ignoreHeadlessMode
"$G" --headless --path . --export-release "Web" ../build/web/index.html
py -3.14 ../tools/check_build.py          # проверка + build/game.zip
py -3.14 -m http.server 8061 --bind 127.0.0.1 -d ../build/web
py -3.14 ../tools/browser_check.py http://127.0.0.1:8061/ <out> 10 1280 720 "640,327@4"   # консоль + скриншот
py -3.14 ../tools/copy_art.py             # арт из design/ → art/, атласы тайлов и врагов, art/animations.json
"$G" --headless --path . --import          # затем импорт новых PNG (может не выйти сам — снять процесс)
"$G" --headless --path . -s res://tools/import_animations_cli.gd   # SpriteFrames art/frames/*.tres + атласы врагов (в редакторе: tools/import_animations.gd, Ctrl+Shift+X)
"$G" --path . --resolution 1280x720 -s res://dev/battle_demo.gd -- <out> 60,700   # скриншоты боя
"$G" --path . --resolution 1280x720 -s res://dev/sandbox_demo.gd -- <out> 700      # все защитники и враги
"$G" --path . --resolution 540x960 -s res://dev/windows_demo.gd -- <out_dir>           # снимки всех окон
"$G" --headless --path . -s res://dev/rebuild_level.gd -- res://scenes/levels/level_01.tscn  # тайлы по Path2D
"$G" --headless --path . --export-release "WebStress" ../build/stress/index.html   # стресс-тест для телефона
py -3.14 -m http.server 8063 --bind 0.0.0.0 -d ../build/stress   # телефон: http://192.168.0.35:8063/?n=250
```

Скриншоты — только в режиме с окном (`--path . --resolution`), headless не рисует. Проверять размеры на 540×960 (телефон) и 1280×720.

Шаблон движка: `powershell -File tools/build_template.ps1` (~15 мин) → `C:\PROGRAMS\godot-templates\towerdefence_web_release.zip`.
