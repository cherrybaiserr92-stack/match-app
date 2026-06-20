#!/usr/bin/env bash
# СДВИГ R41 — КРИТФИКС: улика перекрывала карту решения (z-index конфликт + порядок)
set -e

echo ""; echo "══ 1/2  app.js — карта решения ПОСЛЕ закрытия улики ══"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# showClueReveal принимает onClose-колбэк
old_sig="function showClueReveal(clue){"
new_sig="function showClueReveal(clue, onClose){"
if old_sig in txt:
    txt=txt.replace(old_sig,new_sig,1); n+=1; print("  + showClueReveal принимает onClose")

# при закрытии (тап) — вызвать onClose
old_tap=("  ov.onclick=function(){ ov.classList.add('tofile');\n"
         "    setTimeout(function(){ if(ov.parentNode)ov.parentNode.removeChild(ov); },600); };")
new_tap=("  var _closed=false;\n"
         "  function _close(){ if(_closed)return; _closed=true; ov.classList.add('tofile');\n"
         "    setTimeout(function(){ if(ov.parentNode)ov.parentNode.removeChild(ov); if(onClose)onClose(); },600); }\n"
         "  ov.onclick=_close;")
if old_tap in txt:
    txt=txt.replace(old_tap,new_tap,1); n+=1; print("  + тап по улике вызывает onClose")

# авто-закрытие тоже через _close
old_auto=("  setTimeout(function(){ if(ov.parentNode){ ov.classList.add('tofile');\n"
          "    setTimeout(function(){ if(ov.parentNode)ov.parentNode.removeChild(ov); },600);} }, 3400);")
new_auto="  setTimeout(_close, 3000);"
if old_auto in txt:
    txt=txt.replace(old_auto,new_auto,1); n+=1; print("  + авто-закрытие улики через onClose (3с)")

# grantClue передаёт onClose дальше
old_grant="  try{ showClueReveal(clue); }catch(_){}"
new_grant="  try{ showClueReveal(clue, window._afterClue||null); window._afterClue=null; }catch(_){}"
if old_grant in txt:
    txt=txt.replace(old_grant,new_grant,1); n+=1; print("  + grantClue прокидывает _afterClue")

# unlockSwipe: enterDecision вызываем ПОСЛЕ закрытия улики, не сразу
old_unlock=("  try{ if(window._pendingClue){ grantClue(window._pendingClue); window._pendingClue=null; } }catch(_){}\n"
            "  if(window.Feed){ try{ Feed.enterDecision(); }catch(_){} }\n"
            "  else { try{ startDecisionMode(); }catch(_){} }")
new_unlock=("  var _goDecision=function(){\n"
            "    if(window.Feed){ try{ Feed.enterDecision(); }catch(_){} }\n"
            "    else { try{ startDecisionMode(); }catch(_){} }\n"
            "  };\n"
            "  if(window._pendingClue){\n"
            "    // показываем улику, а карту решения — ТОЛЬКО после её закрытия\n"
            "    window._afterClue=_goDecision;\n"
            "    try{ grantClue(window._pendingClue); }catch(_){ _goDecision(); }\n"
            "    window._pendingClue=null;\n"
            "  } else {\n"
            "    _goDecision();\n"
            "  }")
if old_unlock in txt:
    txt=txt.replace(old_unlock,new_unlock,1); n+=1; print("  + карта решения ПОСЛЕ закрытия улики (нет перекрытия)")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/2  clue-reveal z-index выше + не застревает ═════"
python3 - << 'PYEOF'
path="src/main/resources/static/card-design.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# поднимаем z-index оверлея улики чтобы точно был сверху (над всем)
old=".clue-reveal{position:fixed;inset:0;z-index:80;"
new=".clue-reveal{position:fixed;inset:0;z-index:200;"
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + clue-reveal z-index 200 (над картой решения)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ card-design.css: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R41 — улика больше не блокирует карту решения"
echo "   git add -A && git commit -m 'R41: fix clue overlay blocking decision card' && git push"
echo "═══════════════════════════════════════════════════════"
