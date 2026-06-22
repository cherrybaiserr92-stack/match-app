#!/usr/bin/env bash
# СДВИГ R60 — пролог при первом запуске (4 слайда → выбор персонажа → игра)
set -e
echo "══ штамп → R60 ══"
sed -i "s/SDVIG_BUILD='R59'/SDVIG_BUILD='R60'/" src/main/resources/static/app.js
sed -i 's/>R59</>R60</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  HTML пролога перед выбором персонажа ═══════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
prologue = r'''  <!-- ПРОЛОГ (первый запуск) -->
  <div id="prologue" class="prologue" style="display:none">
    <button class="pr-skip" onclick="window.prologueNext&&window.prologueNext(true)">Пропустить ›</button>
    <div class="pr-slides" id="pr-slides">
      <div class="pr-slide active" data-s="0">
        <div class="pr-ico"><img src="/img/icons/ico-detective.png" alt=""></div>
        <div class="pr-eyebrow">Добро пожаловать в СДВИГ</div>
        <div class="pr-title">Ты — <em>детектив</em></div>
        <div class="pr-body">Расследуй дела о загадочных исчезновениях. Осматривай места преступлений, ищи улики, допрашивай свидетелей и вычисляй правду.</div>
      </div>
      <div class="pr-slide" data-s="1">
        <div class="pr-ico"><img src="/img/icons/ico-hat.png" alt=""></div>
        <div class="pr-eyebrow">Твой наставник</div>
        <div class="pr-title"><em>Сдвиг</em></div>
        <div class="pr-body">Опытный детектив ведёт тебя через расследование. Слушай его — или иди своим путём. От этого зависят ваши отношения.</div>
      </div>
      <div class="pr-slide" data-s="2">
        <div class="pr-ico"><img src="/img/icons/ico-cards.png" alt=""></div>
        <div class="pr-eyebrow">Управление</div>
        <div class="pr-title">Свайп <em>решает</em></div>
        <div class="pr-body">Принимай решения свайпом карточек. Находи улики в мини-играх. Выбирай версии — каждый выбор меняет ход дела.</div>
      </div>
      <div class="pr-slide" data-s="3">
        <div class="pr-ico"><img src="/img/icons/ico-scales.png" alt=""></div>
        <div class="pr-eyebrow">Две шкалы</div>
        <div class="pr-title">Истина — в <em>балансе</em></div>
        <div class="pr-body">Отношения со Сдвигом и твоя детективность растут от решений. Дави — растёшь как сыщик. Будь человечнее — крепнет доверие.</div>
      </div>
    </div>
    <div class="pr-controls">
      <div class="pr-dots" id="pr-dots"><i class="on"></i><i></i><i></i><i></i></div>
      <button class="pr-next" id="pr-next" onclick="window.prologueNext&&window.prologueNext()">Дальше</button>
    </div>
  </div>
'''
# Вставляем пролог ПЕРЕД gender-select
anchor='  <div id="gender-select" class="gender-modal"'
if 'id="prologue"' not in txt:
    txt=txt.replace(anchor, prologue+'\n'+anchor, 1); n+=1; print("  + HTML пролога вставлен")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/3  CSS пролога ═════════════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".prologue{" not in txt:
    txt+='''
/* ════ ПРОЛОГ ════ */
.prologue{position:fixed;inset:0;z-index:9500;background:#070a10;display:flex;flex-direction:column;
  align-items:center;justify-content:center;overflow:hidden;}
.prologue::before{content:'';position:absolute;inset:0;
  background:repeating-linear-gradient(105deg,transparent,transparent 3px,rgba(180,200,220,.05) 3px,rgba(180,200,220,.05) 4px);
  animation:prRain .5s linear infinite;pointer-events:none;}
@keyframes prRain{0%{background-position:0 0}100%{background-position:8px 40px}}
.pr-skip{position:absolute;top:20px;right:20px;z-index:10;background:rgba(0,0,0,.35);
  border:1px solid rgba(255,255,255,.15);color:#9aa3b2;font-size:12px;padding:8px 14px;
  border-radius:20px;cursor:pointer;}
.pr-slides{flex:1;width:100%;max-width:420px;position:relative;display:flex;align-items:center;justify-content:center;}
.pr-slide{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;
  padding:40px 32px;text-align:center;opacity:0;pointer-events:none;transition:opacity .7s ease;}
.pr-slide.active{opacity:1;pointer-events:auto;}
.pr-ico{margin-bottom:26px;opacity:0;animation:prUp .8s ease .2s forwards;}
.pr-ico img{width:130px;height:130px;object-fit:contain;filter:drop-shadow(0 8px 30px rgba(200,134,10,.4));}
.pr-eyebrow{font-family:Unbounded,sans-serif;font-size:11px;letter-spacing:.3em;text-transform:uppercase;
  color:#c8860a;margin-bottom:16px;opacity:0;animation:prUp .8s ease .4s forwards;}
.pr-title{font-family:'Playfair Display',Georgia,serif;font-size:32px;line-height:1.15;font-weight:700;
  color:#fff;margin-bottom:18px;opacity:0;animation:prUp .8s ease .55s forwards;}
.pr-title em{color:#ffcf6b;font-style:italic;}
.pr-body{font-size:15px;line-height:1.65;color:#b8b0a0;max-width:330px;opacity:0;animation:prUp .8s ease .7s forwards;}
@keyframes prUp{0%{opacity:0;transform:translateY(16px)}100%{opacity:1;transform:translateY(0)}}
.pr-controls{width:100%;max-width:360px;padding:24px 28px 36px;display:flex;flex-direction:column;align-items:center;gap:18px;z-index:5;}
.pr-dots{display:flex;gap:8px;}
.pr-dots i{width:7px;height:7px;border-radius:50%;background:rgba(255,255,255,.2);transition:all .3s;}
.pr-dots i.on{background:#ffcf6b;width:22px;border-radius:4px;}
.pr-next{width:100%;padding:16px;border:none;border-radius:14px;cursor:pointer;
  font-family:Unbounded,sans-serif;font-weight:800;font-size:15px;
  background:linear-gradient(180deg,#ffe09a,#c8860a);color:#241701;transition:transform .15s;}
.pr-next:active{transform:scale(.97);}

@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital@1&display=swap');
'''
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS пролога")
PYEOF


echo ""; echo "══ 3/3  логика пролога (слайды → выбор) ════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# maybeShowGenderSelect: сначала пролог (если не пройден), потом выбор
old='''function maybeShowGenderSelect(){
  try{
    applyRecruitGender();
    if(App.profile && !App.profile.genderChosen){
      var m=document.getElementById('gender-select');
      if(m){ m.style.display='flex'; initGenderSelect(); }
    }
  }catch(_){}
}'''
new='''function maybeShowGenderSelect(){
  try{
    applyRecruitGender();
    if(App.profile && !App.profile.genderChosen){
      // сначала пролог, потом выбор персонажа
      if(!App.profile.prologueSeen){ showPrologue(); }
      else { var m=document.getElementById('gender-select'); if(m){ m.style.display='flex'; initGenderSelect(); } }
    }
  }catch(_){}
}
var _prSlide=0, _prTotal=4;
function showPrologue(){
  var pr=document.getElementById('prologue'); if(!pr) return;
  _prSlide=0; pr.style.display='flex'; _prShow(0);
}
function _prShow(i){
  document.querySelectorAll('.pr-slide').forEach(function(s){ s.classList.toggle('active', +s.getAttribute('data-s')===i); });
  document.querySelectorAll('#pr-dots i').forEach(function(d,di){ d.classList.toggle('on', di===i); });
  var nb=document.getElementById('pr-next'); if(nb) nb.textContent=(i===_prTotal-1)?'Выбрать персонажа':'Дальше';
  // перезапуск анимаций
  var sl=document.querySelector('.pr-slide[data-s="'+i+'"]');
  if(sl) sl.querySelectorAll('.pr-ico,.pr-eyebrow,.pr-title,.pr-body').forEach(function(el){
    el.style.animation='none'; void el.offsetWidth; el.style.animation='';
  });
}
window.prologueNext=function(skip){
  if(skip){ _finishPrologue(); return; }
  _prSlide++;
  if(_prSlide<_prTotal){ _prShow(_prSlide); }
  else { _finishPrologue(); }
};
function _finishPrologue(){
  var pr=document.getElementById('prologue'); if(pr) pr.style.display='none';
  if(App.profile){ App.profile.prologueSeen=true; saveProfile(); }
  var m=document.getElementById('gender-select'); if(m){ m.style.display='flex'; initGenderSelect(); }
}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + логика пролога (слайды → выбор персонажа)")

# prologueSeen в профиль
txt=txt.replace("gender:'m', genderChosen:false, onboarded:false",
                "gender:'m', genderChosen:false, prologueSeen:false, onboarded:false")
n+=1; print("  + prologueSeen в профиль")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R60 — пролог при первом запуске"
echo "   git add -A && git commit -m 'R60: intro prologue before character select' && git push"
echo "═══════════════════════════════════════════════════════"
