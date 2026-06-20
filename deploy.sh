#!/usr/bin/env bash
# СДВИГ R44 — накопительная лента (история главы), фикс застревания, защита от пересоздания
set -e

echo ""; echo "══ 1/3  feed.js — НАКОПИТЕЛЬНАЯ лента (история) ════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Храним историю показанных событий
if "var _history=[]" not in txt:
    txt=txt.replace("  let _wrap=null, _busy=false, _decision=false, _decTimer=null;",
        "  let _wrap=null, _busy=false, _decision=false, _decTimer=null;\n  var _history=[];  // история показанных событий (вся глава)\n  var _builtFor=null;  // для какого CState.ev построена лента")
    n+=1; print("  + хранилище истории _history")

# pushEvent: НЕ чистим ленту — добавляем событие к истории
old=("  function pushEvent(evId, instant){\n"
     "    const ev=CASE.events[evId]; if(!ev) return;\n"
     "    // защита от повторного рендера того же события (лента не сбрасывается)\n"
     "    if(_lastRenderedEv===evId && _wrap && _wrap.children.length>0) return;\n"
     "    _lastRenderedEv=evId;\n"
     "    CState.ev=evId;\n"
     "    if(_wrap) _wrap.innerHTML='';\n"
     "    _wrap.onclick=null;\n"
     "    try{ if(window.updateCaseBg) updateCaseBg(); }catch(_){}")
new=("  function pushEvent(evId, instant){\n"
     "    const ev=CASE.events[evId]; if(!ev) return;\n"
     "    // защита от повторного рендера того же события\n"
     "    if(_lastRenderedEv===evId && _wrap && _wrap.children.length>0) return;\n"
     "    _lastRenderedEv=evId;\n"
     "    CState.ev=evId;\n"
     "    // добавляем в историю (не дублируя)\n"
     "    if(_history.indexOf(evId)<0) _history.push(evId);\n"
     "    // убираем прошлую кнопку/подсказку, но НЕ стираем ленту (история копится)\n"
     "    var oldc=_wrap.querySelector('.feed2-next,.feed2-find'); if(oldc)oldc.remove();\n"
     "    _wrap.onclick=null;\n"
     "    // прошлые сообщения тускнеют\n"
     "    _wrap.querySelectorAll('.msg2').forEach(function(m){ m.classList.add('m2-past'); m.classList.remove('active'); });\n"
     "    try{ if(window.updateCaseBg) updateCaseBg(); }catch(_){}")
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + события КОПЯТСЯ в ленте (история главы)")

# разделитель события (тонкая линия с бейджем) перед новым событием
old_msgs="    const msgs=buildMessages(ev);\n    let mi=0;"
new_msgs=("    // разделитель главы перед новым событием (кроме первого)\n"
          "    if(_wrap.children.length>0 && ev.badge){\n"
          "      var sep=document.createElement('div'); sep.className='feed2-sep';\n"
          "      sep.innerHTML='<span>'+esc(ev.badge)+'</span>';\n"
          "      _wrap.appendChild(sep);\n"
          "    }\n"
          "    const msgs=buildMessages(ev);\n    let mi=0;")
if old_msgs in txt:
    txt=txt.replace(old_msgs,new_msgs,1); n+=1; print("  + разделитель между событиями")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 2/3  feed.js — init восстанавливает ВСЮ историю ═"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# renderFromState: восстанавливаем всю историю, не только текущее
old=("  function renderFromState(){\n"
     "    if(!_wrap) return; _wrap.innerHTML='';\n"
     "    pushEvent(CState.ev||CASE.start, true);\n"
     "  }")
new=("  function renderFromState(){\n"
     "    if(!_wrap) return;\n"
     "    // если лента уже построена для этого события — не пересоздаём (не мигает)\n"
     "    if(_builtFor===CState.ev && _wrap.children.length>0) return;\n"
     "    _builtFor=CState.ev;\n"
     "    _wrap.innerHTML=''; _lastRenderedEv=null;\n"
     "    // восстанавливаем всю историю кроме последнего (его покажем интерактивно)\n"
     "    var hist=_history.slice(); var cur=CState.ev||CASE.start;\n"
     "    if(hist.length===0 || hist[hist.length-1]!==cur){\n"
     "      // нет истории — начинаем с текущего\n"
     "      pushEvent(cur, true);\n"
     "    } else {\n"
     "      // восстанавливаем прошлые события статично, последнее — интерактивно\n"
     "      for(var i=0;i<hist.length-1;i++){ renderStatic(hist[i]); }\n"
     "      _lastRenderedEv=null; pushEvent(cur, true);\n"
     "    }\n"
     "  }\n"
     "  // статичный рендер прошлого события (вся реплики сразу, без печати)\n"
     "  function renderStatic(evId){\n"
     "    var ev=CASE.events[evId]; if(!ev) return;\n"
     "    if(ev.badge && _wrap.children.length>0){\n"
     "      var sep=document.createElement('div'); sep.className='feed2-sep';\n"
     "      sep.innerHTML='<span>'+esc(ev.badge)+'</span>'; _wrap.appendChild(sep);\n"
     "    }\n"
     "    var msgs=buildMessages(ev);\n"
     "    msgs.forEach(function(m){ addMessageStatic(m); });\n"
     "  }\n"
     "  // добавить сообщение без анимации печати (для истории)\n"
     "  function addMessageStatic(m){\n"
     "    var el=document.createElement('div');\n"
     "    if(m.type==='narr'){ el.className='msg2 narr m2-past';\n"
     "      el.innerHTML='<div class=\"m2-narr\">'+renderClues(m.text)+'</div>'; }\n"
     "    else if(m.type==='deduce'){ el.className='msg2 deduce m2-past';\n"
     "      el.innerHTML='<div class=\"m2-av\">🧠</div><div class=\"m2-body\"><div class=\"m2-head\"><span class=\"m2-nm\">Дедукция</span></div><div class=\"m2-bubble\">'+renderClues(m.text)+'</div></div>'; }\n"
     "    else { var spk=m.speaker||'narrator'; var cls=(spk==='shift')?'shift':(spk==='recruit')?'recruit':'other';\n"
     "      el.className='msg2 '+cls+' m2-past';\n"
     "      el.innerHTML='<div class=\"m2-av\" style=\"background-image:url('+avatar(spk)+')\"></div><div class=\"m2-body\"><div class=\"m2-head\"><span class=\"m2-nm\">'+(NAMES[spk]||spk)+'</span></div><div class=\"m2-bubble\">'+renderClues(m.text)+'</div></div>'; }\n"
     "    _wrap.appendChild(el);\n"
     "    var b=el.querySelector('.m2-bubble,.m2-narr'); if(b) bindClues(b);\n"
     "  }")
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + init восстанавливает ВСЮ историю главы")

# reset чистит историю
txt=txt.replace("reset(){ _lastRenderedEv=null; if(_wrap)_wrap.innerHTML='';",
                "reset(){ _lastRenderedEv=null; _history=[]; _builtFor=null; if(_wrap)_wrap.innerHTML='';")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/3  CSS — разделитель + тусклые прошлые реплики ═"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".feed2-sep" not in txt:
    anchor="    .clue-fly2{"
    css=("""    .feed2-sep{display:flex;align-items:center;gap:10px;margin:6px 2px;opacity:.5;}
    .feed2-sep::before,.feed2-sep::after{content:'';flex:1;height:1px;background:linear-gradient(90deg,transparent,rgba(200,134,10,.4),transparent);}
    .feed2-sep span{font-family:Unbounded,sans-serif;font-size:9px;letter-spacing:.12em;color:#c8a05a;text-transform:uppercase;white-space:nowrap;}
    .msg2.m2-past{opacity:.62;}
    .msg2.m2-past .m2-av{filter:grayscale(.3) brightness(.85);}
""")
    txt=txt.replace(anchor,css+anchor,1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS разделителя и тусклых прошлых реплик")
PYEOF


echo ""; echo "══ штамп версии R44 (видно живую версию) ══════════"
python3 - << 'PYEOF2'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
# выводим версию в консоль и на экран при старте
if "SDVIG_BUILD" not in txt:
    txt="window.SDVIG_BUILD='R44';console.log('%cСДВИГ '+window.SDVIG_BUILD,'color:#c8860a;font-weight:bold');\n"+txt
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + штамп R44 (в консоли F12 видно версию)")
PYEOF2

# маленький штамп в углу шапки
python3 - << 'PYEOF3'
import re
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
if "build-tag" not in txt:
    # добавляем после <body>
    txt=re.sub(r'(<body[^>]*>)', r'\1\n<div id="build-tag" style="position:fixed;bottom:2px;right:4px;z-index:9999;font-size:8px;color:rgba(200,160,90,.4);pointer-events:none;font-family:monospace">R44</div>', txt, count=1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + штамп R44 в углу экрана")
PYEOF3

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R44 — лента копит историю главы (видно с начала)"
echo "   git add -A && git commit -m 'R44: accumulative feed - full chapter history visible' && git push"
echo "═══════════════════════════════════════════════════════"
