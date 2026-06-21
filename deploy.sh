#!/usr/bin/env bash
# СДВИГ R50 — шкалы влияют на концовку дела + предупреждение при просадке
set -e
echo "══ штамп → R50 ══"
sed -i "s/SDVIG_BUILD='R49'/SDVIG_BUILD='R50'/" src/main/resources/static/app.js
sed -i 's/>R49</>R50</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  computeEnding — учитывает обе шкалы ════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''function computeEnding(f){
  const t=CASE.truth;
  const keys=Object.keys(t);
  const align=keys.filter(function(k){return f[k]===t[k];}).length;
  const e=CASE.endings||{};
  if(align===keys.length&&e.win)  return Object.assign({},e.win,{align:align});
  if(align>=Math.ceil(keys.length/2)&&e.partial) return Object.assign({},e.partial,{align:align});
  return Object.assign({},e.fail||{mark:'✗',verdict:'ПРОВАЛ',text:'Сдвиг промолчал.'},{ align:align,kind:'fail'});
}'''
new='''function computeEnding(f){
  const t=CASE.truth;
  const keys=Object.keys(t);
  const align=keys.filter(function(k){return f[k]===t[k];}).length;
  const e=CASE.endings||{};
  var p=App.profile||{};
  var rap=clamp(p.rapport||0,0,100), det=clamp(p.skill||30,0,100);
  // базовая концовка по сходимости версий
  var base;
  if(align===keys.length&&e.win)  base=Object.assign({},e.win,{align:align});
  else if(align>=Math.ceil(keys.length/2)&&e.partial) base=Object.assign({},e.partial,{align:align});
  else base=Object.assign({},e.fail||{mark:'✗',verdict:'ПРОВАЛ',text:'Сдвиг промолчал.'},{align:align,kind:'fail'});
  // шкалы добавляют эпилог-оттенок (задел на сквозную драму)
  base.rap=rap; base.det=det;
  if(base.kind==='win'){
    if(rap>=60 && det>=60) base.epilogue='Сдвиг хлопнул тебя по плечу. «Напарник». Впервые это слово прозвучало всерьёз.';
    else if(det>=60 && rap<40) base.epilogue='Ты раскрыл дело блестяще. Но Сдвиг смотрел на тебя холодно — машина, а не человек. «Берегись, рекрут. Лёд трескается изнутри».';
    else if(rap>=60 && det<40) base.epilogue='«Голова у тебя ещё сырая, но сердце на месте, — буркнул Сдвиг. — С этим можно работать».';
  }
  return base;
}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + computeEnding учитывает rapport+skill (эпилог-оттенок)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/3  showEnding — показ шкал + эпилог в финале ══"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# meta-строка: показываем обе шкалы
old='const meta=document.getElementById("e-meta");if(meta)meta.innerHTML="Сходимость: <b>"+r.align+" / 3</b> · улик: <b>"+CState.evidence.length+"</b> · Сдвиг: <b>"+rapportTitle()+"</b>";'
new='''const meta=document.getElementById("e-meta");if(meta){
    var _rt=(typeof rapTitle==='function')?rapTitle(r.rap||0):'';
    var _dt=(typeof detTitle==='function')?detTitle(r.det||0):'';
    meta.innerHTML="Сходимость: <b>"+r.align+" / 3</b> · 🎩 Сдвиг: <b style='color:#ff8fb0'>"+(r.rap||0)+" "+_rt+"</b> · 🔍 Детектив: <b style='color:#46d89b'>"+(r.det||0)+" "+_dt+"</b>";
  }
  // эпилог-оттенок от шкал
  if(r.epilogue){
    var _te=document.getElementById("e-text");
    if(_te) _te.textContent=(r.text||'')+"\\n\\n"+r.epilogue;
  }'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + финал показывает обе шкалы + эпилог")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/3  предупреждение при просадке шкалы (точка 1) ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# после показа концовки — если шкала просела, Сдвиг предупреждает (задел на увольнение в деле 3)
if "_scaleWarning" not in txt:
    anchor="function showEnding(r){"
    fn='''function _scaleWarning(r){
  // предупреждение при низких шкалах (драматический задел)
  var msg=null;
  if((r.rap||50)<25) msg='Сдвиг задержался у двери. «Ты хорош, рекрут. Слишком хорош, чтобы слушать. Смотри, не останься один». — Отношения на грани. Если упадут ещё — он уйдёт.';
  else if((r.det||30)<25) msg='«Ты идёшь за мной, как тень, — сказал Сдвиг. — А тень не раскрывает дел. Учись думать сам». — Детективность слишком низкая.';
  if(msg){
    setTimeout(function(){ try{ toast('Предупреждение', msg, '⚠'); }catch(_){} }, 2600);
  }
}
'''
    txt=txt.replace(anchor, fn+anchor, 1); n+=1; print("  + _scaleWarning (предупреждение при просадке)")

# вызываем предупреждение в showEnding
txt=txt.replace('haptic(r.kind==="fail"?"shift":"burn"); endEl.classList.add("show");',
                'haptic(r.kind==="fail"?"shift":"burn"); endEl.classList.add("show"); try{ _scaleWarning(r); }catch(_){}')
n+=1
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R50 — шкалы влияют на концовку + предупреждение"
echo "   git add -A && git commit -m 'R50: scales affect ending + low-scale warning' && git push"
echo "═══════════════════════════════════════════════════════"
