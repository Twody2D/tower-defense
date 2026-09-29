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

Решения Twody (важнее CODE_PROMPT):
- код в файлы пишет Claude сам;
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
game/            проект Godot (res://)
  autoload/      Game, Save, Audio, YandexSdk, Ads, I18n
  platform/      бэкенды SDK: platform_base / _yandex / _mock
  data/ scenes/ art/ audio/ fonts/ shaders/ localization/
  tests/         gdUnit4
  web/shell.html страница экспорта с мостом window.YG
tools/           check_build.py, browser_check.py, build_template.ps1
custom.build     профиль облегчённого web-шаблона движка
build/           экспорт (в .gitignore)
```

## Технические правила

- GDScript строго типизирован, `untyped_declaration` и `unsafe_*` — ошибки.
- Compatibility, база 720×720, stretch `canvas_items` + `expand` (ландшафт → 1280×720, портрет → 720×1280). UI на якорях.
- Враги — данные в `EnemyManager`, рисуются `MultiMeshInstance2D`. В бою без `instantiate()`/`queue_free()` — пулы.
- Баланс — только в `.tres` в `game/data/`. Тексты — `tr("KEY")`, `localization/translations.csv`.
- SDK — только через `YandexSdk`, реклама — через `Ads`.
- Новый тип узла — проверить, что он не вырезан в `custom.build` (иначе «Cannot get class» в браузере).

## Команды (Git Bash, из `game/`)

```bash
G="/c/PROGRAMS/Godot/Godot_v4.7.2-stable_win64_console.exe"
"$G" --headless --path . --import
"$G" --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests --ignoreHeadlessMode
"$G" --headless --path . --export-release "Web" ../build/web/index.html
py -3.14 ../tools/check_build.py          # проверка + build/game.zip
py -3.14 -m http.server 8060 --bind 127.0.0.1 -d ../build/web
```

Шаблон движка: `powershell -File tools/build_template.ps1` (~15 мин) → `C:\PROGRAMS\godot-templates\towerdefence_web_release.zip`.
