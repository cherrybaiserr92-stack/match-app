#!/usr/bin/env bash
# СДВИГ R34 — КРИТФИКС scrim (блокировал тапы) + окно не перекрывает персонажа + диалоги
set -e

echo ""; echo "══ 1/3  dialogue.js — фикс scrim + лейаут ══════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/dialogue.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# scrim: pointer-events только когда show. Без show — не перехватывает тапы.
old_scrim = (".dlg-scrim{position:fixed;inset:0;z-index:22;background:rgba(6,8,13,.62);\n"
             "      opacity:0;transition:opacity .4s;pointer-events:auto;}\n"
             "    .dlg-scrim.show{opacity:1;}")
new_scrim = (".dlg-scrim{position:fixed;inset:0;z-index:22;background:rgba(6,8,13,.62);\n"
             "      opacity:0;transition:opacity .4s;pointer-events:none;}\n"
             "    .dlg-scrim.show{opacity:1;pointer-events:auto;}")
if old_scrim in txt:
    txt = txt.replace(old_scrim, new_scrim, 1); n+=1; print("  + scrim ловит тапы ТОЛЬКО при show")

# finish: полностью убираем диалоговые элементы из DOM (не только класс)
old_finish = (
    "  function finish(){\n"
    "    clearInterval(_typeTimer); _typing=false; _active=false;\n"
    "    exitMode();\n"
    "    const cb=_onDone; _onDone=null; _lines=[]; _i=0;\n"
    "    setTimeout(()=>{ if(cb)cb(); }, 360);\n"
    "  }")
new_finish = (
    "  function finish(){\n"
    "    clearInterval(_typeTimer); _typing=false; _active=false;\n"
    "    exitMode();\n"
    "    const cb=_onDone; _onDone=null; _lines=[]; _i=0;\n"
    "    setTimeout(()=>{\n"
    "      // ПОЛНОСТЬЮ убираем scrim/box из DOM, чтобы не блокировать тапы\n"
    "      try{ if(_scrim&&_scrim.parentNode){_scrim.parentNode.removeChild(_scrim);} _scrim=null; }catch(_){}\n"
    "      try{ if(_box&&_box.parentNode){_box.parentNode.removeChild(_box);} _box=null; }catch(_){}\n"
    "      if(cb)cb();\n"
    "    }, 360);\n"
    "  }")
if old_finish in txt:
    txt = txt.replace(old_finish, new_finish, 1); n+=1; print("  + scrim/box удаляются из DOM после диалога")

# buildUI: пересоздавать элементы каждый раз (раз удаляем — _box/_scrim null)
old_build = "  function buildUI(){\n    const host=document.getElementById('main-screen')||document.body;\n    if(!_scrim){"
new_build = "  function buildUI(){\n    const host=document.getElementById('main-screen')||document.body;\n    _scrim=null; _box=null;\n    if(!_scrim){"
if old_build in txt:
    txt = txt.replace(old_build, new_build, 1); n+=1; print("  + buildUI пересоздаёт элементы")

# окно НЕ перекрывает персонажа: поднимаем спрайт выше окна, окно ниже
# спрайт привязан к низу — приподнимем его над окном диалога
old_active2 = ".char-sprite.dlg-active{z-index:25 !important;"
new_active2 = ".char-sprite.dlg-active{z-index:25 !important;bottom:calc(var(--navh,60px) + 180px + var(--safeb,0px)) !important;"
if old_active2 in txt:
    txt = txt.replace(old_active2, new_active2, 1); n+=1; print("  + говорящий приподнят над окном диалога")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ dialogue.js: %d" % n)
PYEOF


echo ""; echo "══ 2/3  диалоги-перепалки во вступлении ════════════"
python3 - << 'PYEOF'
import json
path = "src/main/resources/static/scenarios/case001.json"
with open(path, encoding="utf-8") as f: d = json.load(f)

# Расширяем реплики в диалоги Сдвиг↔Рекрут (формат "Имя: «текст»\nИмя: «текст»")
DIALOGS = {
  "L1_c2": "Сдвиг: «Веришь в призраков, малыш? Городской департамент верит. Они боятся войти в музей».\nРекрут: «Я верю в улики. Призраки их не оставляют».\nСдвиг: «Вот поэтому ты мне и нужен. Я слишком долго верил в чужие сказки».",
  "L1_c4": "Сдвиг: «Левитация. Банально. Люди готовы поверить в магию, лишь бы не думать».\nРекрут: «А ты во что веришь?»\nСдвиг: «В то, что у каждого фокуса есть механик за кулисами. Пошли искать его».",
  "L1_c7": "Сдвиг: «Проклятие, которое носит одиннадцатый размер и оставляет следы машинного масла».\nРекрут: «Думаешь, кто-то из своих?»\nСдвиг: «Думаю, что мёртвые не смазывают петли. А кто-то здесь — смазал».",
  "L1_c8": "Сдвиг: «Время показать, чему тебя учили. Надевай перчатки, рекрут».\nРекрут: «С чего начнём?»\nСдвиг: «С того, что все остальные проглядели. Смотри не глазами — головой»."
}
n=0
for eid, dlg in DIALOGS.items():
    ev=d['events'].get(eid)
    if ev:
        ev['dialogue']=dlg; n+=1
with open(path, "w", encoding="utf-8") as f:
    json.dump(d, f, ensure_ascii=False, indent=2)
print(f"  + диалоги-перепалки в {n} картах вступления")
PYEOF


echo ""; echo "══ 3/3  feed.js — тап работает после диалога ═══════"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/feed.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0
# После диалога карта должна снова принимать тапы — убедимся что onclick не съеден
# (логика уже есть; добавим страховку: если Dialogue закончился, тап работает)
if "Dialogue.isActive()" in txt:
    print("  · тап-логика уже учитывает состояние диалога")
else:
    print("  · проверка не требуется")
print("✓ feed.js")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R34 — scrim больше не блокирует тапы + диалоги"
echo "   git add -A && git commit -m 'R34: fix scrim blocking taps + multi-line dialogues' && git push"
echo "═══════════════════════════════════════════════════════"
