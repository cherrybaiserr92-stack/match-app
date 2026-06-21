#!/usr/bin/env bash
# СДВИГ R49 — визуальные шкалы внизу (отношения + детективность) вместо инструментов
set -e
echo "══ штамп → R49 ══"
sed -i "s/SDVIG_BUILD='R4[0-9]'/SDVIG_BUILD='R49'/" src/main/resources/static/app.js
sed -i 's/>R4[0-9]</>R49</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  index.html — шкалы вместо tools-bar ════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

old='''      <div class="tools-bar" id="tools-bar">
        <div class="ev-chip" id="ev-chip">
          <span class="ev-dot"></span>
          <span>Улики</span>
          <b id="ev-count">0</b>
        </div>
        <button class="tool-btn" data-tool="magnify" title="Лупа — подсветит важную улику">
          <span class="tool-ico" data-tico="magnify"></span>
          <span class="tool-badge" id="tool-magnify-n">2</span>
        </button>
        <button class="tool-btn" data-tool="file" title="Досье — пропустить мини-игру">
          <span class="tool-ico" data-tico="file"></span>
          <span class="tool-badge" id="tool-file-n">1</span>
        </button>
        <button class="tool-btn" data-tool="hourglass" title="Песочные часы — +20 энергии">
          <span class="tool-ico" data-tico="hourglass"></span>
          <span class="tool-badge" id="tool-hourglass-n">1</span>
        </button>
        <button class="tool-btn tool-shop" data-tool="shop" title="Купить инструменты">
          <span class="tool-ico" data-tico="plus"></span>
        </button>
      </div>'''

new='''      <div class="scales-bar" id="scales-bar">
        <div class="gscale rapport">
          <div class="gscale-pop" id="rap-pop"></div>
          <div class="gscale-top">
            <span class="gscale-name"><span class="gscale-ico">🎩</span>Сдвиг</span>
            <span class="gscale-num" id="rap-num">50</span>
          </div>
          <div class="gscale-track"><div class="gscale-fill" id="rap-fill" style="width:50%"></div></div>
          <div class="gscale-stat" id="rap-stat">Напарник</div>
        </div>
        <div class="gscale detective">
          <div class="gscale-pop" id="det-pop"></div>
          <div class="gscale-top">
            <span class="gscale-name"><span class="gscale-ico">🔍</span>Детектив</span>
            <span class="gscale-num" id="det-num">30</span>
          </div>
          <div class="gscale-track"><div class="gscale-fill" id="det-fill" style="width:30%"></div></div>
          <div class="gscale-stat" id="det-stat">Стажёр</div>
        </div>
        <button class="tools-mini" data-tool="shop" title="Инструменты">
          <span class="ev-chip-mini"><span class="ev-dot"></span><b id="ev-count">0</b></span>
        </button>
      </div>'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + tools-bar заменён на scales-bar (2 шкалы)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/3  CSS — стиль шкал ═══════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".scales-bar" not in txt:
    css='''
/* ── ШКАЛЫ ПРОГРЕССА (отношения + детективность) ── */
.scales-bar{display:flex;gap:10px;align-items:stretch;padding:10px 12px;}
.gscale{flex:1;position:relative;background:rgba(16,20,28,.85);border:1px solid rgba(255,255,255,.08);
  border-radius:14px;padding:9px 12px;backdrop-filter:blur(8px);}
.gscale-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;}
.gscale-name{display:flex;align-items:center;gap:5px;font-family:Unbounded,sans-serif;font-weight:700;
  font-size:10px;letter-spacing:.02em;text-transform:uppercase;}
.gscale-ico{font-size:13px;}
.gscale-num{font-family:Unbounded,sans-serif;font-weight:900;font-size:15px;}
.gscale-track{height:6px;border-radius:4px;background:rgba(255,255,255,.08);overflow:hidden;}
.gscale-fill{height:100%;border-radius:4px;transition:width .6s cubic-bezier(.3,1,.4,1);position:relative;}
.gscale-fill::after{content:'';position:absolute;inset:0;
  background:linear-gradient(90deg,transparent,rgba(255,255,255,.35),transparent);
  animation:gscaleShine 2.4s ease-in-out infinite;}
@keyframes gscaleShine{0%{transform:translateX(-100%)}60%,100%{transform:translateX(100%)}}
.gscale-stat{font-size:9px;margin-top:4px;opacity:.65;font-style:italic;}
.gscale.rapport .gscale-name,.gscale.rapport .gscale-num{color:#ff8fb0;}
.gscale.rapport .gscale-fill{background:linear-gradient(90deg,#c44569,#ff8fb0);}
.gscale.detective .gscale-name,.gscale.detective .gscale-num{color:#46d89b;}
.gscale.detective .gscale-fill{background:linear-gradient(90deg,#2a9d6f,#46d89b);}
.gscale-pop{position:absolute;top:-6px;right:10px;font-family:Unbounded,sans-serif;font-weight:800;
  font-size:13px;opacity:0;pointer-events:none;z-index:5;}
.gscale-pop.show{animation:gscalePop 1.2s ease forwards;}
@keyframes gscalePop{0%{opacity:0;transform:translateY(0)}20%{opacity:1}100%{opacity:0;transform:translateY(-20px)}}
.tools-mini{flex:0 0 auto;width:46px;border:1px solid rgba(200,134,10,.3);border-radius:14px;
  background:rgba(200,134,10,.12);display:flex;align-items:center;justify-content:center;cursor:pointer;}
.ev-chip-mini{display:flex;align-items:center;gap:3px;color:#ffcf6b;font-weight:800;font-size:13px;
  font-family:Unbounded,sans-serif;}
.ev-chip-mini .ev-dot{width:6px;height:6px;border-radius:50%;background:#46d89b;}
'''
    txt+=css
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS шкал добавлен")
else:
    print("  · CSS шкал уже есть")
PYEOF


echo ""; echo "══ 3/3  app.js — updateScaleBars + статусы 0-100 ═══"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# updateScaleBars — обновляет обе шкалы
if "function updateScaleBars" not in txt:
    anchor="function rapportTitle(){"
    fn='''function updateScaleBars(){
  var p=App.profile; if(!p) return;
  var rap=clamp(p.rapport||0,0,100), det=clamp(p.skill||30,0,100);
  var rn=document.getElementById('rap-num'), rf=document.getElementById('rap-fill'), rs=document.getElementById('rap-stat');
  var dn=document.getElementById('det-num'), df=document.getElementById('det-fill'), ds=document.getElementById('det-stat');
  if(rn)rn.textContent=rap; if(rf)rf.style.width=rap+'%'; if(rs)rs.textContent=rapTitle(rap);
  if(dn)dn.textContent=det; if(df)df.style.width=det+'%'; if(ds)ds.textContent=detTitle(det);
}
function rapTitle(v){
  if(v>=95)return'Брат'; if(v>=80)return'Свой'; if(v>=60)return'Доверяет';
  if(v>=40)return'Напарник'; if(v>=20)return'Терпит'; return'Чужак';
}
function detTitle(v){
  if(v>=95)return'Легенда'; if(v>=80)return'Профи'; if(v>=60)return'Детектив';
  if(v>=40)return'Сыщик'; if(v>=20)return'Стажёр'; return'Новичок';
}
function scalePop(which,delta){
  var el=document.getElementById(which+'-pop'); if(!el)return;
  el.textContent=(delta>0?'+':'')+delta;
  el.style.color=delta>0?(which==='rap'?'#ff8fb0':'#46d89b'):'#ff5d6c';
  el.classList.remove('show'); void el.offsetWidth; el.classList.add('show');
}
'''
    txt=txt.replace(anchor, fn+anchor, 1); n+=1; print("  + updateScaleBars + статусы 0-100")

# addSkill и addRapport вызывают pop-анимацию
txt=txt.replace(
  "function addSkill(n){\n  var p=App.profile; p.skill=clamp((p.skill||30)+n,0,100); saveProfile();\n  try{ updateScaleBars&&updateScaleBars(); }catch(_){}\n}",
  "function addSkill(n){\n  var p=App.profile; p.skill=clamp((p.skill||30)+n,0,100); saveProfile();\n  try{ updateScaleBars&&updateScaleBars(); scalePop&&scalePop('det',n); }catch(_){}\n}")
txt=txt.replace(
  "  p.rapport=clamp((p.rapport||0)+n,0,100); saveProfile();\n  try{ updateScaleBars&&updateScaleBars(); }catch(_){}",
  "  p.rapport=clamp((p.rapport||0)+n,0,100); saveProfile();\n  try{ updateScaleBars&&updateScaleBars(); scalePop&&scalePop('rap',n); }catch(_){}")
n+=1; print("  + pop-анимация при изменении шкал")

# вызываем updateScaleBars при входе в дело (показать актуальные значения)
if "updateScaleBars();" not in txt.split("function enterMain")[1][:500] if "function enterMain" in txt else False:
    pass
# просто добавим вызов в enterMain
import re
m=re.search(r'(function enterMain\([^)]*\)\s*\{)', txt)
if m and 'updateScaleBars' not in txt[m.end():m.end()+300]:
    txt=txt[:m.end()]+'\n  try{ updateScaleBars(); }catch(_){}'+txt[m.end():]
    n+=1; print("  + updateScaleBars при входе в дело")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R49 — визуальные шкалы внизу (отношения + детектив)"
echo "   git add -A && git commit -m 'R49: visual stat scales (rapport + detective) replace tools' && git push"
echo "═══════════════════════════════════════════════════════"
