#!/usr/bin/env bash
# СДВИГ R109 — убрать подложку за картой + объёмный дизайн карты
set -e
echo "══ штамп → R109 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R109'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R109</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/2  убрать тёмную подложку decision-stage ════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old=""".decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;
      align-items:center;justify-content:center;gap:0;padding:20px 14px;
      background:radial-gradient(60% 50% at 50% 42%,rgba(10,7,9,.12),rgba(10,7,9,.42));
      backdrop-filter:blur(2px);}"""
new=""".decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;
      align-items:center;justify-content:center;gap:0;padding:20px 14px;
      background:transparent;pointer-events:none;}
    .decision-stage>*{pointer-events:auto;}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + подложка убрана (фон уровня виден полностью)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 2/2  объёмный дизайн карты (neumorphism + bevel) ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
import re
n=0

# Объёмная карта: многослойные тени, bevel-край, светлый верхний блик, тёмный низ
old=re.search(r'\.dec-card\{position:relative;width:min\(86vw,340px\);[^}]*animation:cardIdle 3\.5s ease-in-out infinite;\}', txt)
if old:
    new=""".dec-card{position:relative;width:min(86vw,340px);margin-top:20px;border-radius:24px;z-index:5;
      background:
        linear-gradient(165deg,#2a1e28 0%,#1a1220 55%,#100a14 100%);
      box-shadow:
        /* глубокая отбрасываемая тень (карта парит) */
        0 30px 60px -12px rgba(0,0,0,.8),
        0 18px 36px -8px rgba(0,0,0,.6),
        /* багровое свечение */
        0 0 40px rgba(176,38,66,.25),
        /* bevel: светлый кант сверху, тёмный снизу (объём) */
        inset 0 2px 1px rgba(255,255,255,.14),
        inset 0 -2px 2px rgba(0,0,0,.5),
        inset 0 0 0 1px rgba(224,84,110,.3);
      touch-action:none;will-change:transform;cursor:grab;overflow:hidden;
      animation:cardIdle 3.5s ease-in-out infinite;}"""
    txt=txt[:old.start()]+new+txt[old.end():]
    n+=1; print("  + объёмная карта (bevel, парящая тень, свечение)")

# Улучшенная рамка-обводка: ярче, с бликом сверху
old2=re.search(r'\.dec-card::before\{content:'+"''"+r';position:absolute;inset:0;border-radius:22px;[^}]*mask-composite:exclude;\}', txt)
if old2:
    new2=""".dec-card::before{content:'';position:absolute;inset:0;border-radius:24px;padding:1.5px;pointer-events:none;z-index:1;
      background:linear-gradient(155deg,
        rgba(255,180,200,.7) 0%,
        rgba(224,84,110,.5) 25%,
        rgba(176,38,66,.15) 50%,
        transparent 75%);
      -webkit-mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);
      -webkit-mask-composite:xor;mask-composite:exclude;}"""
    txt=txt[:old2.start()]+new2+txt[old2.end():]
    n+=1; print("  + яркая градиентная рамка с бликом")

# добавим верхний глянцевый блик внутри карты (glass sheen)
if ".dec-card::after{" not in txt:
    sheen="""    .dec-card::after{content:'';position:absolute;top:0;left:0;right:0;height:45%;border-radius:24px 24px 0 0;
      pointer-events:none;z-index:0;
      background:linear-gradient(180deg,rgba(255,255,255,.06),transparent);}"""
    # вставляем после ::before
    txt=txt.replace("      -webkit-mask-composite:xor;mask-composite:exclude;}",
                    "      -webkit-mask-composite:xor;mask-composite:exclude;}\n"+sheen,1)
    n+=1; print("  + верхний глянцевый блик")

# grabbed — тень углубляется, карта приподнимается
old3=re.search(r'\.dec-card\.grabbed\{animation:none;cursor:grabbing;[^}]*\}', txt)
if old3:
    new3=""".dec-card.grabbed{animation:none;cursor:grabbing;
      box-shadow:
        0 40px 80px -12px rgba(0,0,0,.85),
        0 24px 48px -8px rgba(0,0,0,.7),
        0 0 54px rgba(224,84,110,.4),
        inset 0 2px 1px rgba(255,255,255,.18),
        inset 0 -2px 2px rgba(0,0,0,.55),
        inset 0 0 0 1px rgba(224,84,110,.45);}"""
    txt=txt[:old3.start()]+new3+txt[old3.end():]
    n+=1; print("  + захват: тень углубляется")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R109 — подложка убрана, карта объёмная (bevel/тени/блик)"
echo "   git add -A && git commit -m 'R109: remove backing, volumetric card design' && git push"
echo "═══════════════════════════════════════════════════════"
