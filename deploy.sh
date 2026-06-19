#!/usr/bin/env bash
# СДВИГ R26 — КРИТФИКС: вызов showChar/showSpeech в setActive (спрайты не показывались вообще)
set -e
echo ""; echo "══ app.js — добавляем недостающий вызов showChar ════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# Текущий setActive НЕ содержит showChar. Вставляем вызов после App.currentCard=ev
old = ('  App.currentCard=ev; App.swipeUnlocked=false;\n'
       '  if(ev&&ev._id){ CState.ev=ev._id; }\n')
new = ('  App.currentCard=ev; App.swipeUnlocked=false;\n'
       '  if(ev&&ev._id){ CState.ev=ev._id; }\n'
       '  try{ showChar(ev.speaker||null); showSpeech(ev.speaker?ev.dialogue:null); }catch(_){}\n')
if old in txt and "showChar(ev.speaker" not in txt:
    txt = txt.replace(old, new, 1); n+=1; print("  ✓ showChar/showSpeech вызов добавлен в setActive")
elif "showChar(ev.speaker" in txt:
    print("  · вызов уже есть")
else:
    print("  ✗ якорь не найден — проверь setActive вручную")

# Подстрахуемся: showSpeech должен существовать (от R25). Если нет — добавим заглушку рядом с hideChar.
if "function showSpeech" not in txt:
    anchor = "function hideChar(){"
    sp = ("var _speechEl=null;\n"
          "function showSpeech(text){\n"
          "  var host=document.getElementById('main-screen')||document.body;\n"
          "  if(!_speechEl){ _speechEl=document.createElement('div'); _speechEl.className='char-speech'; host.appendChild(_speechEl); }\n"
          "  if(!text){ _speechEl.classList.remove('show'); return; }\n"
          "  _speechEl.innerHTML='<span class=\"cs-quote\">'+text.replace(/^[^:]*:\\s*/,'').replace(/[«»\"]/g,'')+'</span>';\n"
          "  requestAnimationFrame(function(){requestAnimationFrame(function(){ _speechEl.classList.add('show'); });});\n"
          "}\n")
    txt = txt.replace(anchor, sp+anchor, 1); n+=1; print("  + showSpeech добавлен (его не было)")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ применено %d" % n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R26 — критфикс выезжающих персонажей"
echo "   git add -A && git commit -m 'R26: critical fix - actually call showChar in setActive' && git push"
echo "═══════════════════════════════════════════════════════"
