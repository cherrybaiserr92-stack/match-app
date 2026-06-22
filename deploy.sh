#!/usr/bin/env bash
# СДВИГ R56 — выбор персонажа (показ), кнопки Агента (делегирование), подсказки без спойлера, досье
set -e
echo "══ штамп → R56 ══"
sed -i "s/SDVIG_BUILD='R55'/SDVIG_BUILD='R56'/" src/main/resources/static/app.js
sed -i 's/>R55</>R56</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  кнопки Агента — делегирование (переживает перерисовку)"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Заменяем initCharSwitch/initResetProgress на ОДНУ функцию с делегированием на document
old_calls="try{maybeShowGenderSelect();initCharSwitch();initResetProgress();}catch(_){}"
new_calls="try{maybeShowGenderSelect();bindAgentControls();}catch(_){}"
txt=txt.replace(old_calls,new_calls)
n+=1; print("  + вызов bindAgentControls (делегирование)")

# Новая функция делегирования — вешается на document ОДИН раз, работает после любой перерисовки
if "function bindAgentControls" not in txt:
    fn='''function bindAgentControls(){
  if(window._agentBound) return; window._agentBound=true;
  document.addEventListener('click', function(e){
    var t=e.target.closest&&e.target.closest('[data-gender]');
    // смена персонажа в Агенте (кнопки cs-m/cs-f)
    if(t && (t.id==='cs-m'||t.id==='cs-f')){
      var g=t.getAttribute('data-gender');
      if(App.profile){ App.profile.gender=g; saveProfile(); }
      applyRecruitGender();
      document.querySelectorAll('#cs-m,#cs-f').forEach(function(b){
        b.classList.toggle('active', b.getAttribute('data-gender')===g);
      });
      try{ if(window.toast) toast('Персонаж изменён','Рекрут обновлён во всей игре.','👤'); }catch(_){}
      return;
    }
    // сброс прогресса
    if(e.target.closest&&e.target.closest('#reset-progress')){
      if(confirm('Начать игру сначала? Прогресс, улики и шкалы сбросятся (выбранный персонаж сохранится).')){
        try{
          var gen=(App.profile&&App.profile.gender)||'m';
          localStorage.removeItem('sdvig_case_state');
          localStorage.removeItem('sdvig_progress');
          localStorage.removeItem('sdvig_feed_history');
          App.profile=normalizeProfile({...DEFAULT_PROFILE, gender:gen, onboarded:true});
          saveProfile();
          location.reload();
        }catch(err){ console.error('reset',err); }
      }
      return;
    }
  });
}
function _refreshAgentGender(){
  var g=(App.profile&&App.profile.gender)||'m';
  document.querySelectorAll('#cs-m,#cs-f').forEach(function(b){
    b.classList.toggle('active', b.getAttribute('data-gender')===g);
  });
}
'''
    txt=txt.replace("function maybeShowGenderSelect", fn+"function maybeShowGenderSelect",1)
    n+=1; print("  + bindAgentControls + _refreshAgentGender")

# renderProfile в конце обновляет подсветку пола
txt=txt.replace("function renderProfile(){\n  const p=App.profile, u=App.user||{};",
                "function renderProfile(){\n  const p=App.profile, u=App.user||{};\n  try{ _refreshAgentGender(); }catch(_){}")
n+=1; print("  + подсветка пола при открытии Агента")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/4  выбор персонажа — кнопка перевыбора + надёжный показ"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# maybeShowGenderSelect: показывать выбор если пол ещё не выбран ЯВНО (новое поле genderChosen)
old='''function maybeShowGenderSelect(){
  try{
    if(App.profile && !App.profile.onboarded){
      var m=document.getElementById('gender-select');
      if(m){ m.style.display='flex'; initGenderSelect(); }
    } else { applyRecruitGender(); }
  }catch(_){}
}'''
new='''function maybeShowGenderSelect(){
  try{
    applyRecruitGender();
    if(App.profile && !App.profile.genderChosen){
      var m=document.getElementById('gender-select');
      if(m){ m.style.display='flex'; initGenderSelect(); }
    }
  }catch(_){}
}
window.openGenderSelect=function(){
  var m=document.getElementById('gender-select');
  if(m){ m.style.display='flex'; initGenderSelect(); }
};'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + показ выбора по genderChosen + openGenderSelect")

# initGenderSelect: ставим genderChosen=true при подтверждении
txt=txt.replace("if(App.profile){ App.profile.gender=picked; App.profile.onboarded=true; saveProfile(); }",
                "if(App.profile){ App.profile.gender=picked; App.profile.genderChosen=true; App.profile.onboarded=true; saveProfile(); }")
n+=1; print("  + genderChosen при подтверждении")

# DEFAULT_PROFILE: добавляем genderChosen:false
txt=txt.replace("gender:'m', onboarded:false","gender:'m', genderChosen:false, onboarded:false")
n+=1; print("  + genderChosen в профиль")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/4  кнопка «Сменить персонажа» открывает выбор ══"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Заменяем две кнопки cs-m/cs-f на понятную: текущий + кнопка "сменить"
old='''      <div class="char-switch">
        <button class="cs-btn" data-gender="m" id="cs-m">
          <span class="cs-ico">👤</span><span>Детектив (М)</span>
        </button>
        <button class="cs-btn" data-gender="f" id="cs-f">
          <span class="cs-ico">👤</span><span>Детектив (Ж)</span>
        </button>
      </div>'''
new='''      <div class="char-switch">
        <button class="cs-btn" data-gender="m" id="cs-m">
          <span class="cs-ico">🕵️</span><span>Мужчина</span>
        </button>
        <button class="cs-btn" data-gender="f" id="cs-f">
          <span class="cs-ico">🕵️‍♀️</span><span>Женщина</span>
        </button>
      </div>'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + кнопки пола обновлены")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 4/4  подсказки БЕЗ спойлера + досье счётчик/анимация"
python3 - << 'PYEOF'
import json
# Подсказки переписываем — НЕ называем суть улики, только направление действия
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
ev=d['events']
hints={
  'eL2a':'Осмотри пол у стены внимательнее — там что-то есть.',
  'eL2b':'Сдвиг кивнул в сторону стены. Присмотрись.',
  'eL2c2':'За тяжёлой портьерой тянет холодом. Проверь её.',
  'eL2c3':'Среди старой проводки мелькнуло что-то неуместное. Разгляди.',
  'eL3c3':'Сторож что-то прячет в кармане. Загляни туда.',
  'eL4c1':'На столе мигает огонёк. Стоит проверить.',
}
n=0
for k,h in hints.items():
    if k in ev and ev[k].get('hint'):
        ev[k]['hint']=h; n+=1
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print(f"  + {n} подсказок переписаны без спойлера")

# Досье: счётчик ev-chip + анимация в правый нижний угол
path2="src/main/resources/static/games/feed.js"
with open(path2,encoding="utf-8") as f: txt=f.read()
n2=0
# flyToDossier — летит к РЕАЛЬНОМУ положению счётчика (ev-chip), а не к фикс. координатам
import re
old_fly="fly.style.left=(sr.width-60)+'px'; fly.style.top=(sr.height-30)+'px'; fly.style.opacity='0'; fly.style.transform='scale(.4)';"
new_fly='''var _chip=document.getElementById('ev-chip');
      if(_chip){ var cr=_chip.getBoundingClientRect(); var pr=fly.parentElement.getBoundingClientRect();
        fly.style.left=(cr.left-pr.left+cr.width/2-20)+'px'; fly.style.top=(cr.top-pr.top+cr.height/2-20)+'px';
      } else { fly.style.left=(sr.width-60)+'px'; fly.style.top=(sr.height-30)+'px'; }
      fly.style.opacity='0'; fly.style.transform='scale(.4)';'''
if old_fly in txt:
    txt=txt.replace(old_fly,new_fly,1); n2+=1; print("  + улика летит к реальному счётчику ev-chip")
with open(path2,"w",encoding="utf-8") as f: f.write(txt)
print(f"✓ feed.js: {n2}")

# Счётчик ev-chip: обновление числа при добавлении улики
path3="src/main/resources/static/app.js"
with open(path3,encoding="utf-8") as f: t3=f.read()
n3=0
# grantClue обновляет #ev-count
if "_evCountEl" in t3 and "document.getElementById('ev-count')" not in t3:
    t3=t3.replace("if(_evCountEl) _evCountEl.textContent=CState.clues.length;",
                  "if(_evCountEl) _evCountEl.textContent=CState.clues.length;\n  try{ var _ec=document.getElementById('ev-count'); if(_ec)_ec.textContent=CState.clues.length; }catch(_){}")
    n3+=1; print("  + счётчик улик обновляется")
with open(path3,"w",encoding="utf-8") as f: f.write(t3)
print(f"✓ app.js счётчик: {n3}")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R56 — выбор персонажа, кнопки Агента, подсказки, досье"
echo "   git add -A && git commit -m 'R56: gender select show, agent buttons, hint no-spoiler, dossier' && git push"
echo "═══════════════════════════════════════════════════════"
