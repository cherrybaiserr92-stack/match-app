#!/usr/bin/env bash
# СДВИГ R105 — починка карточки: компоновка плашек, штампы внутри карты, сгорание, подложка
set -e
echo "══ штамп → R105 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R105'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R105</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/6  decision-stage → вертикальный flex-column ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old=""".decision-stage{position:absolute;inset:0;z-index:40;display:flex;align-items:center;justify-content:center;
      background:radial-gradient(80% 70% at 50% 45%,rgba(12,16,24,.55),rgba(8,11,18,.82));
      backdrop-filter:blur(3px);}"""
new=""".decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;
      align-items:center;justify-content:center;gap:0;padding:20px 14px;
      background:radial-gradient(80% 70% at 50% 45%,rgba(12,16,24,.55),rgba(8,11,18,.82));
      backdrop-filter:blur(3px);}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + stage: flex-column")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 2/6  карта-обёртка + штампы ВНУТРИ карты ═══════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# подложка карты — окончательно прозрачная, карта в потоке (не растянута)
old="""#dec-card.canvas-card{background:none!important;background-color:transparent!important;
      border:none!important;box-shadow:none!important;border-radius:0!important;
      width:min(90vw,350px)!important;overflow:visible!important;animation:none!important;margin-top:20px!important;}"""
new="""#dec-card.canvas-card{background:none!important;background-color:transparent!important;
      border:none!important;box-shadow:none!important;border-radius:0!important;
      width:min(84vw,330px)!important;overflow:visible!important;animation:none!important;
      margin:0 0 14px 0!important;flex:0 0 auto;position:relative;}
    #dec-card.canvas-card canvas{width:100%;height:auto;display:block;
      filter:drop-shadow(0 20px 40px rgba(0,0,0,.7));border-radius:4px;}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + карта в потоке, прозрачная, drop-shadow")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 3/6  штампы: внутри карты, не вылезают ═════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""    .dc-stamp{position:absolute;top:12%;max-width:50%;padding:8px 13px;border-radius:8px;
      font-family:'Special Elite',monospace;font-weight:700;font-size:13px;letter-spacing:.05em;
      opacity:0;pointer-events:none;z-index:20;text-transform:uppercase;white-space:nowrap;
      overflow:hidden;text-overflow:ellipsis;transition:opacity .1s;}
    .dc-stamp.left{left:4%;transform:rotate(-12deg);color:#ffb0b0;border:3px solid rgba(224,106,106,.95);background:rgba(90,20,20,.65);}
    .dc-stamp.right{right:4%;transform:rotate(12deg);color:#8ceed6;border:3px solid rgba(116,216,190,.95);background:rgba(20,70,58,.65);}"""
new="""    .dc-stamp{position:absolute;top:26%;max-width:42%;padding:7px 11px;border-radius:8px;
      font-family:'Special Elite',monospace;font-weight:700;font-size:13px;letter-spacing:.04em;
      opacity:0;pointer-events:none;z-index:20;text-transform:uppercase;white-space:nowrap;
      overflow:hidden;text-overflow:ellipsis;transition:opacity .08s;}
    .dc-stamp.left{left:8%;transform:rotate(-11deg);color:#ffb0b0;border:3px solid rgba(224,106,106,.95);background:rgba(90,20,20,.72);}
    .dc-stamp.right{right:8%;transform:rotate(11deg);color:#8ceed6;border:3px solid rgba(116,216,190,.95);background:rgba(20,70,58,.72);}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + штампы внутри карты (top:26%, внутри границ)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 4/6  плашки: в потоке под картой, компактнее ═══"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old=""".dec-stickers{position:absolute;left:0;right:0;bottom:11%;display:flex;gap:14px;
      padding:0 18px;max-width:440px;margin:0 auto;z-index:15;}
    .dec-sticker{flex:1;cursor:pointer;transition:transform .15s;transform-origin:center;}
    .dec-sticker canvas{width:100%;height:auto;display:block;filter:drop-shadow(0 8px 16px rgba(0,0,0,.5));}"""
new=""".dec-stickers{position:relative;display:flex;gap:12px;width:min(84vw,330px);
      margin:0 auto;z-index:15;flex:0 0 auto;}
    .dec-sticker{flex:1;cursor:pointer;transition:transform .15s;transform-origin:center;max-width:50%;}
    .dec-sticker canvas{width:100%;height:auto;display:block;filter:drop-shadow(0 6px 12px rgba(0,0,0,.5));}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + плашки в потоке под картой, компактные")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 5/6  порядок в DOM: карта → плашки → хинт ══════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# таймер выносим из карты, плашки идут ПОСЛЕ карты в потоке
old='''dec.innerHTML='<div class="dec-card canvas-card" id="dec-card"></div>'+
      '<div class="dec-timer" id="dec-timer"><div class="dt-ring2"><svg viewBox="0 0 50 50">'+
      '<circle class="bg" cx="25" cy="25" r="21"/><circle class="fg" id="dec-fg" cx="25" cy="25" r="21"/></svg>'+
      '<div class="dt-n" id="dec-n">15</div></div></div><div class="dec-stickers" id="dec-stickers"></div><div class="oc-hint">← свайп или тап →</div>';'''
new='''dec.innerHTML='<div class="dec-timer" id="dec-timer"><div class="dt-ring2"><svg viewBox="0 0 50 50">'+
      '<circle class="bg" cx="25" cy="25" r="21"/><circle class="fg" id="dec-fg" cx="25" cy="25" r="21"/></svg>'+
      '<div class="dt-n" id="dec-n">15</div></div></div>'+
      '<div class="dec-card canvas-card" id="dec-card"></div>'+
      '<div class="dec-stickers" id="dec-stickers"></div>'+
      '<div class="oc-hint">← свайп или тап →</div>';'''
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + порядок: таймер, карта, плашки, хинт")

# таймер — absolute сверху (не в потоке flex)
if ".dec-timer{position:absolute" not in txt:
    txt=txt.replace(".decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;",
                    ".dec-timer{position:absolute;top:5%;right:8%;z-index:22;}\n    .decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;",1)
    n+=1; print("  + таймер absolute сверху")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 6/6  сгорание: гарантия срабатывания ═══════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# burnCard применяется к canvas, а не к контейнеру (эффект виден на арте)
old="""  function burnCard(card){
    if(!card)return;"""
new="""  function burnCard(card){
    if(!card)return;
    var cv=card.querySelector('canvas'); var target=cv||card;
    if(cv){ cv.classList.add('burning'); }"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + сгорание на canvas")

# CSS: burning работает и на canvas
if ".burning{animation:cardBurn" in txt:
    txt=txt.replace(".dec-card.burning{animation:cardBurn .6s ease-in forwards!important;}",
                    ".dec-card.burning,#dec-card canvas.burning{animation:cardBurn .6s ease-in forwards!important;}",1)
    n+=1; print("  + CSS сгорания для canvas")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 7/7  весь CSS сгорания (cardBurn + ember + edge) ═"
python3 - << 'PYEOF2'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# гарантируем полный CSS сгорания (в R103 не вставился)
if "@keyframes cardBurn" not in txt:
    css=[]
    css.append("    #dec-card canvas.burning{animation:cardBurn .62s ease-in forwards!important;}")
    css.append("    @keyframes cardBurn{")
    css.append("      0%{filter:brightness(1);}")
    css.append("      30%{filter:brightness(1.25) sepia(.4);}")
    css.append("      60%{filter:brightness(.7) sepia(.85) contrast(1.4) hue-rotate(-18deg);}")
    css.append("      100%{filter:brightness(.15) sepia(1) contrast(2.2);opacity:0;transform:scale(.9) translateY(24px) rotate(-3deg);}}")
    css.append("    .burn-ember{position:absolute;pointer-events:none;border-radius:50%;z-index:30;")
    css.append("      background:radial-gradient(circle,#ffd07a,#ff6a2a 50%,#8a1a0a);")
    css.append("      animation:emberFly 1s ease-out forwards;}")
    css.append("    @keyframes emberFly{0%{opacity:1;transform:translateY(0) scale(1);}")
    css.append("      100%{opacity:0;transform:translateY(-90px) scale(.2);}}")
    css.append("    .burn-edge{position:absolute;inset:0;pointer-events:none;z-index:25;opacity:0;border-radius:6px;")
    css.append("      background:radial-gradient(120% 90% at 50% 100%,rgba(255,120,40,.55),transparent 55%);")
    css.append("      animation:burnGlow .62s ease-out forwards;}")
    css.append("    @keyframes burnGlow{0%{opacity:0;}40%{opacity:1;}100%{opacity:0;}}")
    block="\n".join(css)+"\n"
    # вставляем перед .dec-stickers{ (точно существует)
    marker=".dec-stickers{position:relative;"
    if marker in txt:
        txt=txt.replace(marker, block+marker, 1)
        n+=1; print("  + полный CSS сгорания вставлен")
    else:
        print("  ! маркер dec-stickers не найден")
else:
    print("  cardBurn уже есть")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("CSS сгорания: %d"%n)
PYEOF2

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "final feed.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R105 — карточка починена: компоновка, штампы, сгорание"
echo "   git add -A && git commit -m 'R105: fix card layout, stamps, stickers, burn' && git push"
echo "═══════════════════════════════════════════════════════"
