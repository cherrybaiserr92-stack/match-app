#!/usr/bin/env bash
# СДВИГ R28 — новая механика карт-решений + фикс спрайтов + переименование
# ════════════════════════════════════════════════
# ПЕРЕД ЗАПУСКОМ обнови очищенные спрайты в репозитории:
#   cp /sdcard/Download/chars/*.png src/main/resources/static/img/chars/
# (это PNG с убранным фоном)
# ════════════════════════════════════════════════
set -e

echo ""; echo "══ 1/4  Переименование «Самоцветы улик» → «Улики» ══"
python3 - << 'PYEOF'
import os, re
files = ["src/main/resources/static/games/match3.js",
         "src/main/resources/static/games/cube.js",
         "src/main/resources/static/app.js"]
n=0
for path in files:
    if not os.path.exists(path): continue
    with open(path, encoding="utf-8") as f: t=f.read()
    before=t
    t=t.replace("Самоцветы улик","Улики дела").replace("Самоцветы","Улики")
    if t!=before:
        with open(path,"w",encoding="utf-8") as f: f.write(t)
        n+=1; print(f"  + переименовано в {os.path.basename(path)}")
print(f"✓ файлов изменено: {n}")
PYEOF


echo ""; echo "══ 2/4  CSS — фикс спрайтов (стороны, фон) ═════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f: txt = f.read()

# Фикс: Сдвиг и Рекрут — слева, остальные справа. Раньше .left/.right
# зависели от def.side в CHARS — проверим что Сдвиг реально left.
# Здесь же убираем любые остатки фона у спрайта.
if "/* R28 */" not in txt:
    css = r"""
/* ════ R28 — фикс спрайтов + карта-решение ════ */

/* спрайт: гарантируем прозрачность, корректные стороны */
.char-sprite{ background:transparent !important; }
.char-sprite.left{  left:2vw;  right:auto; transform:translate3d(-120%,0,0) !important; }
.char-sprite.right{ right:2vw; left:auto;  transform:translate3d(120%,0,0)  !important; }
.char-sprite.left.show,
.char-sprite.right.show{ transform:translate3d(0,0,0) !important; }

/* ── РЕЖИМ КАРТЫ-РЕШЕНИЯ ── */
/* когда мини-игра пройдена: карта по центру, таймер, тряска, корни исходов */
.stage.decision-mode .cfcard:not(.active){ opacity:.15; filter:blur(2px); }
.cfcard.active.decision{
  animation:cardTension 2.6s ease-in-out infinite;
}
@keyframes cardTension{
  0%,100%{ transform:translate(-50%,-50%) rotate(0deg); }
  25%{ transform:translate(calc(-50% - 1.5px),calc(-50% + 1px)) rotate(-.25deg); }
  50%{ transform:translate(calc(-50% + 1px),calc(-50% - 1.5px)) rotate(.25deg); }
  75%{ transform:translate(calc(-50% - 1px),-50%) rotate(-.15deg); }
}

/* таймер решения */
.decision-timer{
  position:fixed; top:calc(var(--hudh,76px) + 8px); left:50%; transform:translateX(-50%);
  z-index:30; display:flex; flex-direction:column; align-items:center; gap:3px;
  pointer-events:none; opacity:0; transition:opacity .3s;
}
.decision-timer.show{ opacity:1; }
.dt-ring{ width:52px; height:52px; }
.dt-ring svg{ width:100%; height:100%; transform:rotate(-90deg); }
.dt-ring .dt-bg{ fill:none; stroke:rgba(255,255,255,.1); stroke-width:5; }
.dt-ring .dt-fg{ fill:none; stroke:var(--acc,#c8860a); stroke-width:5; stroke-linecap:round;
  transition:stroke-dashoffset .25s linear, stroke .3s; }
.dt-num{ position:absolute; top:0; left:0; width:52px; height:52px; display:flex; align-items:center; justify-content:center;
  font-family:Unbounded,sans-serif; font-weight:900; font-size:18px; color:#fff; }
.decision-timer.urgent .dt-fg{ stroke:#ff5d6c; }
.decision-timer.urgent .dt-num{ color:#ff5d6c; animation:dtPulse .5s ease-in-out infinite; }
@keyframes dtPulse{ 0%,100%{transform:scale(1)} 50%{transform:scale(1.15)} }
.dt-label{ font-size:9px; letter-spacing:.1em; color:#c8a05a; font-family:Unbounded,sans-serif; }

/* корни-исходы по бокам карты */
.outcome-roots{ position:fixed; inset:0; z-index:8; pointer-events:none; opacity:0; transition:opacity .5s; }
.outcome-roots.show{ opacity:1; }
.outcome-roots svg{ width:100%; height:100%; }
.or-path{ fill:none; stroke-width:2.5; stroke-linecap:round; opacity:.5;
  stroke-dasharray:6 8; animation:rootFlow 1.4s linear infinite; }
.or-left{ stroke:#ff7a5d; }   /* левый исход — тёплый */
.or-right{ stroke:#5cd0ff; }  /* правый исход — холодный */
@keyframes rootFlow{ to{ stroke-dashoffset:-14; } }
.or-label{ font-family:Unbounded,sans-serif; font-size:10px; font-weight:700; letter-spacing:.04em; }
.or-label.left{ fill:#ff9d85; }
.or-label.right{ fill:#9fe0ff; }
"""
    txt += "\n/* R28 */\n" + css
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + фикс спрайтов + CSS карты-решения")
else:
    print("  · уже применено")
PYEOF


echo ""; echo "══ 3/4  index.html — слои таймера и корней ═════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/index.html"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0
if 'id="decision-timer"' not in txt:
    layers = '''
<!-- ══ РЕЖИМ РЕШЕНИЯ (R28) ══ -->
<div class="decision-timer" id="decision-timer">
  <div class="dt-ring" style="position:relative">
    <svg viewBox="0 0 52 52"><circle class="dt-bg" cx="26" cy="26" r="22"/><circle class="dt-fg" id="dt-fg" cx="26" cy="26" r="22"/></svg>
    <div class="dt-num" id="dt-num">10</div>
  </div>
  <div class="dt-label">РЕШЕНИЕ</div>
</div>
<div class="outcome-roots" id="outcome-roots">
  <svg viewBox="0 0 100 100" preserveAspectRatio="none" id="roots-svg"></svg>
</div>
'''
    txt = txt.replace('</body>', layers+'</body>', 1)
    n+=1; print("  + слои таймера + корней")
with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d" % n)
PYEOF


echo ""; echo "══ 4/4  app.js — логика карты-решения ══════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# unlockSwipe → запуск режима решения (таймер + тряска + корни)
old = ("function unlockSwipe(){\n"
       "  App.swipeUnlocked=true;\n"
       "  vibrate(20); try{Sound.booster();}catch(_){}\n"
       "  try{removeLockOverlay();}catch(_){}\n"
       "}")
new = ("function unlockSwipe(){\n"
       "  App.swipeUnlocked=true;\n"
       "  vibrate(20); try{Sound.booster();}catch(_){}\n"
       "  try{removeLockOverlay();}catch(_){}\n"
       "  try{ startDecisionMode(); }catch(_){}\n"
       "}\n"
       "\n"
       "var _decTimer=null,_decLeft=0;\n"
       "function startDecisionMode(){\n"
       "  var ev=App.currentCard; if(!ev||ev.linear) return;\n"
       "  /* карта по центру + тряска */\n"
       "  var st=document.getElementById('stage'); if(st)st.classList.add('decision-mode');\n"
       "  if(cActive)cActive.classList.add('decision');\n"
       "  /* корни-исходы по бокам */\n"
       "  showOutcomeRoots(ev);\n"
       "  /* таймер на решение */\n"
       "  _decLeft=15; var dt=document.getElementById('decision-timer');\n"
       "  var fg=document.getElementById('dt-fg'); var num=document.getElementById('dt-num');\n"
       "  var R=22, C=2*Math.PI*R;\n"
       "  if(fg){ fg.style.strokeDasharray=C; fg.style.strokeDashoffset=0; }\n"
       "  if(dt){ dt.classList.add('show'); dt.classList.remove('urgent'); }\n"
       "  if(num) num.textContent=_decLeft;\n"
       "  clearInterval(_decTimer);\n"
       "  var total=15;\n"
       "  _decTimer=setInterval(function(){\n"
       "    _decLeft--;\n"
       "    if(num) num.textContent=Math.max(0,_decLeft);\n"
       "    if(fg){ var frac=_decLeft/total; fg.style.strokeDashoffset=C*(1-frac); }\n"
       "    if(_decLeft<=5 && dt){ dt.classList.add('urgent'); try{Sound.tap&&Sound.tap();}catch(_){} }\n"
       "    if(_decLeft<=0){ clearInterval(_decTimer); onDecisionTimeout(); }\n"
       "  },1000);\n"
       "}\n"
       "function endDecisionMode(){\n"
       "  clearInterval(_decTimer);\n"
       "  var st=document.getElementById('stage'); if(st)st.classList.remove('decision-mode');\n"
       "  if(cActive)cActive.classList.remove('decision');\n"
       "  var dt=document.getElementById('decision-timer'); if(dt)dt.classList.remove('show');\n"
       "  var or=document.getElementById('outcome-roots'); if(or)or.classList.remove('show');\n"
       "}\n"
       "function onDecisionTimeout(){\n"
       "  /* время вышло — Сдвиг подгоняет, но не штрафуем жёстко */\n"
       "  if(window.toast) toast('Время уходит','Сдвиг: «Решай, рекрут. Промедление — тоже выбор».','\\u23f1');\n"
       "  var dt=document.getElementById('decision-timer');\n"
       "  if(dt){ var num=document.getElementById('dt-num'); if(num)num.textContent='!'; }\n"
       "}\n"
       "function showOutcomeRoots(ev){\n"
       "  var or=document.getElementById('outcome-roots'); var svg=document.getElementById('roots-svg');\n"
       "  if(!or||!svg) return;\n"
       "  var lLabel=(ev.left&&ev.left.label)?ev.left.label.replace(/^◄\\s*/,''):'влево';\n"
       "  var rLabel=(ev.right&&ev.right.label)?ev.right.label.replace(/\\s*►$/,''):'вправо';\n"
       "  if(ev.shift){ lLabel=(ev.a&&ev.a.label||'').replace(/^◄\\s*/,''); rLabel=(ev.b&&ev.b.label||'').replace(/\\s*►$/,''); }\n"
       "  /* рисуем ветвящиеся корни от центра к краям */\n"
       "  svg.innerHTML=\n"
       "    '<path class=\"or-path or-left\" d=\"M50 50 Q 30 48 20 40 T 4 30\"/>'+\n"
       "    '<path class=\"or-path or-left\" d=\"M50 50 Q 32 54 22 58 T 6 66\"/>'+\n"
       "    '<path class=\"or-path or-right\" d=\"M50 50 Q 70 48 80 40 T 96 30\"/>'+\n"
       "    '<path class=\"or-path or-right\" d=\"M50 50 Q 68 54 78 58 T 94 66\"/>'+\n"
       "    '<text class=\"or-label left\" x=\"3\" y=\"26\">'+esc(lLabel)+'</text>'+\n"
       "    '<text class=\"or-label right\" x=\"60\" y=\"26\">'+esc(rLabel)+'</text>';\n"
       "  or.classList.add('show');\n"
       "}\n"
       "function esc(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }")
if old in txt:
    txt = txt.replace(old, new, 1); n+=1; print("  + режим карты-решения (таймер+тряска+корни)")

# При свайпе (cAdvance) — завершаем режим решения
old_adv = "function cAdvance(dir,ev,opt){\n  if(cBusy) return; cBusy=true;"
new_adv = "function cAdvance(dir,ev,opt){\n  if(cBusy) return; cBusy=true;\n  try{endDecisionMode();}catch(_){}"
if old_adv in txt and "endDecisionMode" not in txt.split("function cAdvance")[1][:200]:
    txt = txt.replace(old_adv, new_adv, 1); n+=1; print("  + свайп завершает режим решения")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d" % n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R28 готов — карта-решение + фикс спрайтов"
echo "   Не забудь обновить очищенные спрайты:"
echo "   cp /sdcard/Download/chars/*.png src/main/resources/static/img/chars/"
echo ""
echo "   git add -A && git commit -m 'R28: decision-card mechanic + sprite fixes + rename' && git push"
echo "═══════════════════════════════════════════════════════"
