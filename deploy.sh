#!/usr/bin/env bash
# СДВИГ R103 — убрать подложку карты, вернуть плашки-стикеры, эффект сгорания
set -e
echo "══ штамп → R103 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R103'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R103</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/4  убрать багровую подложку карты начисто ════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# усиливаем сброс canvas-card (перебивает .dec-card)
old=""".canvas-card{background:none!important;border:none!important;box-shadow:none!important;
      width:min(90vw,350px)!important;overflow:visible!important;animation:none!important;}"""
new="""#dec-card.canvas-card{background:none!important;background-color:transparent!important;
      border:none!important;box-shadow:none!important;border-radius:0!important;
      width:min(90vw,350px)!important;overflow:visible!important;animation:none!important;margin-top:20px!important;}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + подложка карты убрана (#dec-card перебит)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 2/4  вернуть плашки-выбора (canvas-стикеры) под карту ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# добавляем контейнер плашек в разметку decision-stage
old='''<div class="oc-hint">← свайп решает →</div>';'''
new='''<div class="dec-stickers" id="dec-stickers"></div><div class="oc-hint">← свайп или тап →</div>';'''
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + контейнер плашек")

# строим canvas-стикеры после карты (в том же блоке где canvas-карта)
old2='''          host.innerHTML=''; host.appendChild(cv);
          // штампы поверх
          var sl=document.createElement('div'); sl.className='dc-stamp left';'''
new2='''          host.innerHTML=''; host.appendChild(cv);
          // плашки выбора (canvas-стикеры) под картой
          try{
            var box=document.getElementById('dec-stickers');
            if(box){
              box.innerHTML='';
              var mkSticker=function(label,sub,side){
                var wrap=document.createElement('div'); wrap.className='dec-sticker '+side;
                var scv=CardGen.renderSticker(label.replace(/^[\\u25c4\\u25ba]\\s*/,'').replace(/\\s*[\\u25c4\\u25ba]$/,''), sub);
                wrap.appendChild(scv);
                wrap.onclick=function(){ commitDecision(ev, side==='l'?'left':'right'); };
                return wrap;
              };
              box.appendChild(mkSticker(lL,'◄ РЕШЕНИЕ','l'));
              box.appendChild(mkSticker(rL,'РЕШЕНИЕ ►','r'));
            }
          }catch(e){console.error('stickers',e);}
          // штампы поверх
          var sl=document.createElement('div'); sl.className='dc-stamp left';'''
if old2 in txt: txt=txt.replace(old2,new2,1); n+=1; print("  + canvas-стикеры строятся под картой")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 3/4  CSS плашек + подсветка при свайпе ═════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".dec-stickers{" not in txt:
    add=""".dec-stickers{position:absolute;left:0;right:0;bottom:11%;display:flex;gap:14px;
      padding:0 18px;max-width:440px;margin:0 auto;z-index:15;}
    .dec-sticker{flex:1;cursor:pointer;transition:transform .15s;transform-origin:center;}
    .dec-sticker canvas{width:100%;height:auto;display:block;filter:drop-shadow(0 8px 16px rgba(0,0,0,.5));}
    .dec-sticker:active{transform:scale(.96);}
    .dec-sticker.lit{transform:scale(1.06) translateY(-4px);}
    .dec-sticker.lit canvas{filter:drop-shadow(0 12px 22px rgba(0,0,0,.6)) brightness(1.08);}
    """
    txt=txt.replace("    .dc-stamp{position:absolute;",add+"\n    .dc-stamp{position:absolute;",1)
    # подсветка стикеров при свайпе (заменяем .dc-choice.lit логику в paint)
    txt=txt.replace(
      "var sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');\n      if(sl)sl.style.opacity=dx<0?p:0; if(sr)sr.style.opacity=dx>0?p:0;\n      var over=Math.abs(dx)>TH;",
      "var sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');\n      if(sl)sl.style.opacity=dx<0?p:0; if(sr)sr.style.opacity=dx>0?p:0;\n      var stl=document.querySelector('.dec-sticker.l'),str2=document.querySelector('.dec-sticker.r');\n      if(stl)stl.classList.toggle('lit',dx<-TH*0.4); if(str2)str2.classList.toggle('lit',dx>TH*0.4);\n      var over=Math.abs(dx)>TH;",1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS плашек + подсветка при свайпе")
PYEOF

echo ""; echo "══ 4/4  эффект СГОРАНИЯ карты при свайпе ══════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# CSS сгорания
if "@keyframes cardBurn" not in txt:
    burn=""".dec-card.burning{animation:cardBurn .6s ease-in forwards!important;}
    @keyframes cardBurn{
      0%{filter:brightness(1);}
      35%{filter:brightness(1.3) sepia(.4);}
      60%{filter:brightness(.7) sepia(.8) contrast(1.4) hue-rotate(-18deg);}
      100%{filter:brightness(.2) sepia(1) contrast(2);opacity:0;transform:scale(.92) translateY(20px);}}
    .burn-ember{position:absolute;pointer-events:none;border-radius:50%;
      background:radial-gradient(circle,#ffd07a,#ff6a2a 50%,#8a1a0a);z-index:30;
      animation:ember 1s ease-out forwards;}
    @keyframes ember{0%{opacity:1;transform:translateY(0) scale(1);}
      100%{opacity:0;transform:translateY(-80px) scale(.2);}}
    .burn-edge{position:absolute;inset:0;pointer-events:none;z-index:25;opacity:0;
      background:radial-gradient(120% 90% at 50% 100%,rgba(255,120,40,.5),transparent 55%);
      animation:burnGlow .6s ease-out forwards;}
    @keyframes burnGlow{0%{opacity:0;}40%{opacity:1;}100%{opacity:0;}}
    """
    txt=txt.replace("    .dec-stickers{",burn+"\n    .dec-stickers{",1)
    n+=1; print("  + CSS сгорания (угли, свечение края)")

# функция сгорания + вызов в commitDecision
if "function burnCard" not in txt:
    fn='''  function burnCard(card){
    if(!card)return;
    // свечение горящего края
    var edge=document.createElement('div'); edge.className='burn-edge'; card.appendChild(edge);
    // угольки
    for(var i=0;i<14;i++){
      (function(i){
        var e=document.createElement('div'); e.className='burn-ember';
        var sz=3+Math.random()*5;
        e.style.width=sz+'px'; e.style.height=sz+'px';
        e.style.left=(10+Math.random()*80)+'%';
        e.style.top=(40+Math.random()*55)+'%';
        e.style.animationDelay=(Math.random()*0.25)+'s';
        card.appendChild(e);
      })(i);
    }
    card.classList.add('burning');
    try{Sound.burn&&Sound.burn();}catch(_){}
  }
'''
    txt=txt.replace("  function commitDecision(ev,dir,flew){",fn+"\n  function commitDecision(ev,dir,flew){",1)
    n+=1; print("  + функция burnCard")

# в commitDecision: заменить swipe-left/right на сгорание
old='''    if(card&&!flew)card.classList.add(dir==='left'?'swipe-left':'swipe-right');'''
new='''    if(card)burnCard(card);'''
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + карта сгорает при выборе")
# увеличим задержку удаления под анимацию сгорания
txt=txt.replace("},520);\n  }\n","},640);\n  }\n",1)
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R103 — подложка убрана, плашки возвращены, сгорание"
echo "   git add -A && git commit -m 'R103: remove card backing, restore choice stickers, burn effect' && git push"
echo "═══════════════════════════════════════════════════════"
