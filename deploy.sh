#!/usr/bin/env bash
# СДВИГ R31 — фикс кэша спрайтов (версия пути) + Рекрут во вступлении + проверка речей
set -e

echo ""; echo "══ 1/3  app.js — версионирование путей спрайтов ════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# Добавляем ?v=N к src спрайта, чтобы пробить кэш браузера при обновлении арта
# Версия задаётся одной константой — меняешь её при каждом обновлении PNG
if "CHAR_VER" not in txt:
    # вставляем константу перед CHARS
    txt = txt.replace("const CHARS={", "const CHAR_VER='3';  /* поднимай при замене артов — пробивает кэш */\nconst CHARS={", 1)
    n+=1; print("  + CHAR_VER константа")

# в showChar добавляем версию к src
old_src = "    _charEl.src=def.src; _charId=id;"
new_src = "    _charEl.src=def.src+'?v='+CHAR_VER; _charId=id;"
if old_src in txt:
    txt = txt.replace(old_src, new_src, 1); n+=1; print("  + ?v= к пути спрайта (пробитие кэша)")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d" % n)
PYEOF


echo ""; echo "══ 2/3  feed.js — версия пути (если грузит сам) ════"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/feed.js"
with open(path, encoding="utf-8") as f: txt = f.read()
# feed.js вызывает showChar из app.js, отдельной загрузки нет — проверяем
if "showChar(ev.speaker" in txt:
    print("  · feed.js использует showChar из app.js (версия уже там)")
else:
    print("  · feed.js не грузит спрайты напрямую")
PYEOF


echo ""; echo "══ 3/3  Рекрут во вступлении + проверка речей ══════"
python3 - << 'PYEOF'
import json
path = "src/main/resources/static/scenarios/case001.json"
with open(path, encoding="utf-8") as f: d = json.load(f)

# Во вступлении главный герой — Рекрут (от его лица). Карты-нарратив (без speaker)
# оставляем как есть, но там где явно говорит/думает Рекрут — ставим recruit.
# Сдвиг говорит в L1_c2,c4,c5,c7,c8. Нарратив c1,c3,c6 — оставим Рекрута (его взгляд).
RECRUIT_CARDS = {
    'L1_c1':'recruit',  # вступительный нарратив — глазами Рекрута
    'L1_c3':'recruit',
    'L1_c6':'recruit'
}
n=0
for eid, spk in RECRUIT_CARDS.items():
    ev=d['events'].get(eid)
    if ev and not ev.get('speaker'):
        ev['speaker']=spk; n+=1

with open(path, "w", encoding="utf-8") as f:
    json.dump(d, f, ensure_ascii=False, indent=2)
print(f"  + Рекрут проставлен в {n} картах вступления")

# Проверим что у всех speaker-карт есть dialogue (иначе речь не покажется)
no_dlg=[]
for eid,ev in d['events'].items():
    if ev.get('speaker') and not ev.get('dialogue'):
        # если речи нет — берём text как реплику
        if ev.get('text'):
            ev['dialogue']=ev['text']
            no_dlg.append(eid)
if no_dlg:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(d, f, ensure_ascii=False, indent=2)
    print(f"  + дублирован text→dialogue для речи в {len(no_dlg)} картах: {no_dlg}")
else:
    print("  · у всех speaker-карт есть dialogue")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R31 — кэш спрайтов пробит, Рекрут говорит"
echo "   ВАЖНО: при каждой замене артов поднимай CHAR_VER в app.js"
echo "   git add -A && git commit -m 'R31: sprite cache-bust + recruit speaker + speech fix' && git push"
echo "═══════════════════════════════════════════════════════"
