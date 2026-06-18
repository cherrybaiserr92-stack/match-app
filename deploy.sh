#!/usr/bin/env bash
# СДВИГ R16 — контекстный онбординг (3 шага) + SVG-иконки жестов
set -e

echo ""; echo "══ 1/3  index.html — слой онбординга ════════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/index.html"
with open(path, encoding="utf-8") as f: txt = f.read()

if 'id="onb"' in txt:
    print("  · слой онбординга уже есть")
else:
    onb = '''
<!-- ══ ОНБОРДИНГ ══ -->
<div class="onb" id="onb" hidden>
  <div class="onb-spot" id="onb-spot"></div>
  <div class="onb-card" id="onb-card">
    <div class="onb-ico" id="onb-ico"></div>
    <div class="onb-title" id="onb-title"></div>
    <div class="onb-text" id="onb-text"></div>
    <button class="onb-btn" id="onb-btn">Понятно</button>
    <div class="onb-dots" id="onb-dots"></div>
  </div>
</div>

'''
    txt = txt.replace('</body>', onb + '</body>', 1)
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + слой #onb добавлен")
PYEOF


echo ""; echo "══ 2/3  card-design.css — стили + SVG-иконки ════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f: txt = f.read()

if "/* R16 */" in txt:
    print("  · стили онбординга уже есть")
else:
    css = r'''
/* ════════ R16 — ОНБОРДИНГ ════════ */
.onb{ position:fixed; inset:0; z-index:300; display:flex; align-items:flex-end; justify-content:center;
  background:rgba(4,7,12,.74); backdrop-filter:blur(2px); padding:0 18px calc(96px + env(safe-area-inset-bottom)); }
.onb[hidden]{ display:none; }
.onb-card{ position:relative; width:100%; max-width:340px; border-radius:18px; padding:20px 18px 16px;
  background:linear-gradient(160deg,rgba(26,21,15,.98),rgba(11,9,7,.98));
  border:1px solid rgba(200,134,10,.42); box-shadow:0 18px 50px rgba(0,0,0,.6),0 0 30px rgba(200,134,10,.12);
  animation:onbPop .32s cubic-bezier(.2,1.4,.4,1) both; text-align:center; }
@keyframes onbPop{ from{opacity:0;transform:translateY(20px) scale(.94)} to{opacity:1;transform:none} }
.onb-ico{ width:64px; height:64px; margin:0 auto 12px; }
.onb-ico svg{ width:100%; height:100%; display:block; }
.onb-title{ font-family:'Unbounded',sans-serif; font-weight:800; font-size:16px; color:#f3d27a; margin-bottom:7px; }
.onb-text{ font-size:13.5px; line-height:1.5; color:#ded6c4; margin-bottom:16px; }
.onb-btn{ width:100%; padding:13px; border:none; border-radius:12px; cursor:pointer;
  background:linear-gradient(180deg,#ffdf95,var(--acc,#c8860a)); color:#241701;
  font-family:'Unbounded',sans-serif; font-weight:800; font-size:13px; letter-spacing:.04em;
  box-shadow:0 8px 22px rgba(200,134,10,.3); }
.onb-btn:active{ filter:brightness(.92); }
.onb-dots{ display:flex; gap:6px; justify-content:center; margin-top:12px; }
.onb-dots i{ width:6px; height:6px; border-radius:50%; background:rgba(255,255,255,.2); transition:background .2s,width .2s; }
.onb-dots i.on{ width:18px; border-radius:3px; background:var(--acc,#c8860a); }

/* подсветка-«дырка» вокруг элемента (по желанию через onb-spot) */
.onb-spot{ position:absolute; border-radius:16px; pointer-events:none; display:none;
  box-shadow:0 0 0 9999px rgba(4,7,12,.74), 0 0 0 2px rgba(200,134,10,.6), 0 0 26px rgba(200,134,10,.4);
  animation:onbGlow 1.6s ease-in-out infinite; }
.onb-spot.show{ display:block; }
@keyframes onbGlow{ 0%,100%{box-shadow:0 0 0 9999px rgba(4,7,12,.74),0 0 0 2px rgba(200,134,10,.5),0 0 18px rgba(200,134,10,.3)}
  50%{box-shadow:0 0 0 9999px rgba(4,7,12,.74),0 0 0 2px rgba(200,134,10,.85),0 0 30px rgba(200,134,10,.55)} }

/* анимация качающейся стрелки в иконке свайпа */
@keyframes onbSwayL{ 0%,100%{transform:translateX(0)} 50%{transform:translateX(-7px)} }
@keyframes onbSwayR{ 0%,100%{transform:translateX(0)} 50%{transform:translateX(7px)} }
.onb-ico .sway-l{ animation:onbSwayL 1.3s ease-in-out infinite; }
.onb-ico .sway-r{ animation:onbSwayR 1.3s ease-in-out infinite; }
.onb-ico .pulse{ animation:onbGlowPulse 1.4s ease-in-out infinite; transform-origin:center; }
@keyframes onbGlowPulse{ 0%,100%{opacity:.55} 50%{opacity:1} }
'''
    txt += "\n/* R16 */\n" + css
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + стили онбординга + анимации иконок")
PYEOF


echo ""; echo "══ 3/3  app.js — логика 3-шагового онбординга ═══════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n = 0

# ── SVG-иконки жестов (качественные, в стиле системы) ──
if "var ONB_ICONS" not in txt:
    icons = r'''
/* ═══ ОНБОРДИНГ (R16) ═══ */
var ONB_ICONS={
  swipe:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
    +'<rect x="22" y="10" width="20" height="34" rx="5" fill="rgba(200,134,10,.1)"/>'
    +'<circle cx="32" cy="27" r="4.5" fill="#f3d27a" stroke="none"/>'
    +'<g class="sway-l"><path d="M16 27l-7 0M12 23l-4 4 4 4"/></g>'
    +'<g class="sway-r"><path d="M48 27l7 0M52 23l4 4-4 4"/></g></svg>',
  gems:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.2" stroke-linejoin="round">'
    +'<g class="pulse"><path d="M32 8l9 9-9 9-9-9z" fill="rgba(92,208,255,.25)"/>'
    +'<path d="M16 30l7 7-7 7-7-7z" fill="rgba(255,111,134,.22)"/>'
    +'<path d="M48 30l7 7-7 7-7-7z" fill="rgba(200,134,10,.28)"/>'
    +'<path d="M32 40l9 9-9 9-9-9z" fill="rgba(120,220,150,.22)"/></g></svg>',
  shift:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
    +'<line x1="32" y1="8" x2="32" y2="56" stroke="rgba(243,210,122,.5)" stroke-dasharray="3 4"/>'
    +'<g class="sway-l" stroke="#5cd0ff"><path d="M24 20l-9 9 9 9"/></g>'
    +'<g class="sway-r" stroke="#ff6f86"><path d="M40 20l9 9-9 9"/></g></svg>',
  energy:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">'
    +'<path d="M20 24h20v10a10 10 0 0 1-20 0z" fill="rgba(200,134,10,.15)"/>'
    +'<path d="M40 26h4a4 4 0 0 1 0 8h-4"/>'
    +'<g class="pulse" stroke="#f3d27a"><path d="M24 14c-1 2 1 3 0 5M30 13c-1 2 1 3 0 5M36 14c-1 2 1 3 0 5"/></g></svg>'
};
'''
    # вставим перед initCarousel
    anchor = "function initCarousel(){"
    txt = txt.replace(anchor, icons+"\n"+anchor, 1); n+=1; print("  + SVG-иконки жестов")

# ── движок онбординга ──
if "function onbShow" not in txt:
    engine = r'''
var ONB_STEPS=[
  {key:'gems',  icon:'gems',  title:'Сначала — улики',
    text:'Каждая карта дела заперта. Нажми «Найти улики» и пройди мини-игру «Самоцветы», чтобы разблокировать выбор.'},
  {key:'swipe', icon:'swipe', title:'Свайп решает',
    text:'После мини-игры тяни карту влево или вправо — это твой выбор в расследовании. Каждый свайп тратит ☕ кофе (энергию).'},
  {key:'shift', icon:'shift', title:'Момент СДВИГА',
    text:'Иногда реальность раскалывается надвое. Выбранная версия станет правдой дела — и определит финал. Думай как детектив.'}
];
function onbDone(){ try{ if(App.profile){ App.profile.onboarded=true; saveProfile(); } }catch(_){} }
function onbSeen(){ try{ return !!(App.profile&&App.profile.onboarded); }catch(_){ return false; } }
function onbShow(i){
  var el=document.getElementById('onb'); if(!el) return;
  var s=ONB_STEPS[i]; if(!s){ el.setAttribute('hidden',''); onbDone(); return; }
  el.removeAttribute('hidden');
  document.getElementById('onb-ico').innerHTML=ONB_ICONS[s.icon]||'';
  document.getElementById('onb-title').textContent=s.title;
  document.getElementById('onb-text').textContent=s.text;
  var dots=document.getElementById('onb-dots');
  if(dots){ dots.innerHTML=ONB_STEPS.map(function(_,j){return '<i class="'+(j===i?'on':'')+'"></i>';}).join(''); }
  var btn=document.getElementById('onb-btn');
  btn.textContent=(i>=ONB_STEPS.length-1)?'Начать дело':'Дальше';
  btn.onclick=function(){ try{Sound.tap();}catch(_){} onbShow(i+1); };
}
function onbMaybeStart(){
  if(onbSeen()) return;
  /* показываем на первой НЕ-линейной карте (когда реально нужен match-3+свайп) */
  setTimeout(function(){ if(!onbSeen()) onbShow(0); }, 400);
}
'''
    anchor = "function initCarousel(){"
    txt = txt.replace(anchor, engine+"\n"+anchor, 1); n+=1; print("  + движок онбординга (3 шага)")

# ── профиль: флаг onboarded ──
old_prof = "  lastEnergyTs:0, rapport:0"
new_prof = "  lastEnergyTs:0, rapport:0, onboarded:false"
if old_prof in txt and "onboarded" not in txt.split("DEFAULT_PROFILE")[1][:400]:
    txt = txt.replace(old_prof, new_prof, 1); n+=1; print("  + профиль: onboarded")

# ── запуск онбординга при первом показе НЕ-линейной карты ──
# в addLockOverlay (там точно match-3 гейт первой игровой карты)
old_lock_end = ("  lock.querySelector('#play-gems-ring').addEventListener('click',function(){\n"
                "    try{Sound.tap();}catch(_){} openHintGame(App.currentCard||{});\n"
                "  });\n"
                "}")
new_lock_end = ("  lock.querySelector('#play-gems-ring').addEventListener('click',function(){\n"
                "    try{Sound.tap();}catch(_){} openHintGame(App.currentCard||{});\n"
                "  });\n"
                "  try{ onbMaybeStart(); }catch(_){}\n"
                "}")
if old_lock_end in txt:
    txt = txt.replace(old_lock_end, new_lock_end, 1); n+=1; print("  + онбординг стартует на первой игровой карте")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: применено %d" % n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R16 готов — контекстный онбординг (3 шага)"
echo "   git add -A && git commit -m 'R16: onboarding tutorial' && git push"
echo "═══════════════════════════════════════════════════════"
