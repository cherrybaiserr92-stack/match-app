#!/usr/bin/env bash
# СДВИГ R84 — система имени игрока (ввод ника, замена "Рекрут" на ник везде)
set -e
echo "══ штамп → R84 ══"
sed -i "s/SDVIG_BUILD='R83'/SDVIG_BUILD='R84'/" src/main/resources/static/app.js
sed -i 's/>R83</>R84</' src/main/resources/static/index.html

echo ""; echo "══ 1/5  поле playerName в профиль ═════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if "playerName:" not in txt:
    txt=txt.replace("gender:'m', genderChosen:false, prologueSeen:false,",
                    "gender:'m', genderChosen:false, playerName:'', prologueSeen:false,")
    n+=1; print("  + playerName в DEFAULT_PROFILE")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/5  HTML экрана ввода имени ════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if 'id="name-select"' not in txt:
    modal='''
  <!-- ВВОД ИМЕНИ игрока (после выбора пола) -->
  <div id="name-select" class="gender-modal" style="display:none">
    <div class="gm-inner">
      <div class="gm-title">КАК ТЕБЯ ЗВАТЬ?</div>
      <div class="gm-sub">Введи имя, под которым тебя запомнят на этих улицах. Так к тебе будут обращаться Сдвиг и другие.</div>
      <input type="text" id="name-input" class="name-input" maxlength="16" placeholder="Твоё имя" autocomplete="off">
      <div class="name-hint" id="name-hint"></div>
      <button class="gm-confirm" id="name-confirm" disabled>Принять имя</button>
    </div>
  </div>'''
    # вставляем после gender-select
    anchor='  <div id="gender-select" class="gender-modal" style="display:none">'
    # находим закрытие gender-select модалки и вставляем после неё
    idx=txt.find(anchor)
    if idx>=0:
        # ищем закрывающий </div></div> блока (конец модалки)
        end=txt.find('</body>',idx)
        txt=txt[:end]+modal+'\n'+txt[end:]
        n+=1; print("  + HTML экрана ввода имени")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 3/5  CSS поля имени ═════════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".name-input" not in txt:
    txt+='''
/* ── ввод имени игрока ── */
.name-input{width:100%;box-sizing:border-box;padding:16px 18px;margin:10px 0 6px;
  background:rgba(0,0,0,.35);border:2px solid rgba(200,134,10,.3);border-radius:14px;
  color:#fff;font-size:18px;font-family:'Playfair Display',serif;text-align:center;
  outline:none;transition:border-color .2s;}
.name-input:focus{border-color:#c8860a;}
.name-input::placeholder{color:#5a6472;font-style:italic;}
.name-hint{font-size:12px;color:#7a8494;min-height:16px;margin-bottom:14px;text-align:center;}
.name-hint.err{color:#e08080;}
'''
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS поля имени")
PYEOF


echo ""; echo "══ 4/5  логика: пол → имя → игра ═══════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# После подтверждения пола — показать ввод имени (а не сразу в игру)
old='''    if(App.profile){ App.profile.gender=picked; App.profile.genderChosen=true; App.profile.onboarded=true; saveProfile(); }'''
new='''    if(App.profile){ App.profile.gender=picked; saveProfile(); }
      // переход к вводу имени
      var gm=document.getElementById('gender-select'); if(gm) gm.style.display='none';
      var nm=document.getElementById('name-select'); if(nm){ nm.style.display='flex'; initNameSelect(); }
      return;'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + после пола → экран имени")

# Функция initNameSelect
if "function initNameSelect" not in txt:
    code='''
function initNameSelect(){
  var inp=document.getElementById('name-input');
  var btn=document.getElementById('name-confirm');
  var hint=document.getElementById('name-hint');
  if(!inp||!btn) return;
  inp.value=''; btn.disabled=true;
  setTimeout(function(){ try{inp.focus();}catch(_){} },100);
  function validate(){
    var v=inp.value.trim();
    if(v.length<2){ btn.disabled=true; hint.textContent=''; hint.className='name-hint'; return; }
    if(v.length>16){ btn.disabled=true; hint.textContent='Слишком длинно'; hint.className='name-hint err'; return; }
    if(!/^[A-Za-zА-Яа-яЁё0-9 _-]+$/.test(v)){ btn.disabled=true; hint.textContent='Только буквы и цифры'; hint.className='name-hint err'; return; }
    btn.disabled=false; hint.textContent='Хорошее имя'; hint.className='name-hint';
  }
  inp.oninput=validate;
  inp.onkeydown=function(e){ if(e.key==='Enter'&&!btn.disabled) confirmName(); };
  btn.onclick=confirmName;
}
function confirmName(){
  var inp=document.getElementById('name-input');
  var v=(inp&&inp.value.trim())||'Детектив';
  if(App.profile){
    App.profile.playerName=v;
    App.profile.genderChosen=true;
    App.profile.onboarded=true;
    saveProfile();
  }
  var nm=document.getElementById('name-select'); if(nm) nm.style.display='none';
  if(window.toast) toast('Добро пожаловать',v,'🕵');
  try{ if(window.Feed){ Feed.reset&&Feed.reset(); Feed.init&&Feed.init(); } }catch(_){}
}
window.playerName=function(){ try{ return (App.profile&&App.profile.playerName)||'Детектив'; }catch(_){ return 'Детектив'; } };
'''
    txt=txt.replace("function initGenderSelect(){", code+"\nfunction initGenderSelect(){",1)
    n+=1; print("  + initNameSelect / confirmName / playerName()")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 5/5  замена 'Рекрут' → ник в ленте ═════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# 1) Хелпер динамической подписи спикера (recruit → актуальный ник)
if "function speakerName" not in txt:
    idx=txt.find("const NAMES={")
    end=txt.find("};",idx)+2
    helper="\n  function speakerName(spk){\n    if(spk===\'recruit\'){ try{ return (window.playerName?window.playerName():\'Рекрут\'); }catch(_){ return \'Рекрут\'; } }\n    return NAMES[spk]||spk;\n  }\n"
    txt=txt[:end]+helper+txt[end:]
    txt=txt.replace("(NAMES[spk]||spk)","speakerName(spk)")
    n+=1; print("  + динамическая подпись спикера (ник)")

# 2) Замена "Рекрут" в тексте/диалогах при показе
old2="  function renderClues(text){"
new2="  function _playerName(text){\n    if(!text) return text;\n    var nm=\'Рекрут\';\n    try{ nm=(window.playerName?window.playerName():\'Рекрут\'); }catch(_){}\n    return text.replace(/Рекрут/g, nm);\n  }\n  function renderClues(text){\n    text=_playerName(text);"
if old2 in txt and "_playerName" not in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + замена 'Рекрут' → ник в тексте")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R84 — система имени игрока"
echo "   git add -A && git commit -m 'R84: player name system' && git push"
echo "═══════════════════════════════════════════════════════"
