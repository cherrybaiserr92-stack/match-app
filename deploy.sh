#!/usr/bin/env bash
# СДВИГ R110 — вставка утверждённой карты: black-рамка + переливы + огонь-спрайт + плашки-стиль
set -e
echo "══ штамп → R110 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R110'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R110</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 0/6  проверка спрайта огня ═════════════════════"
if [ -f img/cards/fire-sheet.png ]; then echo "  ✓ спрайт огня на месте"
else echo "  ⚠ ПОЛОЖИ img/cards/fire-sheet.png (из огонь-спрайт.zip)!"; mkdir -p img/cards; fi

echo ""; echo "══ 1/6  CSS карты → black-стиль + переливы ════════"
python3 - << 'PYEOF'
import re
path="games/feed.js"; txt=open(path,encoding="utf-8").read()

# Заменяем весь блок от .dec-card{ до конца .dc-choice.right.lit (старый полированный)
start=txt.find("    .dec-card{position:relative;width:min(86vw,340px);margin-top:20px;")
end=txt.find(".dc-choice.right.lit{transform:scale(1.04);box-shadow:0 0 18px rgba(110,210,185,.4);}")
if start<0 or end<0:
    print("  ⚠ якоря CSS не найдены"); 
else:
    end=end+len(".dc-choice.right.lit{transform:scale(1.04);box-shadow:0 0 18px rgba(110,210,185,.4);}")
    newcss='''    /* ═══ BLACK-КАРТА: чёрная рамка + переливы + огонь ═══ */
    .dec-cardbox{position:relative;flex:0 0 auto;margin-top:20px;}
    .dec-card{position:relative;width:min(86vw,340px);border-radius:24px;z-index:5;padding:3px;
      background:linear-gradient(160deg,#2a2a2e,#0a0a0c 55%,#000);border:1.5px solid #000;
      box-shadow:0 24px 60px rgba(0,0,0,.75),0 0 0 1px rgba(255,255,255,.04),
        inset 0 1px 0 rgba(255,255,255,.08),inset 0 -2px 4px rgba(0,0,0,.6);
      touch-action:none;will-change:transform;cursor:grab;transform-style:preserve-3d;}
    .dec-card.grabbed{cursor:grabbing;}
    .dec-card.spring{transition:transform .5s cubic-bezier(.34,1.56,.64,1);}
    .dec-card.shake{animation:cardShake .4s ease;}
    @keyframes cardShake{0%,100%{transform:translateX(0);}20%{transform:translateX(-8px) rotate(-1deg);}
      40%{transform:translateX(8px) rotate(1deg);}60%{transform:translateX(-5px);}80%{transform:translateX(5px);}}
    .dc-inner{border-radius:21px;padding:24px 22px;position:relative;overflow:hidden;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));
      border:1px solid rgba(255,255,255,.06);transition:filter .5s;}
    /* переливы (голографический блик) */
    .dc-inner::before{content:'';position:absolute;inset:0;z-index:1;pointer-events:none;opacity:.55;mix-blend-mode:color-dodge;
      background:linear-gradient(115deg,transparent 25%,rgba(224,84,110,.35) 42%,rgba(120,180,220,.4) 50%,rgba(224,180,110,.35) 58%,transparent 75%);
      background-size:250% 250%;animation:sheenMove 5s ease-in-out infinite;}
    @keyframes sheenMove{0%,100%{background-position:0% 0%;}50%{background-position:100% 100%;}}
    .dc-inner::after{content:'';position:absolute;top:0;left:0;right:0;height:45%;z-index:1;pointer-events:none;
      background:linear-gradient(180deg,rgba(255,255,255,.06),transparent);}
    .dc-badge,.dc-title,.dc-intro{position:relative;z-index:2;}
    .dc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;letter-spacing:.14em;
      color:#fff;padding:5px 13px;border-radius:20px;background:linear-gradient(135deg,#e0546e,#8e1e36);
      box-shadow:0 3px 12px rgba(142,30,54,.4);margin-bottom:14px;}
    .dc-title{font-family:Unbounded,sans-serif;font-weight:900;font-size:22px;line-height:1.13;color:#fff;
      margin-bottom:10px;overflow-wrap:break-word;text-wrap:balance;}
    .dc-intro{font-size:14.5px;line-height:1.6;color:#c8bcc2;text-wrap:pretty;}
    /* огонь-спрайт (языки снизу) */
    .dc-fire{position:absolute;left:0;right:0;bottom:-8%;height:120%;z-index:20;pointer-events:none;opacity:0;
      background-image:url(/img/cards/fire-sheet.png);background-repeat:no-repeat;
      mix-blend-mode:screen;transition:opacity .3s ease;}
    /* ПЛАШКИ выбора в стиле карты */
    .dc-choices{display:flex;gap:12px;width:min(86vw,340px);margin:16px auto 0;z-index:15;flex:0 0 auto;}
    .dc-choice{flex:1;min-width:0;border-radius:16px;padding:2px;cursor:pointer;
      transition:transform .2s cubic-bezier(.34,1.56,.64,1),box-shadow .25s;
      background:linear-gradient(160deg,#2a2a2e,#0a0a0c 55%,#000);border:1px solid #000;
      box-shadow:0 8px 20px rgba(0,0,0,.6),inset 0 1px 0 rgba(255,255,255,.06);}
    .dc-choice-in{border-radius:14px;padding:13px 10px;text-align:center;position:relative;overflow:hidden;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));
      font-family:Unbounded,sans-serif;font-weight:700;font-size:11.5px;line-height:1.25;}
    .dc-choice-in::before{content:'';position:absolute;inset:0;z-index:1;pointer-events:none;opacity:.5;mix-blend-mode:color-dodge;
      background:linear-gradient(115deg,transparent 30%,rgba(224,84,110,.3) 45%,rgba(120,180,220,.35) 52%,rgba(224,180,110,.3) 60%,transparent 75%);
      background-size:250% 250%;animation:sheenMove 5s ease-in-out infinite;}
    .dc-choice-in span{position:relative;z-index:2;}
    .dc-choice.left .dc-choice-in span{color:#ffb9c4;}
    .dc-choice.right .dc-choice-in span{color:#a8e2e8;}
    .dc-choice:active{transform:scale(.96);}
    .dc-choice.left.lit{transform:scale(1.06);box-shadow:0 10px 24px rgba(0,0,0,.6),0 0 22px rgba(224,84,110,.5);}
    .dc-choice.right.lit{transform:scale(1.06);box-shadow:0 10px 24px rgba(0,0,0,.6),0 0 22px rgba(90,180,200,.5);}'''
    txt=txt[:start]+newcss+txt[end:]
    print("  + CSS карты заменён на black-стиль")
open(path,"w",encoding="utf-8").write(txt)
PYEOF

echo ""; echo "══ 2/6  decCardInner → без плашек + огонь ═════════"
python3 - << 'PYEOF'
path="games/feed.js"; txt=open(path,encoding="utf-8").read()
old='''  function decCardInner(ev){
    const lL=ev.shift?(ev.a&&ev.a.label||''):(ev.left&&ev.left.label||'');
    const rL=ev.shift?(ev.b&&ev.b.label||''):(ev.right&&ev.right.label||'');
    const intro=ev.intro||'Реши, как действовать.';
    return '<div class="dc-inner">'+
      '<span class="dc-badge">'+esc(ev.badge||'РЕШЕНИЕ')+'</span>'+
      '<div class="dc-title">'+esc(ev.title||'')+'</div>'+
      '<div class="dc-intro">'+esc(intro)+'</div>'+
      '<div class="dc-choices">'+
        '<div class="dc-choice left"><span class="dc-arrow">◄</span><span class="dc-lbl">'+esc(lL.replace(/^◄\\s*/,''))+'</span></div>'+
        '<div class="dc-or">или</div>'+
        '<div class="dc-choice right"><span class="dc-lbl">'+esc(rL.replace(/\\s*►$/,''))+'</span><span class="dc-arrow">►</span></div>'+
      '</div></div>';
  }'''
new='''  function decCardInner(ev){
    const intro=ev.intro||'Реши, как действовать.';
    return '<div class="dc-inner">'+
      '<span class="dc-badge">'+esc(ev.badge||'РЕШЕНИЕ')+'</span>'+
      '<div class="dc-title">'+esc(ev.title||'')+'</div>'+
      '<div class="dc-intro">'+esc(intro)+'</div>'+
      '<div class="dc-fire" id="dc-fire"></div>'+
      '</div>';
  }
  function decChoicesInner(ev){
    const lL=ev.shift?(ev.a&&ev.a.label||''):(ev.left&&ev.left.label||'');
    const rL=ev.shift?(ev.b&&ev.b.label||''):(ev.right&&ev.right.label||'');
    return '<div class="dc-choice left" data-side="left"><div class="dc-choice-in"><span>\\u25c4 '+esc(lL.replace(/^\\u25c4\\s*/,''))+'</span></div></div>'+
      '<div class="dc-choice right" data-side="right"><div class="dc-choice-in"><span>'+esc(rL.replace(/\\s*\\u25ba$/,''))+' \\u25ba</span></div></div>';
  }'''
if old in txt: txt=txt.replace(old,new,1); print("  + decCardInner без плашек + decChoicesInner отдельно")
else: print("  ⚠ decCardInner не найден")
open(path,"w",encoding="utf-8").write(txt)
PYEOF

echo ""; echo "══ 3/6  renderDecision: cardbox + плашки под картой ═"
python3 - << 'PYEOF'
path="games/feed.js"; txt=open(path,encoding="utf-8").read()
old='''      '<div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div>';'''
new='''      '<div class="dec-cardbox" id="dec-cardbox"><div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div></div>'+
      '<div class="dc-choices" id="dec-choices">'+decChoicesInner(ev)+'</div>';'''
if old in txt: txt=txt.replace(old,new,1); print("  + cardbox-обёртка + плашки под картой")
else: print("  ⚠ якорь renderDecision не найден")
# клики по плашкам
anchor="bindDecisionSwipe(ev); startDecTimer();"
inject='''(function(){
      var box=document.getElementById('dec-choices');
      if(box){ box.querySelectorAll('.dc-choice').forEach(function(c){
        c.addEventListener('click',function(){ commitDecision(ev, c.getAttribute('data-side')); });
      }); }
    })();
    bindDecisionSwipe(ev); startDecTimer();'''
if anchor in txt and "box.querySelectorAll('.dc-choice')" not in txt:
    txt=txt.replace(anchor,inject,1); print("  + клики по плашкам")
open(path,"w",encoding="utf-8").write(txt)
PYEOF

echo ""; echo "══ 4/6  свайп: подсветка плашек + вылет через cardbox ═"
python3 - << 'PYEOF'
path="games/feed.js"; txt=open(path,encoding="utf-8").read()
# paint: подсветка новых плашек
old='''      var stl=document.querySelector('.dec-sticker.l'),str2=document.querySelector('.dec-sticker.r');
      if(stl)stl.classList.toggle('lit',dx<-TH*0.4); if(str2)str2.classList.toggle('lit',dx>TH*0.4);
      var cl=card.querySelector('.dc-choice.left'),cr=card.querySelector('.dc-choice.right');
      if(cl)cl.classList.toggle('lit',dx<-TH*0.4); if(cr)cr.classList.toggle('lit',dx>TH*0.4);'''
new='''      var cl=document.querySelector('#dec-choices .dc-choice.left'),cr=document.querySelector('#dec-choices .dc-choice.right');
      if(cl)cl.classList.toggle('lit',dx<-TH*0.4); if(cr)cr.classList.toggle('lit',dx>TH*0.4);'''
if old in txt: txt=txt.replace(old,new,1); print("  + подсветка плашек под картой")
open(path,"w",encoding="utf-8").write(txt)
PYEOF

echo ""; echo "══ 5/6  burnCard → огонь-спрайт + вылет ═══════════"
python3 - << 'PYEOF'
path="games/feed.js"; txt=open(path,encoding="utf-8").read()
import re
# заменяем функцию burnCard целиком на спрайт-огонь
m=re.search(r'  function burnCard\(card\)\{.*?\n  \}\n', txt, re.DOTALL)
if m:
    new='''  function burnCard(card){
    if(!card)return;
    var box=document.getElementById('dec-cardbox');
    var inner=card.querySelector('.dc-inner');
    var fire=card.querySelector('.dc-fire');
    var COLS=5,ROWS=4,NFR=20;
    if(fire){
      var fw=fire.offsetWidth,fh=fire.offsetHeight;
      fire.style.backgroundSize=(fw*COLS)+'px '+(fh*ROWS)+'px';
      var frame=0;
      var iv=setInterval(function(){
        var cx=(frame%COLS)*fw,cy=Math.floor(frame/COLS)*fh;
        fire.style.backgroundPosition=(-cx)+'px '+(-cy)+'px';
        frame++; if(frame>=NFR)frame=0;
      },1000/24);
      fire.style.opacity='1';
      setTimeout(function(){clearInterval(iv);},1400);
    }
    if(inner){
      inner.style.filter='brightness(.6)';
      setTimeout(function(){inner.style.filter='brightness(.35) contrast(1.3) sepia(.4)';},300);
    }
    try{Sound.burn&&Sound.burn();}catch(_){}
  }
'''
    txt=txt[:m.start()]+new+txt[m.end():]
    print("  + burnCard = огонь-спрайт")
else: print("  ⚠ burnCard не найден")
open(path,"w",encoding="utf-8").write(txt)
PYEOF

echo ""; echo "══ 6/6  commitDecision: вылет cardbox (без дёрганья) ═"
python3 - << 'PYEOF'
path="games/feed.js"; txt=open(path,encoding="utf-8").read()
# в up(): при commit — не толкать карту, а запустить огонь + вылет cardbox
old='''      if(commit){var dir=(dx||vx)<0?-1:1;
        // короткий толчок в сторону выбора, затем сгорание на месте
        card.style.transition='transform .18s ease-out';
        card.style.transform='translate3d('+(dir*40)+'px,0,0) rotate('+(dir*4)+'deg)';
        try{vibrate&&vibrate(18)}catch(_){}
        commitDecision(ev,dir<0?'left':'right',true);
      } else {'''
new='''      if(commit){var dir=(dx||vx)<0?-1:1;
        try{vibrate&&vibrate(18)}catch(_){}
        commitDecision(ev,dir<0?'left':'right',true,dir);
      } else {'''
if old in txt: txt=txt.replace(old,new,1); print("  + свайп-commit без толчка")

# commitDecision: принять dir, запустить burnCard + вылет cardbox
# найдём сигнатуру
import re
txt=txt.replace("function commitDecision(ev,dir,flew){","function commitDecision(ev,dir,flew,swipeDir){",1)
# вставим вылет cardbox после burnCard вызова
old2="if(card)burnCard(card);"
new2='''if(card)burnCard(card);
    // вылет карты в сторону свайпа (одновременно с огнём)
    var box=document.getElementById('dec-cardbox');
    if(box&&flew){
      var dirs=(swipeDir||(dir==='left'?-1:1));
      var dist=window.innerWidth*1.3;
      box.style.transition='transform .85s cubic-bezier(.4,0,.6,1),opacity .7s ease-in .15s';
      requestAnimationFrame(function(){
        box.style.transform='translate3d('+(dirs*dist)+'px,-30px,0) rotate('+(dirs*24)+'deg) scale(.85)';
        box.style.opacity='0';
      });
    }'''
if old2 in txt: txt=txt.replace(old2,new2,1); print("  + вылет cardbox с огнём")
open(path,"w",encoding="utf-8").write(txt)
PYEOF

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R110 — утверждённая карта в игре (black+переливы+огонь+плашки)"
echo "   ⚠ СНАЧАЛА: unzip -o /sdcard/Download/огонь-спрайт.zip -d src/main/resources/static/img/cards/"
echo "   git add -A && git commit -m 'R110: approved black card with sheen and fire sprite' && git push"
echo "═══════════════════════════════════════════════════════"
