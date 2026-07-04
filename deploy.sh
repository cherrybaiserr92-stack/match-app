#!/usr/bin/env bash
# СДВИГ R108 — вернуть старую карточку + доработка (рамка, подсветка, потряхивание)
set -e
echo "══ штамп → R108 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R108'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R108</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/4  вернуть старую карту (убрать canvas-контейнер) ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''      '<div class="dec-card canvas-card" id="dec-card"></div>'+
      '<div class="dec-stickers" id="dec-stickers"></div>'+
      '';'''
new='''      '<div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div>';'''
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + старая карта возвращена")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 2/4  вырезать весь canvas-блок построения ══════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
import re
# удаляем блок (function(){ ... })(); перед bindDecisionSwipe
start=txt.find("    (function(){\n      try{\n        var host=document.getElementById('dec-card'); if(!host) return;\n        var spk=(ev.speaker")
if start>=0:
    end=txt.find("    })();\n    bindDecisionSwipe(ev); startDecTimer();", start)
    if end>=0:
        end=end+len("    })();\n")
        txt=txt[:start]+txt[end:]
        print("  + canvas-блок вырезан")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ готово")
PYEOF

echo ""; echo "══ 3/4  красивая карта: рамка, багровый, типографика ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
import re, io
n=0

# Полностью переписываем CSS старой карты — премиальный вид
# Находим блок .dec-card{...} и связанные
old_card=re.search(r'\.dec-card\{position:relative;width:min\(80vw,320px\);[^}]*\}', txt)
if old_card:
    new_card=""".dec-card{position:relative;width:min(86vw,340px);margin-top:20px;border-radius:22px;z-index:5;
      background:linear-gradient(165deg,#241922 0%,#17101a 55%,#0f0912 100%);
      border:1px solid rgba(224,84,110,.45);
      box-shadow:0 20px 50px rgba(0,0,0,.65),0 0 0 1px rgba(0,0,0,.4),
        0 0 34px rgba(176,38,66,.22),inset 0 1px 0 rgba(255,255,255,.08);
      touch-action:none;will-change:transform;cursor:grab;overflow:hidden;
      animation:cardIdle 3.5s ease-in-out infinite;}
    /* тонкая светящаяся рамка-обводка */
    .dec-card::before{content:'';position:absolute;inset:0;border-radius:22px;padding:1px;pointer-events:none;
      background:linear-gradient(150deg,rgba(224,84,110,.5),rgba(176,38,66,.1) 40%,transparent 70%);
      -webkit-mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);
      -webkit-mask-composite:xor;mask-composite:exclude;}
    @keyframes cardIdle{0%,100%{transform:translateY(0) rotate(0);}50%{transform:translateY(-4px) rotate(.3deg);}}
    .dec-card.grabbed{animation:none;cursor:grabbing;
      box-shadow:0 28px 62px rgba(0,0,0,.72),0 0 46px rgba(224,84,110,.34),inset 0 1px 0 rgba(255,255,255,.1);}
    .dec-card.spring{transition:transform .5s cubic-bezier(.34,1.56,.64,1);}
    .dec-card.shake{animation:cardShake .4s ease;}
    @keyframes cardShake{0%,100%{transform:translateX(0);}20%{transform:translateX(-8px) rotate(-1deg);}
      40%{transform:translateX(8px) rotate(1deg);}60%{transform:translateX(-5px);}80%{transform:translateX(5px);}}"""
    txt=txt[:old_card.start()]+new_card+txt[old_card.end():]
    n+=1; print("  + премиальная рамка + idle + shake")

# внутренности карты
old_inner=re.search(r'\.dc-inner\{[^}]*\}', txt)
if old_inner:
    new_inner=""".dc-inner{padding:22px 20px 20px;position:relative;}"""
    txt=txt[:old_inner.start()]+new_inner+txt[old_inner.end():]
    n+=1

# бейдж, заголовок, интро — багровые, читаемые
for pat,rep,name in [
  (r'\.dc-badge\{[^}]*\}',
   """.dc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.14em;color:#fff;padding:5px 13px;border-radius:20px;
      background:linear-gradient(135deg,#e0546e,#8e1e36);box-shadow:0 3px 12px rgba(142,30,54,.4);margin-bottom:14px;}""",'badge'),
  (r'\.dc-title\{[^}]*\}',
   """.dc-title{font-family:Unbounded,sans-serif;font-weight:800;font-size:22px;line-height:1.15;
      color:#fff;margin-bottom:10px;overflow-wrap:break-word;text-wrap:balance;}""",'title'),
  (r'\.dc-intro\{[^}]*\}',
   """.dc-intro{font-size:14.5px;line-height:1.62;color:#c8bcc2;margin-bottom:20px;text-wrap:pretty;}""",'intro'),
]:
    m=re.search(pat,txt)
    if m: txt=txt[:m.start()]+rep+txt[m.end():]; n+=1

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ CSS карты: %d"%n)
PYEOF

echo ""; echo "══ 4/4  плашки выбора: премиум + подсветка при свайпе ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
import re
n=0
# кнопки выбора
old_choices=re.search(r'\.dc-choices\{[^}]*\}', txt)
if old_choices:
    new_choices=""".dc-choices{display:flex;gap:10px;align-items:stretch;margin-top:4px;}"""
    txt=txt[:old_choices.start()]+new_choices+txt[old_choices.end():]
    n+=1

old_choice=re.search(r'\.dc-choice\{[^}]*\}', txt)
if old_choice:
    new_choice=""".dc-choice{flex:1;min-width:0;display:flex;align-items:center;gap:7px;padding:13px 12px;border-radius:14px;
      font-family:Unbounded,sans-serif;font-weight:700;font-size:11.5px;line-height:1.3;cursor:pointer;
      transition:transform .18s cubic-bezier(.34,1.56,.64,1),box-shadow .25s,border-color .25s,background .25s;
      box-sizing:border-box;justify-content:center;text-align:center;}
    .dc-choice.left{background:linear-gradient(150deg,rgba(120,32,44,.35),rgba(60,16,24,.5));
      border:1px solid rgba(220,100,116,.4);color:#ffb9c4;}
    .dc-choice.right{background:linear-gradient(150deg,rgba(28,74,88,.35),rgba(14,38,46,.5));
      border:1px solid rgba(110,190,205,.4);color:#a8e2e8;}
    .dc-choice:active{transform:scale(.95);}
    /* подсветка при свайпе в сторону */
    .dc-choice.left.lit{transform:scale(1.06);box-shadow:0 0 26px rgba(220,100,116,.55),inset 0 0 20px rgba(220,100,116,.15);
      border-color:rgba(255,157,178,.9);background:linear-gradient(150deg,rgba(160,44,60,.55),rgba(90,24,36,.6));}
    .dc-choice.right.lit{transform:scale(1.06);box-shadow:0 0 26px rgba(110,190,205,.55),inset 0 0 20px rgba(110,190,205,.15);
      border-color:rgba(168,226,232,.9);background:linear-gradient(150deg,rgba(38,94,108,.55),rgba(20,52,62,.6));}"""
    txt=txt[:old_choice.start()]+new_choice+txt[old_choice.end():]
    n+=1; print("  + премиум-кнопки + подсветка при свайпе")

# arrow + or + lbl
for pat,rep in [
  (r'\.dc-arrow\{[^}]*\}',""".dc-arrow{font-size:15px;flex-shrink:0;opacity:.7;}"""),
  (r'\.dc-or\{[^}]*\}',""".dc-or{align-self:center;font-family:Unbounded,sans-serif;font-size:10px;color:#7d7080;flex-shrink:0;}"""),
]:
    m=re.search(pat,txt)
    if m: txt=txt[:m.start()]+rep+txt[m.end():]; n+=1

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ плашки: %d"%n)
PYEOF

echo ""; echo "══ доп: свайп подсвечивает кнопки + shake при недоступности ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# в bindDecisionSwipe — подсветка .dc-choice.lit (уже может быть), убедимся
if ".dc-choice.left'),cr=card.querySelector" not in txt and "dc-choice" in txt:
    # добавим подсветку в paint если её нет
    if "cl.classList.toggle('lit'" not in txt:
        txt=txt.replace(
          "var over=Math.abs(dx)>TH;",
          "var cl=card.querySelector('.dc-choice.left'),cr=card.querySelector('.dc-choice.right');\n      if(cl)cl.classList.toggle('lit',dx<-TH*0.4); if(cr)cr.classList.toggle('lit',dx>TH*0.4);\n      var over=Math.abs(dx)>TH;",1)
        n+=1; print("  + подсветка кнопок при свайпе")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R108 — старая карта возвращена и доработана (рамка/подсветка/потряхивание)"
echo "   git add -A && git commit -m 'R108: restore and polish CSS card - border, glow, shake' && git push"
echo "═══════════════════════════════════════════════════════"
