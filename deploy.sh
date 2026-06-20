#!/usr/bin/env bash
# СДВИГ R36 — улики = карточки знания в досье (фича вовлечённости #1)
set -e

echo ""; echo "══ 1/4  сценарии — улики с названием и смыслом ═════"
python3 - << 'PYEOF'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))

# Привязываем к картам-расследованиям КОНКРЕТНЫЕ улики (что доказывает)
EVIDENCE={
 "eL2c2":{"id":"portiera","name":"Надорванная портьера","icon":"🪟",
   "proof":"Ткань надорвана изнутри — кто-то прятался за ней до падения жертвы."},
 "eL2c3":{"id":"detail","name":"Чужая деталь","icon":"⚙️",
   "proof":"Шестерёнка не от музейного оборудования. След промышленного механизма."},
 "eL3c1":{"id":"miller_lie","name":"Ложь сторожа","icon":"🥃",
   "proof":"Миллер «спал», но магнит ставили 2 часа. Либо врёт, либо был не один."},
 "eL3c3":{"id":"bribe","name":"Пачка банкнот","icon":"💵",
   "proof":"Свежие купюры у сторожа. Кто-то купил его слепоту в ночь убийства."},
 "eL4c1":{"id":"answering","name":"Запись автоответчика","icon":"📼",
   "proof":"Механический голос на плёнке. Тот же тембр, что Сдвиг слышал в машине."},
}
n=0
for eid,ev in EVIDENCE.items():
    e=d['events'].get(eid)
    if e:
        e['clue']=ev  # привязка улики к карте
        n+=1
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print(f"  + {n} улик-знаний привязаны к картам case001")
PYEOF


echo ""; echo "══ 2/4  app.js — досье: хранение + выдача улики ════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# CState.evidence теперь хранит объекты-улики, не строки. Добавим функцию выдачи.
if "function grantClue" not in txt:
    anchor="function cAddEvidence("
    fn=('''function grantClue(clue){
  if(!clue||!clue.id) return;
  if(!CState.clues) CState.clues=[];
  if(CState.clues.some(function(c){return c.id===clue.id;})) return; // уже есть
  CState.clues.push(clue);
  if(_evCountEl) _evCountEl.textContent=CState.clues.length;
  try{ showClueReveal(clue); }catch(_){}
  try{ saveCaseState&&saveCaseState(); }catch(_){}
}
function showClueReveal(clue){
  // эффектная выдача: улика «ложится» в досье
  var ov=document.createElement('div'); ov.className='clue-reveal';
  ov.innerHTML='<div class="cr-card">'+
    '<div class="cr-ico">'+(clue.icon||'🔍')+'</div>'+
    '<div class="cr-label">УЛИКА НАЙДЕНА</div>'+
    '<div class="cr-name">'+esc(clue.name||'')+'</div>'+
    '<div class="cr-proof">'+esc(clue.proof||'')+'</div>'+
    '<div class="cr-hint">▸ в досье</div>'+
  '</div>';
  document.body.appendChild(ov);
  try{ Sound.approve&&Sound.approve(); vibrate&&vibrate([10,40,10]); }catch(_){}
  requestAnimationFrame(function(){ ov.classList.add('show'); });
  ov.onclick=function(){ ov.classList.add('tofile');
    setTimeout(function(){ if(ov.parentNode)ov.parentNode.removeChild(ov); },600); };
  setTimeout(function(){ if(ov.parentNode){ ov.classList.add('tofile');
    setTimeout(function(){ if(ov.parentNode)ov.parentNode.removeChild(ov); },600);} }, 3400);
}
''')
    txt=txt.replace(anchor, fn+anchor, 1); n+=1; print("  + grantClue + showClueReveal")

# инициализация CState.clues
txt=txt.replace("const CState={ev:CASE.start,flags:{},evidence:[],step:0};",
                "const CState={ev:CASE.start,flags:{},evidence:[],clues:[],step:0};")

# восстановление clues из сейва
old_load="if(_saved){ CState.ev=_saved.ev; CState.flags=_saved.flags||{}; CState.evidence=_saved.evidence||[]; CState.step=_saved.step||0;"
new_load="if(_saved){ CState.ev=_saved.ev; CState.flags=_saved.flags||{}; CState.evidence=_saved.evidence||[]; CState.clues=_saved.clues||[]; CState.step=_saved.step||0;"
if old_load in txt: txt=txt.replace(old_load,new_load,1); n+=1; print("  + восстановление улик из сейва")

# счётчик показывает clues
txt=txt.replace("if(_evCountEl)_evCountEl.textContent=CState.evidence.length; cSetProgress();",
                "if(_evCountEl)_evCountEl.textContent=(CState.clues?CState.clues.length:0); cSetProgress();")

# сохранение clues
txt=txt.replace("lsSet('sdvig_progress',{cid:cid,ev:CState.ev,flags:CState.flags,evidence:CState.evidence,step:CState.step});",
                "lsSet('sdvig_progress',{cid:cid,ev:CState.ev,flags:CState.flags,evidence:CState.evidence,clues:CState.clues,step:CState.step});")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/4  выдача улики после победы в мини-игре ══════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# При победе (onWin → unlockSwipe) выдаём улику текущей карты
# Найдём openMiniGame и добавим передачу clue
old="    if(window.openHintGame){\n      // openHintGame по победе вызовет unlockSwipe → Feed.enterDecision()\n      openHintGame(ev);"
new="    if(window.openHintGame){\n      window._pendingClue=ev.clue||null; // улика выдастся при победе\n      openHintGame(ev);"
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + улика запоминается перед мини-игрой")
with open(path,"w",encoding="utf-8") as f: f.write(txt)

# в app.js unlockSwipe выдаёт _pendingClue
path2="src/main/resources/static/app.js"
with open(path2,encoding="utf-8") as f: t2=f.read()
old2="function unlockSwipe(){\n  App.swipeUnlocked=true;\n  vibrate(20); try{Sound.booster();}catch(_){}\n  try{removeLockOverlay();}catch(_){}"
new2="function unlockSwipe(){\n  App.swipeUnlocked=true;\n  vibrate(20); try{Sound.booster();}catch(_){}\n  try{removeLockOverlay();}catch(_){}\n  try{ if(window._pendingClue){ grantClue(window._pendingClue); window._pendingClue=null; } }catch(_){}"
if old2 in t2: t2=t2.replace(old2,new2,1); n+=1; print("  + улика выдаётся при победе")
with open(path2,"w",encoding="utf-8") as f: f.write(t2)
print("✓ %d"%n)
PYEOF


echo ""; echo "══ 4/4  досье-панель + CSS выдачи улики ════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
# обновляем initEvPanel — показываем улики-карточки
old='''    list.innerHTML=CState.evidence.length
      ? CState.evidence.map(function(t){return '<div class="ev-item">'+t+'</div>';}).join("")
      : '<div class="ev-empty">Улики появятся по ходу расследования.</div>';'''
new='''    var cl=CState.clues||[];
    list.innerHTML=cl.length
      ? cl.map(function(c){return '<div class="ev-clue"><div class="ec-ico">'+(c.icon||'🔍')+'</div>'+
          '<div class="ec-body"><div class="ec-name">'+c.name+'</div><div class="ec-proof">'+c.proof+'</div></div></div>';}).join("")
      : '<div class="ev-empty">Улики появятся по ходу расследования.</div>';'''
if old in txt: txt=txt.replace(old,new,1); print("  + досье показывает улики-карточки")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

python3 - << 'PYEOF'
path="src/main/resources/static/card-design.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if "/* R36 */" not in txt:
    css='''
/* ════ R36 — улика = карточка знания ════ */
.clue-reveal{position:fixed;inset:0;z-index:80;display:flex;align-items:center;justify-content:center;
  background:rgba(6,8,13,.7);opacity:0;transition:opacity .4s;pointer-events:none;}
.clue-reveal.show{opacity:1;pointer-events:auto;}
.cr-card{width:min(78vw,320px);border-radius:18px;padding:24px 22px;text-align:center;
  background:linear-gradient(160deg,rgba(30,24,16,.99),rgba(14,11,8,.99));
  border:1.5px solid var(--acc,#c8860a);box-shadow:0 20px 50px rgba(0,0,0,.6),0 0 30px rgba(200,134,10,.25);
  transform:translateY(30px) scale(.9);transition:transform .5s cubic-bezier(.2,1.3,.4,1);}
.clue-reveal.show .cr-card{transform:none;}
.clue-reveal.tofile .cr-card{transform:translate(-40vw,40vh) scale(.2);opacity:0;transition:all .6s cubic-bezier(.5,0,.7,1);}
.cr-ico{font-size:54px;margin-bottom:8px;filter:drop-shadow(0 4px 12px rgba(0,0,0,.5));}
.cr-label{font-family:Unbounded,sans-serif;font-size:10px;letter-spacing:.18em;color:var(--acc,#c8860a);margin-bottom:6px;}
.cr-name{font-family:Unbounded,sans-serif;font-weight:900;font-size:19px;color:#fff;margin-bottom:10px;}
.cr-proof{font-size:13px;line-height:1.5;color:#d8cfbe;font-style:italic;margin-bottom:14px;}
.cr-hint{font-size:11px;color:#c8a05a;letter-spacing:.05em;font-family:Unbounded,sans-serif;opacity:.7;}
/* досье */
.ev-clue{display:flex;gap:11px;align-items:flex-start;padding:11px 12px;margin-bottom:8px;border-radius:12px;
  background:rgba(200,134,10,.07);border:1px solid rgba(200,134,10,.22);border-left:3px solid var(--acc,#c8860a);}
.ec-ico{font-size:26px;line-height:1;flex-shrink:0;}
.ec-name{font-family:Unbounded,sans-serif;font-weight:800;font-size:13px;color:var(--acc-2,#ffcf6b);margin-bottom:3px;}
.ec-proof{font-size:11.5px;line-height:1.42;color:#cabfaf;}
'''
    txt+="\n/* R36 */\n"+css
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS выдачи улики + досье")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R36 — улики стали знанием (карточки в досье)"
echo "   git add -A && git commit -m 'R36: clues as knowledge cards in dossier' && git push"
echo "═══════════════════════════════════════════════════════"
