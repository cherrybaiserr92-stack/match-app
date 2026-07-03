#!/usr/bin/env bash
# СДВИГ R101 — ПЕРЕРАБОТКА КАРТОЧКИ СВАЙПА: физика velocity+пружина, штампы, стопка, багровый
set -e
echo "══ штамп → R101 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R101'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R101</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/5  CSS карточки: багровый + grabbed/spring/штампы ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# 1) корпус карты: багровая рамка, will-change, touch-action + состояния grabbed/spring + штампы
old="""    .dec-card{position:relative;width:min(80vw,320px);margin-top:56px;border-radius:18px;overflow:hidden;z-index:5;
      background:linear-gradient(160deg,rgba(28,23,16,.99),rgba(13,11,8,.99));
      border:1.5px solid var(--acc,#c8860a);box-shadow:0 16px 44px rgba(0,0,0,.6),0 0 28px rgba(200,134,10,.2);
      animation:decT 2.8s ease-in-out infinite;}"""
new="""    .dec-card{position:relative;width:min(80vw,320px);margin-top:56px;border-radius:18px;overflow:hidden;z-index:5;
      background:linear-gradient(165deg,#191216 0%,#100b0e 55%,#0b0709 100%);
      border:1.5px solid #b02642;box-shadow:0 18px 48px rgba(0,0,0,.65),0 0 30px rgba(176,38,66,.22),inset 0 1px 0 rgba(255,255,255,.06);
      animation:decT 2.8s ease-in-out infinite;touch-action:none;will-change:transform;cursor:grab;}
    .dec-card.grabbed{animation:none;cursor:grabbing;
      box-shadow:0 26px 60px rgba(0,0,0,.72),0 0 42px rgba(176,38,66,.32),inset 0 1px 0 rgba(255,255,255,.08);}
    .dec-card.spring{transition:transform .45s cubic-bezier(.34,1.56,.64,1);}
    .dc-stamp{position:absolute;top:14px;max-width:46%;padding:6px 11px;border-radius:9px;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:12px;line-height:1.15;letter-spacing:.06em;
      opacity:0;pointer-events:none;z-index:6;text-transform:uppercase;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
    .dc-stamp.left{left:12px;transform:rotate(-11deg);color:#ffa1a1;border:2.5px solid rgba(224,106,106,.95);background:rgba(122,32,32,.32);}
    .dc-stamp.right{right:12px;transform:rotate(11deg);color:#8ceed6;border:2.5px solid rgba(116,216,190,.95);background:rgba(30,92,76,.32);}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + корпус: багровый, grabbed/spring, штампы")

# 2) бейдж: золото → багровый
old2="""    .dc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.14em;color:#241701;padding:5px 13px;border-radius:8px;
      background:linear-gradient(180deg,#ffe09a,#c8860a);margin-bottom:12px;}"""
new2="""    .dc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.14em;color:#fff;padding:5px 13px;border-radius:8px;
      background:linear-gradient(180deg,#e0546e,#8e1e36);box-shadow:0 3px 10px rgba(142,30,54,.4);margin-bottom:12px;}"""
if old2 in txt: txt=txt.replace(old2,new2,1); n+=1; print("  + бейдж багровый")

# 3) заголовок: нормальный перенос (без hyphens:auto), баланс строк
old3="""    .dc-title{font-family:Unbounded,sans-serif;font-weight:900;font-size:18px;line-height:1.15;color:#fff;margin-bottom:8px;word-wrap:break-word;overflow-wrap:break-word;hyphens:auto;}"""
new3="""    .dc-title{font-family:Unbounded,sans-serif;font-weight:900;font-size:clamp(16px,4.6vw,19px);line-height:1.24;color:#fff;margin-bottom:8px;overflow-wrap:break-word;hyphens:none;text-wrap:balance;}"""
if old3 in txt: txt=txt.replace(old3,new3,1); n+=1; print("  + заголовок: перенос по словам, balance")

# 4) интро: воздух и ровный перенос
old4="""    .dc-intro{font-size:13px;line-height:1.5;color:#b8b0a0;font-style:italic;margin-bottom:18px;}"""
new4="""    .dc-intro{font-size:13.5px;line-height:1.58;color:#c2bab0;font-style:italic;margin-bottom:18px;overflow-wrap:break-word;hyphens:none;text-wrap:pretty;}"""
if old4 in txt: txt=txt.replace(old4,new4,1); n+=1; print("  + интро: типографика")

# 5) кнопки-варианты: без кривых переносов
old5="""    .dc-choice{flex:1;min-width:0;display:flex;align-items:center;gap:6px;padding:12px 10px;border-radius:12px;
      font-family:Unbounded,sans-serif;font-weight:700;font-size:11px;line-height:1.2;transition:transform .15s;
      word-wrap:break-word;overflow-wrap:break-word;hyphens:auto;box-sizing:border-box;}"""
new5="""    .dc-choice{flex:1;min-width:0;display:flex;align-items:center;gap:6px;padding:12px 11px;border-radius:12px;
      font-family:Unbounded,sans-serif;font-weight:700;font-size:11px;line-height:1.3;transition:transform .15s,box-shadow .2s;
      overflow-wrap:break-word;hyphens:none;box-sizing:border-box;}"""
if old5 in txt: txt=txt.replace(old5,new5,1); n+=1; print("  + варианты: перенос по словам")

# 6) кольцо таймера: золото → багровый
old6="""    .dt-ring2 .fg{fill:none;stroke:var(--acc,#c8860a);stroke-width:5;stroke-linecap:round;transition:stroke-dashoffset .25s linear,stroke .3s;}"""
new6="""    .dt-ring2 .fg{fill:none;stroke:#d84a64;stroke-width:5;stroke-linecap:round;transition:stroke-dashoffset .25s linear,stroke .3s;}"""
if old6 in txt: txt=txt.replace(old6,new6,1); n+=1; print("  + таймер багровый")

# 7) подсказка снизу: золото → приглушённый багровый
old7="""    .oc-hint{position:absolute;bottom:6%;left:0;right:0;text-align:center;font-size:11px;color:#c8a05a;
      font-family:Unbounded,sans-serif;letter-spacing:.05em;}"""
new7="""    .oc-hint{position:absolute;bottom:6%;left:0;right:0;text-align:center;font-size:11px;color:#c06478;
      font-family:Unbounded,sans-serif;letter-spacing:.05em;}"""
if old7 in txt: txt=txt.replace(old7,new7,1); n+=1; print("  + подсказка багровая")

# 8) шапка shift-версии внутри карты решения: золото → багровый
old8="""    .dec-card .fc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.12em;color:#ffcf6b;padding:5px 11px;border-radius:8px;
      background:rgba(200,134,10,.16);border:1px solid rgba(200,134,10,.4);margin-bottom:10px;}"""
new8="""    .dec-card .fc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.12em;color:#ff9db2;padding:5px 11px;border-radius:8px;
      background:rgba(176,38,66,.16);border:1px solid rgba(216,74,100,.42);margin-bottom:10px;}"""
if old8 in txt: txt=txt.replace(old8,new8,1); n+=1; print("  + шапка shift-версии багровая")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ CSS: %d/8"%n)
PYEOF

echo ""; echo "══ 2/5  НОВАЯ ФИЗИКА СВАЙПА (velocity+флик+пружина) ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""  function bindDecisionSwipe(ev){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,down=false;
    card.addEventListener('pointerdown',e=>{down=true;sx=e.clientX;card.setPointerCapture&&card.setPointerCapture(e.pointerId);});
    card.addEventListener('pointermove',e=>{if(!down)return;const dx=e.clientX-sx;
      card.style.transform='translateX('+dx*.5+'px) rotate('+dx*.02+'deg)';
      var cl=card.querySelector('.dc-choice.left'),cr=card.querySelector('.dc-choice.right');
      if(cl)cl.classList.toggle('lit',dx<-30); if(cr)cr.classList.toggle('lit',dx>30);});
    card.addEventListener('pointerup',e=>{if(!down)return;down=false;const dx=e.clientX-sx;
      if(Math.abs(dx)>60)commitDecision(ev,dx<0?'left':'right');else card.style.transform='';});
  }"""
new="""  function bindDecisionSwipe(ev){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,sy=0,down=false,dx=0,dy=0,vx=0,lastX=0,lastT=0,raf=0,armed=false;
    const TH=Math.min(window.innerWidth*0.28,120);   // порог по дистанции
    const FLICK=0.55;                                 // порог по скорости, px/ms
    card.style.transformOrigin='50% 115%';            // поворот от нижнего края
    function paint(){
      raf=0;
      const rot=dx*0.07, ty=Math.abs(dx)*-0.04+dy*0.12;
      card.style.transform='translate3d('+dx+'px,'+ty+'px,0) rotate('+rot+'deg) scale(1.02)';
      const p=Math.min(1,Math.abs(dx)/TH);
      const sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');
      if(sl)sl.style.opacity=dx<0?p:0;
      if(sr)sr.style.opacity=dx>0?p:0;
      const cl=card.querySelector('.dc-choice.left'),cr=card.querySelector('.dc-choice.right');
      if(cl)cl.classList.toggle('lit',dx<-TH*0.4);
      if(cr)cr.classList.toggle('lit',dx>TH*0.4);
      const over=Math.abs(dx)>TH;
      if(over&&!armed){armed=true;try{vibrate&&vibrate(8);}catch(_){}try{Sound.tap&&Sound.tap();}catch(_){}}
      else if(!over&&armed){armed=false;}
    }
    function onDown(e){
      down=true;dx=0;dy=0;vx=0;sx=e.clientX;sy=e.clientY;lastX=e.clientX;lastT=performance.now();
      card.classList.remove('spring');card.classList.add('grabbed');
      card.setPointerCapture&&card.setPointerCapture(e.pointerId);
    }
    function onMove(e){
      if(!down)return;
      const t=performance.now();
      dx=e.clientX-sx; dy=e.clientY-sy;
      const dt=Math.max(1,t-lastT);
      vx=vx*0.8+((e.clientX-lastX)/dt)*0.2;           // сглаженная скорость
      lastX=e.clientX;lastT=t;
      if(!raf)raf=requestAnimationFrame(paint);
    }
    function onUp(){
      if(!down)return;down=false;
      card.classList.remove('grabbed');
      if(raf){cancelAnimationFrame(raf);raf=0;}
      const commit=Math.abs(dx)>TH||(Math.abs(vx)>FLICK&&Math.abs(dx)>24);
      if(commit){
        flyOut(); commitDecision(ev,(dx||vx)<0?'left':'right',true);
      }else{
        card.classList.add('spring');
        card.style.transform='';
        const sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');
        if(sl)sl.style.opacity=0; if(sr)sr.style.opacity=0;
        card.querySelectorAll('.dc-choice.lit').forEach(c=>c.classList.remove('lit'));
        armed=false;
        setTimeout(()=>card.classList.remove('spring'),470);
      }
    }
    function flyOut(){
      const dir=(dx||vx)<0?-1:1;
      const dist=window.innerWidth*1.2;
      const speed=Math.max(Math.abs(vx),0.9);          // px/ms — вылет со скоростью пальца
      const dur=Math.min(520,Math.max(240,dist/speed));
      card.style.transition='transform '+dur+'ms cubic-bezier(.22,.9,.36,1),opacity '+dur+'ms ease';
      card.style.transform='translate3d('+(dir*dist)+'px,'+(-dist*0.08)+'px,0) rotate('+(dir*24)+'deg)';
      card.style.opacity='0';
    }
    card.addEventListener('pointerdown',onDown);
    card.addEventListener('pointermove',onMove);
    card.addEventListener('pointerup',onUp);
    card.addEventListener('pointercancel',onUp);
  }"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + физика: velocity, флик, пружина, вылет со скоростью пальца")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ swipe: %d/1"%n)
PYEOF

echo ""; echo "══ 3/5  commitDecision: без двойной анимации ══════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if "function commitDecision(ev,dir,flew)" not in txt:
    txt=txt.replace("function commitDecision(ev,dir){","function commitDecision(ev,dir,flew){",1); n+=1
    txt=txt.replace("if(card)card.classList.add(dir==='left'?'swipe-left':'swipe-right');",
                    "if(card&&!flew)card.classList.add(dir==='left'?'swipe-left':'swipe-right');",1); n+=1
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ commit: %d/2 (таймер/клавиши работают по-старому)"%n)
PYEOF

echo ""; echo "══ 4/5  штампы-подсказки в разметку карты ═════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""    return '<div class="dc-inner">'+
      '<span class="dc-badge">'+esc(ev.badge||'РЕШЕНИЕ')+'</span>'+"""
new="""    const stampL=esc((lL||'').replace(/^\\u25c4\\s*/,'').split(/\\s+/).slice(0,2).join(' '));
    const stampR=esc((rL||'').replace(/\\s*\\u25ba$/,'').split(/\\s+/).slice(0,2).join(' '));
    return '<div class="dc-inner">'+
      '<div class="dc-stamp left">'+stampL+'</div>'+
      '<div class="dc-stamp right">'+stampR+'</div>'+
      '<span class="dc-badge">'+esc(ev.badge||'РЕШЕНИЕ')+'</span>'+"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + штампы (первые 2 слова варианта) проявляются при свайпе")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ stamps: %d/1"%n)
PYEOF

echo ""; echo "══ 5/5  стопка карт под текущей (глубина) ═════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""    stage.appendChild(dec);
    requestAnimationFrame(()=>dec.querySelectorAll('.outcome-cascade').forEach(c=>c.classList.add('show')));
    bindDecisionSwipe(ev); startDecTimer();"""
new="""    stage.appendChild(dec);
    requestAnimationFrame(()=>{
      dec.querySelectorAll('.outcome-cascade').forEach(c=>c.classList.add('show'));
      try{
        var c=document.getElementById('dec-card');
        if(c){
          var r={l:c.offsetLeft,t:c.offsetTop,w:c.offsetWidth,h:c.offsetHeight};
          for(var i=2;i>=1;i--){
            var d=document.createElement('div');d.className='dec-deck';
            d.style.cssText='position:absolute;left:'+r.l+'px;top:'+(r.t+i*9)+'px;width:'+r.w+'px;height:'+r.h+'px;'+
              'border-radius:18px;z-index:'+(4-i)+';transform:scale('+(1-i*0.05)+');transform-origin:50% 0;'+
              'background:linear-gradient(165deg,#141014,#0b080a);border:1px solid rgba(176,38,66,'+(0.35-i*0.12)+');'+
              'box-shadow:0 10px 26px rgba(0,0,0,.45);pointer-events:none;';
            dec.insertBefore(d,c);
          }
        }
      }catch(_){}
    });
    bindDecisionSwipe(ev); startDecTimer();"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + две карты-подложки со scale-глубиной")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ deck: %d/1"%n)
PYEOF

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js синтаксис OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R101 — карточка свайпа переработана (физика/штампы/стопка/багровый)"
echo "   git add -A && git commit -m 'R101: swipe card rework - physics, stamps, deck, crimson' && git push"
echo "═══════════════════════════════════════════════════════"
