#!/usr/bin/env bash
# СДВИГ R55 — выбор пола Рекрута (М/Ж) + сброс прогресса + чистка вкладки Агент
set -e
echo "══ штамп → R55 ══"
sed -i "s/SDVIG_BUILD='R54'/SDVIG_BUILD='R55'/" src/main/resources/static/app.js
sed -i 's/>R54</>R55</' src/main/resources/static/index.html

echo ""; echo "══ 1/5  профиль — поле gender + recruit-аватар по полу"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# gender в профиль
txt=txt.replace("lastEnergyTs:0, rapport:50, skill:30, onboarded:false",
                "lastEnergyTs:0, rapport:50, skill:30, gender:'m', onboarded:false")
n+=1; print("  + gender в профиль")

# recruit-аватар зависит от пола: функция и динамическая подмена
if "function recruitSrc" not in txt:
    anchor="  recruit:{src:'/img/chars/char-recruit.png', side:'left'},"
    txt=txt.replace(anchor, anchor+"\n  'recruit-f':{src:'/img/chars/char-recruit-f.png', side:'left'},")
    # функция выбора спрайта рекрута
    fn='''function recruitSrc(){
  try{ return (App.profile&&App.profile.gender==='f')?'/img/chars/char-recruit-f.png':'/img/chars/char-recruit.png'; }
  catch(_){ return '/img/chars/char-recruit.png'; }
}
function applyRecruitGender(){
  try{ if(window.CHARS&&CHARS.recruit){ CHARS.recruit.src=recruitSrc(); window.CHAR_VER=String(Date.now()); } }catch(_){}
}
'''
    txt=txt.replace("function recruitSrc",fn+"function recruitSrc",1) if "function recruitSrc" in txt else txt
    # вставляем функции перед showChar
    txt=txt.replace("let _charEl=null,_charId=null;", fn+"let _charEl=null,_charId=null;",1)
    n+=1; print("  + recruitSrc/applyRecruitGender (аватар по полу)")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/5  экран выбора персонажа (первый запуск) ═════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Добавляем модалку выбора персонажа перед </body>
if 'id="gender-select"' not in txt:
    modal='''
  <!-- Выбор персонажа (первый запуск) -->
  <div id="gender-select" class="gender-modal" style="display:none">
    <div class="gm-inner">
      <div class="gm-title">КТО ТЫ, ДЕТЕКТИВ?</div>
      <div class="gm-sub">Выбери своего Рекрута. Это решение останется с тобой до конца расследования.</div>
      <div class="gm-options">
        <button class="gm-card" data-gender="m">
          <div class="gm-portrait"><img src="/img/chars/char-recruit.png" alt="М"></div>
          <div class="gm-label">Детектив</div>
        </button>
        <button class="gm-card" data-gender="f">
          <div class="gm-portrait"><img src="/img/chars/char-recruit-f.png" alt="Ж"></div>
          <div class="gm-label">Детектив</div>
        </button>
      </div>
      <button class="gm-confirm" id="gm-confirm" disabled>Начать расследование</button>
    </div>
  </div>
</body>'''
    txt=txt.replace("</body>",modal,1); n+=1; print("  + модалка выбора персонажа")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 3/5  CSS экрана выбора ══════════════════════════"
python3 - << 'PYEOF'
import os
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".gender-modal" not in txt:
    css='''
/* ── Выбор персонажа ── */
.gender-modal{position:fixed;inset:0;z-index:9000;background:rgba(6,8,13,.97);
  display:flex;align-items:center;justify-content:center;padding:24px;backdrop-filter:blur(10px);}
.gm-inner{max-width:440px;width:100%;text-align:center;}
.gm-title{font-family:Unbounded,sans-serif;font-weight:900;font-size:24px;color:#ffcf6b;letter-spacing:.02em;margin-bottom:8px;}
.gm-sub{font-size:13px;line-height:1.5;color:#9aa3b2;margin-bottom:26px;font-style:italic;}
.gm-options{display:flex;gap:14px;margin-bottom:24px;}
.gm-card{flex:1;background:rgba(16,20,28,.8);border:2px solid rgba(255,255,255,.1);border-radius:18px;
  padding:14px 10px;cursor:pointer;transition:all .2s;}
.gm-card:active{transform:scale(.97);}
.gm-card.sel{border-color:#ffcf6b;box-shadow:0 0 24px rgba(200,134,10,.4);background:rgba(200,134,10,.1);}
.gm-portrait{width:100%;aspect-ratio:3/4;border-radius:12px;overflow:hidden;margin-bottom:10px;
  background:linear-gradient(180deg,#1a2230,#0d1119);position:relative;}
.gm-portrait img{position:absolute;width:130%;left:-15%;top:0;object-fit:cover;}
.gm-label{font-family:Unbounded,sans-serif;font-weight:700;font-size:13px;color:#e8e2d4;}
.gm-card.sel .gm-label{color:#ffcf6b;}
.gm-confirm{width:100%;padding:15px;border:none;border-radius:14px;font-family:Unbounded,sans-serif;
  font-weight:800;font-size:15px;cursor:pointer;transition:all .2s;
  background:linear-gradient(180deg,#ffe09a,#c8860a);color:#241701;}
.gm-confirm:disabled{opacity:.4;cursor:not-allowed;filter:grayscale(.5);}
'''
    txt+=css
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS выбора персонажа")
PYEOF


echo ""; echo "══ 4/5  вкладка Агент — смена персонажа + сброс ════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Добавляем в tab-profile блок управления (после достижений)
old='''      <div class="pane-hd" style="margin-top:18px"><div class="pane-title" style="font-size:16px">Достижения</div></div>
      <div class="ach-grid" id="ach-grid"></div>
    </div>'''
new='''      <div class="pane-hd" style="margin-top:18px"><div class="pane-title" style="font-size:16px">Достижения</div></div>
      <div class="ach-grid" id="ach-grid"></div>

      <div class="pane-hd" style="margin-top:18px"><div class="pane-title" style="font-size:16px">Персонаж</div></div>
      <div class="char-switch">
        <button class="cs-btn" data-gender="m" id="cs-m">
          <span class="cs-ico">👤</span><span>Детектив (М)</span>
        </button>
        <button class="cs-btn" data-gender="f" id="cs-f">
          <span class="cs-ico">👤</span><span>Детектив (Ж)</span>
        </button>
      </div>

      <div class="pane-hd" style="margin-top:18px"><div class="pane-title" style="font-size:16px">Игра</div></div>
      <button class="reset-btn" id="reset-progress">↺ Начать игру сначала</button>
    </div>'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + смена персонажа + кнопка сброса в Агенте")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)

# CSS для этих кнопок
path2="src/main/resources/static/style.css"
with open(path2,encoding="utf-8") as f: t2=f.read()
if ".char-switch" not in t2:
    t2+='''
.char-switch{display:flex;gap:10px;}
.cs-btn{flex:1;display:flex;align-items:center;justify-content:center;gap:7px;padding:13px;border-radius:12px;
  background:rgba(16,20,28,.8);border:2px solid rgba(255,255,255,.1);color:#b8b0a0;cursor:pointer;
  font-family:Unbounded,sans-serif;font-weight:700;font-size:12px;transition:all .2s;}
.cs-btn.active{border-color:#ffcf6b;color:#ffcf6b;background:rgba(200,134,10,.1);}
.cs-ico{font-size:15px;}
.reset-btn{width:100%;padding:14px;border-radius:12px;background:rgba(176,80,80,.15);
  border:1.5px solid rgba(220,120,120,.4);color:#ffb3a0;cursor:pointer;
  font-family:Unbounded,sans-serif;font-weight:700;font-size:13px;transition:all .2s;}
.reset-btn:active{transform:scale(.98);background:rgba(176,80,80,.25);}
'''
    with open(path2,"w",encoding="utf-8") as f: f.write(t2)
    print("  + CSS кнопок Агента")
PYEOF


echo ""; echo "══ 5/5  логика — выбор, сброс, показ при старте ════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

if "function initGenderSelect" not in txt:
    fn='''
function initGenderSelect(){
  var modal=document.getElementById('gender-select'); if(!modal) return;
  var picked=null, confirm=document.getElementById('gm-confirm');
  modal.querySelectorAll('.gm-card').forEach(function(c){
    c.addEventListener('click',function(){
      modal.querySelectorAll('.gm-card').forEach(function(x){x.classList.remove('sel');});
      c.classList.add('sel'); picked=c.getAttribute('data-gender');
      if(confirm) confirm.disabled=false;
    });
  });
  if(confirm) confirm.addEventListener('click',function(){
    if(!picked) return;
    if(App.profile){ App.profile.gender=picked; App.profile.onboarded=true; saveProfile(); }
    applyRecruitGender();
    modal.style.display='none';
    try{ updateProfileUI&&updateProfileUI(); }catch(_){}
  });
}
function maybeShowGenderSelect(){
  try{
    if(App.profile && !App.profile.onboarded){
      var m=document.getElementById('gender-select');
      if(m){ m.style.display='flex'; initGenderSelect(); }
    } else { applyRecruitGender(); }
  }catch(_){}
}
function initCharSwitch(){
  var m=document.getElementById('cs-m'), f=document.getElementById('cs-f');
  function refresh(){
    var g=(App.profile&&App.profile.gender)||'m';
    if(m)m.classList.toggle('active',g==='m');
    if(f)f.classList.toggle('active',g==='f');
  }
  function set(g){ if(App.profile){ App.profile.gender=g; saveProfile(); } applyRecruitGender(); refresh();
    try{ if(window.toast) toast('Персонаж изменён','Рекрут обновлён.','👤'); }catch(_){} }
  if(m)m.addEventListener('click',function(){set('m');});
  if(f)f.addEventListener('click',function(){set('f');});
  refresh();
}
function initResetProgress(){
  var btn=document.getElementById('reset-progress'); if(!btn) return;
  btn.addEventListener('click',function(){
    if(confirm('Начать игру сначала? Весь прогресс, улики и шкалы будут сброшены.')){
      try{
        // сброс прогресса дел, шкал, но СОХРАНЯЕМ выбранный пол
        var g=(App.profile&&App.profile.gender)||'m';
        localStorage.removeItem('sdvig_case_state');
        localStorage.removeItem('sdvig_progress');
        App.profile=normalizeProfile({...DEFAULT_PROFILE, gender:g, onboarded:true});
        saveProfile();
        try{ if(window.Feed&&Feed.reset) Feed.reset(); }catch(_){}
        location.reload();
      }catch(e){ console.error('reset',e); }
    }
  });
}
'''
    txt=txt.replace("function initGenderSelect","XfnX") if False else txt
    # вставляем перед initEvPanel
    txt=txt.replace("function initEvPanel(){", fn+"\nfunction initEvPanel(){",1)
    n+=1; print("  + логика выбора/смены/сброса")

# вызываем при инициализации (после enterMain/initEvPanel)
txt=txt.replace("cSetProgress(); buildBacks(); initEvPanel();",
                "cSetProgress(); buildBacks(); initEvPanel(); try{maybeShowGenderSelect();initCharSwitch();initResetProgress();}catch(_){}")
n+=1; print("  + вызовы при старте")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R55 — выбор пола Рекрута + сброс прогресса"
echo "   git add -A && git commit -m 'R55: recruit gender select + reset progress + agent cleanup' && git push"
echo "═══════════════════════════════════════════════════════"
