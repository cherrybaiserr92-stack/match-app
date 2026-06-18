#!/usr/bin/env bash
# СДВИГ R15 — сохранение/восстановление прогресса внутри дела
set -e
echo ""; echo "══ app.js — save/resume case progress ══════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n = 0

# ── 1. функции сохранения/загрузки CState ──────────────
if "function saveCaseState" not in txt:
    anchor = "function initCarousel(){"
    fns = (
        "function saveCaseState(){\n"
        "  try{\n"
        "    var cid=(CAMPAIGN&&CAMPAIGN.cases[_caseIdx])?CAMPAIGN.cases[_caseIdx].id:'case001';\n"
        "    lsSet('sdvig_progress',{cid:cid,ev:CState.ev,flags:CState.flags,evidence:CState.evidence,step:CState.step});\n"
        "  }catch(e){}\n"
        "}\n"
        "function clearCaseState(){ try{localStorage.removeItem('sdvig_progress');}catch(e){} }\n"
        "function loadCaseState(){\n"
        "  try{\n"
        "    var p=lsGet('sdvig_progress',null); if(!p) return null;\n"
        "    var cid=(CAMPAIGN&&CAMPAIGN.cases[_caseIdx])?CAMPAIGN.cases[_caseIdx].id:'case001';\n"
        "    if(p.cid!==cid) return null;\n"
        "    if(!CASE.events[p.ev]) return null; /* карта из старой версии сценария */\n"
        "    return p;\n"
        "  }catch(e){ return null; }\n"
        "}\n"
    )
    txt = txt.replace(anchor, fns+anchor, 1); n+=1; print("  + save/load/clear CaseState")

# ── 2. отслеживаем текущую карту: CState.ev при каждом setActive ──
old_sa = "  App.currentCard=ev; App.swipeUnlocked=false;\n"
new_sa = ("  App.currentCard=ev; App.swipeUnlocked=false;\n"
          "  if(ev&&ev._id){ CState.ev=ev._id; }\n")
if old_sa in txt and "ev._id" not in txt.split("function setActive")[1][:400]:
    txt = txt.replace(old_sa, new_sa, 1); n+=1; print("  + setActive отмечает текущую карту")

# ── 3. проставляем _id каждому событию при загрузке дела ──
old_loadcase = '    x.send();if(x.status===200)CASE=JSON.parse(x.responseText);\n    localStorage.setItem("sdvig_case",cid);}catch(e){}'
new_loadcase = ('    x.send();if(x.status===200){CASE=JSON.parse(x.responseText);\n'
                '      try{Object.keys(CASE.events).forEach(function(k){CASE.events[k]._id=k;});}catch(_){}}\n'
                '    localStorage.setItem("sdvig_case",cid);}catch(e){}')
if old_loadcase in txt:
    txt = txt.replace(old_loadcase, new_loadcase, 1); n+=1; print("  + каждому событию проставлен _id")

# ── 4. сохраняем после каждого хода (cAdvance + linearAdvance) ──
old_turn = ("    const resolve=(opt.to===\"__resolve__\");\n"
            "    if(!resolve) setActive(cfCards[centerIndex],CASE.events[opt.to]);\n"
            "    cLayout(true);")
new_turn = ("    const resolve=(opt.to===\"__resolve__\");\n"
            "    if(!resolve){ CState.ev=opt.to; setActive(cfCards[centerIndex],CASE.events[opt.to]); saveCaseState(); }\n"
            "    cLayout(true);")
if old_turn in txt:
    txt = txt.replace(old_turn, new_turn, 1); n+=1; print("  + cAdvance сохраняет ход")

old_lturn = ("  var resolve=(nextId==='__resolve__'||!nextId);\n"
             "  if(!resolve) setActive(cfCards[centerIndex],CASE.events[nextId]);\n"
             "  cLayout(true);")
new_lturn = ("  var resolve=(nextId==='__resolve__'||!nextId);\n"
             "  if(!resolve){ CState.ev=nextId; setActive(cfCards[centerIndex],CASE.events[nextId]); saveCaseState(); }\n"
             "  cLayout(true);")
if old_lturn in txt:
    txt = txt.replace(old_lturn, new_lturn, 1); n+=1; print("  + linearAdvance сохраняет ход")

# ── 5. buildBacks: стартуем с сохранённой карты, если есть ──
old_bb = ("  cfCards.forEach(function(c,e){\n"
          "    if(e===centerIndex) setActive(c,CASE.events[CASE.start]); else setBack(c);\n"
          "  });\n"
          "  cLayout(false);")
new_bb = ("  var _saved=loadCaseState();\n"
          "  var _startEv=(_saved&&_saved.ev)?_saved.ev:CASE.start;\n"
          "  if(_saved){ CState.ev=_saved.ev; CState.flags=_saved.flags||{}; CState.evidence=_saved.evidence||[]; CState.step=_saved.step||0;\n"
          "    if(_evCountEl)_evCountEl.textContent=CState.evidence.length; cSetProgress();\n"
          "    if(window.toast) toast('Дело продолжается','Ты вернулся туда, где остановился.','\\ud83d\\udcc2'); }\n"
          "  cfCards.forEach(function(c,e){\n"
          "    if(e===centerIndex) setActive(c,CASE.events[_startEv]); else setBack(c);\n"
          "  });\n"
          "  cLayout(false);")
if old_bb in txt:
    txt = txt.replace(old_bb, new_bb, 1); n+=1; print("  + buildBacks восстанавливает прогресс")

# ── 6. при концовке и смене дела — чистим сохранение ──
old_show = "  try{saveProfile();}catch(_){}\n}"
new_show = "  try{saveProfile();clearCaseState();}catch(_){}\n}"
if old_show in txt:
    txt = txt.replace(old_show, new_show, 1); n+=1; print("  + концовка очищает сохранение")

# restartCarousel должен сбрасывать сохранение (новое прохождение)
old_restart = ("function restartCarousel(){\n"
               "  CState.ev=CASE.start;CState.flags={};CState.evidence=[];CState.step=0;")
new_restart = ("function restartCarousel(){\n"
               "  clearCaseState();\n"
               "  CState.ev=CASE.start;CState.flags={};CState.evidence=[];CState.step=0;")
if old_restart in txt:
    txt = txt.replace(old_restart, new_restart, 1); n+=1; print("  + restart очищает сохранение")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: применено %d патчей" % n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R15 готов — прогресс внутри дела сохраняется"
echo "   git add -A && git commit -m 'R15: save/resume case progress' && git push"
echo "═══════════════════════════════════════════════════════"
