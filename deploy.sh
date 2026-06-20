#!/usr/bin/env bash
# СДВИГ R40 — фикс: narrator-обрывки, чёрный круг решения, сброс ленты, аватары, выдача улик
set -e

echo ""; echo "══ 1/5  сценарии — чистим dialogue-обрывки без речи ═"
python3 - << 'PYEOF'
import json, glob, re
# Убираем «обрывки» в dialogue которые НЕ являются речью (нет говорящего, короткий текст-нарратив)
# Признак обрывка: speaker отсутствует И текст не в кавычках И короткий
ORPHANS=['проклятие горгулий']  # известные обрывки
n=0
for f in sorted(glob.glob('src/main/resources/static/scenarios/case*.json')):
    d=json.load(open(f,encoding='utf-8')); ch=False
    for k,e in d['events'].items():
        dlg=e.get('dialogue','')
        # если нет speaker и dialogue без кавычек и не похож на реплику — убираем в text
        if dlg and not e.get('speaker') and '«' not in dlg and '»' not in dlg and ':' not in dlg:
            # это обрывок нарратива, не речь
            if e.get('text') and dlg not in e['text']:
                e['text']=e['text'].rstrip('. ')+'. '+dlg
            del e['dialogue']; ch=True; n+=1
    if ch: json.dump(d,open(f,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print(f"  + убрано обрывков-нарративов из dialogue: {n}")
PYEOF


echo ""; echo "══ 2/5  feed.js — narrator не показывается как имя ══"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# в buildMessages: реплики с speaker=null/narrator → как нарратив, не как пузырь с именем
old=("    if(ev.dialogue && window.parseDialogue){\n"
     "      const lines=parseDialogue(ev);\n"
     "      lines.forEach(l=>{\n"
     "        out.push({type:'speech', speaker:l.speaker, text:l.text});\n"
     "      });\n"
     "    }")
new=("    if(ev.dialogue && window.parseDialogue){\n"
     "      const lines=parseDialogue(ev);\n"
     "      lines.forEach(l=>{\n"
     "        if(!l.speaker || l.speaker==='narrator'){\n"
     "          out.push({type:'narr', text:l.text}); // безымянная реплика = нарратив\n"
     "        } else {\n"
     "          out.push({type:'speech', speaker:l.speaker, text:l.text});\n"
     "        }\n"
     "      });\n"
     "    }")
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + безымянные реплики идут как нарратив (нет 'narrator')")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/5  feed.js — лента НЕ сбрасывается при тапе ════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# pushEvent чистит ленту только если это НОВОЕ событие (не повторный показ того же)
old=("  function pushEvent(evId, instant){\n"
     "    const ev=CASE.events[evId]; if(!ev) return;\n"
     "    CState.ev=evId;\n"
     "    // ФИКС наложения: чистим ленту перед новым событием\n"
     "    if(_wrap) _wrap.innerHTML='';\n"
     "    _wrap.onclick=null;")
new=("  var _lastRenderedEv=null;\n"
     "  function pushEvent(evId, instant){\n"
     "    const ev=CASE.events[evId]; if(!ev) return;\n"
     "    // защита от повторного рендера того же события (лента не сбрасывается)\n"
     "    if(_lastRenderedEv===evId && _wrap && _wrap.children.length>0) return;\n"
     "    _lastRenderedEv=evId;\n"
     "    CState.ev=evId;\n"
     "    if(_wrap) _wrap.innerHTML='';\n"
     "    _wrap.onclick=null;")
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + защита от повторного рендера (лента стабильна)")
# reset обнуляет _lastRenderedEv
txt=txt.replace("reset(){ if(_wrap)_wrap.innerHTML='';",
                "reset(){ _lastRenderedEv=null; if(_wrap)_wrap.innerHTML='';")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 4/5  feed.js — CSS карты-решения (нет чёрного круга)"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".decision-stage{" in txt:
    print("  · CSS решения уже есть")
else:
    # добавляем недостающий CSS решения в инжект feed2-css
    anchor="    .clue-fly2{"
    css="""    .decision-stage{position:absolute;inset:0;z-index:40;display:flex;align-items:center;justify-content:center;
      background:radial-gradient(70% 60% at 50% 45%,rgba(10,14,22,.7),rgba(6,8,13,.95));}
    .dec-card{position:relative;width:min(74vw,300px);border-radius:18px;overflow:hidden;z-index:5;
      background:linear-gradient(160deg,rgba(28,23,16,.99),rgba(13,11,8,.99));
      border:1.5px solid var(--acc,#c8860a);box-shadow:0 16px 44px rgba(0,0,0,.6),0 0 28px rgba(200,134,10,.2);
      animation:decT 2.8s ease-in-out infinite;}
    @keyframes decT{0%,100%{transform:rotate(0) translate(0,0)}25%{transform:rotate(-.3deg) translate(-1.5px,1px)}
      50%{transform:rotate(.3deg) translate(1.5px,-1.5px)}75%{transform:rotate(-.15deg) translate(-1px,0)}}
    .dec-card.swipe-left{animation:decFL .5s ease-in forwards;}
    .dec-card.swipe-right{animation:decFR .5s ease-in forwards;}
    @keyframes decFL{to{transform:translateX(-140%) rotate(-18deg);opacity:0}}
    @keyframes decFR{to{transform:translateX(140%) rotate(18deg);opacity:0}}
    .dec-card .fc-pad{padding:18px 18px 20px;}
    .dec-card .fc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.12em;color:#ffcf6b;padding:5px 11px;border-radius:8px;
      background:rgba(200,134,10,.16);border:1px solid rgba(200,134,10,.4);margin-bottom:10px;}
    .dec-card .fc-title{font-family:Unbounded,sans-serif;font-weight:800;font-size:18px;line-height:1.15;color:#fff;}
    .outcome-cascade{position:absolute;top:50%;z-index:3;pointer-events:none;display:flex;flex-direction:column;gap:6px;
      opacity:0;transition:opacity .5s;}
    .outcome-cascade.show{opacity:1;}
    .outcome-cascade.left{left:2vw;transform:translateY(-50%);align-items:flex-start;}
    .outcome-cascade.right{right:2vw;transform:translateY(-50%);align-items:flex-end;}
    .oc-card{border-radius:10px;padding:7px 10px;font-size:10px;font-weight:700;font-family:Unbounded,sans-serif;
      color:#fff;white-space:nowrap;max-width:30vw;overflow:hidden;text-overflow:ellipsis;
      border:1px solid rgba(255,255,255,.18);box-shadow:0 4px 12px rgba(0,0,0,.4);}
    .outcome-cascade.left .oc-card{background:linear-gradient(160deg,rgba(176,80,80,.85),rgba(94,38,38,.9));}
    .outcome-cascade.right .oc-card{background:linear-gradient(160deg,rgba(74,155,142,.85),rgba(29,74,67,.9));}
    .oc-card:nth-child(1){transform:scale(1);opacity:1;}
    .oc-card:nth-child(2){transform:scale(.88);opacity:.78;}
    .oc-card:nth-child(3){transform:scale(.76);opacity:.56;}
    .oc-hint{position:absolute;bottom:13%;left:0;right:0;text-align:center;font-size:11px;color:#c8a05a;
      font-family:Unbounded,sans-serif;letter-spacing:.05em;}
    .dec-timer{position:absolute;top:7%;left:50%;transform:translateX(-50%);z-index:8;
      display:flex;flex-direction:column;align-items:center;gap:3px;}
    .dt-ring2{width:50px;height:50px;position:relative;}
    .dt-ring2 svg{width:100%;height:100%;transform:rotate(-90deg);}
    .dt-ring2 .bg{fill:none;stroke:rgba(255,255,255,.1);stroke-width:5;}
    .dt-ring2 .fg{fill:none;stroke:var(--acc,#c8860a);stroke-width:5;stroke-linecap:round;transition:stroke-dashoffset .25s linear,stroke .3s;}
    .dt-n{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:17px;color:#fff;}
    .dec-timer.urgent .fg{stroke:#ff5d6c;}
    .dec-timer.urgent .dt-n{color:#ff5d6c;animation:dtP .5s ease-in-out infinite;}
    @keyframes dtP{0%,100%{transform:scale(1)}50%{transform:scale(1.18)}}
"""
    txt=txt.replace(anchor, css+anchor, 1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS карты-решения добавлен (нет чёрного круга)")
PYEOF


echo ""; echo "══ 5/5  feed.js — аватар: лицо целиком (не обрезать) ═"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# аватар: показываем голову целиком. Фигура 800×1200, голова в верхних ~22%.
# background-size по ширине, position сверху, чтобы голова влезла
old=".m2-av{width:44px;height:44px;border-radius:12px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;\n      background-size:280%;background-position:center -2px;transition:all .3s;background-repeat:no-repeat;}"
new=".m2-av{width:44px;height:44px;border-radius:12px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;\n      background-size:160% auto;background-position:center top;transition:all .3s;background-repeat:no-repeat;}"
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + аватар: голова целиком (160% по ширине, сверху)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 6/6  улика к первой карте e0 (выдача сразу видна) ═"
python3 - << 'PYEOF2'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
e0=d['events']['e0']
if not e0.get('clue'):
    e0['clue']={'id':'oil_trace','name':'Машинное масло','icon':'⚙️',
        'proof':'Следы машинного масла на полу под телом. Призраки не оставляют масляных пятен.'}
    json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
    print("  + улика 'Машинное масло' на e0 (первая карта-решение)")
else:
    print("  - e0 уже имеет улику")
PYEOF2

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R40 — narrator/круг/сброс/аватары исправлены"
echo "   git add -A && git commit -m 'R40: fix narrator orphans, decision card CSS, feed reset, avatars' && git push"
echo "═══════════════════════════════════════════════════════"
