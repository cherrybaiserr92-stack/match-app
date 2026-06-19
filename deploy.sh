#!/usr/bin/env bash
# СДВИГ R35 — разделить нарратив/речь, фикс компоновки персонажа, Сдвиг справа, тайминг печати
set -e

echo ""; echo "══ 1/4  сценарии — отделяем прямую речь от нарратива"
python3 - << 'PYEOF'
import json, glob, re

def spk_name(s):
    M={'shift':'Сдвиг','recruit':'Рекрут','kurator':'Куратор','arundel':'Аранделл',
       'miller':'Миллер','hayes':'Хейс','romero':'Ромеро','conroy':'Конрой',
       'jiang':'Цзян','purcell':'Пёрселл','danny':'Дэнни','guests':'Гости'}
    return M.get(s,s)

def split_narration(text):
    """вне «...» → нарратив, в «...» → прямая речь"""
    if '«' not in text:
        return text, ''
    speech_parts = re.findall(r'«([^»]*)»', text)
    narration = re.sub(r'«[^»]*»', '', text)
    narration = re.sub(r'\s+', ' ', narration).strip(' .,—-:')
    return narration, ' '.join(speech_parts).strip()

total=0
for f in sorted(glob.glob('src/main/resources/static/scenarios/case*.json')):
    d=json.load(open(f,encoding='utf-8'))
    n=0
    for k,e in d['events'].items():
        txt=e.get('text','')
        if '«' not in txt:
            continue
        narr, speech = split_narration(txt)
        spk=e.get('speaker')
        has_multi = e.get('dialogue') and '\n' in e.get('dialogue','')
        # text всегда чистим от прямой речи (оставляем нарратив)
        e['text'] = narr if narr else txt
        if not has_multi:
            # одиночная реплика: собираем dialogue из speech
            if spk and speech:
                e['dialogue'] = spk_name(spk)+': «'+speech+'»'
            elif speech:
                e['dialogue'] = speech
        n+=1
    if n:
        json.dump(d, open(f,'w',encoding='utf-8'), ensure_ascii=False, indent=2)
    print(f"  + {f.split('/')[-1]}: разделено {n} событий")
    total+=n
print(f"✓ всего разделено: {total}")

# Проверка
d=json.load(open('src/main/resources/static/scenarios/case001.json',encoding='utf-8'))
e=[v for k,v in d['events'].items() if 'Пачка' in v.get('title','')][0]
print(f"  Проверка 'Пачка': text без «» = {'«' not in e['text']}")
print(f"    text: {e['text'][:55]!r}")
print(f"    dialogue: {e.get('dialogue','')[:55]!r}")
PYEOF


echo ""; echo "══ 2/4  dialogue.js — компоновка персонажа + тайминг"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/dialogue.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# Откатываем «приподнятие» (персонаж висел). Спрайт на низу, z-index над scrim.
old_active = ".char-sprite.dlg-active{z-index:25 !important;bottom:calc(var(--navh,60px) + 180px + var(--safeb,0px)) !important;filter:drop-shadow(0 8px 28px rgba(0,0,0,.75)) drop-shadow(0 0 18px rgba(200,134,10,.35)) !important;}"
new_active = ".char-sprite.dlg-active{z-index:23 !important;filter:drop-shadow(0 8px 28px rgba(0,0,0,.75)) drop-shadow(0 0 18px rgba(200,134,10,.35)) !important;}"
if old_active in txt:
    txt = txt.replace(old_active, new_active, 1); n+=1; print("  + спрайт не висит (на низу)")

# Окно ниже и компактнее
old_box = (".dlg-box{position:fixed;left:12px;right:12px;z-index:28;\n"
           "      bottom:calc(var(--navh,60px) + 12px + var(--safeb,0px));")
new_box = (".dlg-box{position:fixed;left:10px;right:10px;z-index:28;\n"
           "      bottom:calc(var(--navh,60px) + 6px + var(--safeb,0px));")
if old_box in txt:
    txt = txt.replace(old_box, new_box, 1); n+=1; print("  + окно ниже")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ dialogue.js: %d" % n)
PYEOF


echo ""; echo "══ 3/4  feed.js — диалог ПОСЛЕ печати нарратива ════"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/feed.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

old_dlg = ("    try{\n"
           "      if(window.Dialogue && window.parseDialogue && ev.dialogue){\n"
           "        var _lines=parseDialogue(ev);\n"
           "        if(_lines.length){ setTimeout(function(){ Dialogue.play(_lines); }, 320); }\n"
           "      } else if(window.showChar){ showChar(ev.speaker||null); }\n"
           "    }catch(_){}")
new_dlg = ("    try{\n"
           "      if(window.showChar) showChar(ev.speaker||null);\n"
           "      card._afterType=function(){\n"
           "        if(window.Dialogue && window.parseDialogue && ev.dialogue){\n"
           "          var _lines=parseDialogue(ev);\n"
           "          if(_lines.length){ Dialogue.play(_lines); }\n"
           "        }\n"
           "      };\n"
           "    }catch(_){}")
if old_dlg in txt:
    txt = txt.replace(old_dlg, new_dlg, 1); n+=1; print("  + диалог после печати нарратива")

old_done = ("      if(i>=full.length){ clearInterval(el._tt); el._typing=false; el.textContent=full; return; }")
new_done = ("      if(i>=full.length){ clearInterval(el._tt); el._typing=false; el.textContent=full;\n"
            "        if(card._afterType){ var f=card._afterType; card._afterType=null; setTimeout(f,250); } return; }")
if old_done in txt:
    txt = txt.replace(old_done, new_done, 1); n+=1; print("  + после печати → диалог")

old_finish = ("  function finishCardText(card){\n"
              "    var el=card.querySelector('.fc-text'); if(!el||!el._typing) return false;\n"
              "    clearInterval(el._tt); el._typing=false; el.textContent=el._full||''; return true;\n"
              "  }")
new_finish = ("  function finishCardText(card){\n"
              "    var el=card.querySelector('.fc-text'); if(!el||!el._typing) return false;\n"
              "    clearInterval(el._tt); el._typing=false; el.textContent=el._full||'';\n"
              "    if(card._afterType){ var f=card._afterType; card._afterType=null; setTimeout(f,200); }\n"
              "    return true;\n"
              "  }")
if old_finish in txt:
    txt = txt.replace(old_finish, new_finish, 1); n+=1; print("  + дописка тапом → диалог")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d" % n)
PYEOF


echo ""; echo "══ 4/4  app.js — Сдвиг справа ══════════════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
old = "  shift:  {src:'/img/chars/char-shift.png',   side:'left'},"
new = "  shift:  {src:'/img/chars/char-shift.png',   side:'right'},"
if old in txt:
    txt = txt.replace(old, new, 1)
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("✓ Сдвиг справа")
else:
    print("· уже изменён или не найден")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R35 — нарратив/речь разделены, Сдвиг справа, тайминг"
echo "   git add -A && git commit -m 'R35: split narration/speech, sprite layout, shift right, type timing' && git push"
echo "═══════════════════════════════════════════════════════"
