#!/usr/bin/env bash
# СДВИГ R92 — фикс мелькания splash + переименование Аркад + убрать метки пола
set -e
echo "══ штамп → R92 ══"
sed -i "s/SDVIG_BUILD='R91'/SDVIG_BUILD='R92'/" src/main/resources/static/app.js
sed -i 's/>R91</>R92</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  ФИКС мелькания: заслон под splash/прологом ═"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Пока онбординг не пройден — непрозрачный заслон поверх stage, чтобы не было видно нутро
if ".onboarding-guard" not in txt:
    txt+='''
/* ── заслон от мелькания нутра до показа пролога/выбора ── */
body:not(.app-ready) .stage,
body:not(.app-ready) .bottom-nav,
body:not(.app-ready) .topbar{ visibility:hidden !important; }
body:not(.app-ready)::before{
  content:''; position:fixed; inset:0; z-index:5;
  background:#080a0e;
}
/* пролог и сплэш — мгновенно непрозрачный фон, без просвета */
#prologue{ background:#080a0e !important; }
#splash-screen{ background:#080a0e; }
'''
    n+=1; print("  + заслон body:not(.app-ready) (нутро скрыто до готовности)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ style.css: %d"%n)
PYEOF

python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Помечаем app-ready ТОЛЬКО когда онбординг пройден или показан пролог/выбор
# (чтобы нутро открылось лишь после прохождения приветствия)
if "document.body.classList.add('app-ready')" not in txt:
    # в _finishPrologue и при уже пройденном онбординге
    txt=txt.replace(
      "function _finishPrologue(){\n  var pr=document.getElementById('prologue'); if(pr) pr.style.display='none';",
      "function _finishPrologue(){\n  var pr=document.getElementById('prologue'); if(pr) pr.style.display='none';\n  document.body.classList.add('app-ready');",1)
    n+=1
    # если онбординг уже пройден — открыть нутро сразу после старта
    txt=txt.replace(
      "function maybeShowGenderSelect(){\n  try{\n    applyRecruitGender();",
      "function maybeShowGenderSelect(){\n  try{\n    applyRecruitGender();\n    if(App.profile && App.profile.genderChosen && App.profile.onboarded){ document.body.classList.add('app-ready'); }",1)
    n+=1
    # подстраховка: после confirmName тоже
    txt=txt.replace("App.profile.onboarded=true;\n    saveProfile();\n  }\n  var nm=document.getElementById('name-select');",
                    "App.profile.onboarded=true;\n    saveProfile();\n  }\n  document.body.classList.add('app-ready');\n  var nm=document.getElementById('name-select');",1)
    print("  + app-ready выставляется после онбординга")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/4  переименование «Аркады» → «Досуг» ═════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# навбар-метка
if '<span class="nb-lbl">Аркады</span>' in txt:
    txt=txt.replace('<span class="nb-lbl">Аркады</span>','<span class="nb-lbl">Досуг</span>')
    n+=1; print("  + навбар: Аркады → Досуг")
# заголовок панели
if '<div class="pane-title">Аркады</div>' in txt:
    txt=txt.replace('<div class="pane-title">Аркады</div>','<div class="pane-title">Досуг</div>')
    n+=1; print("  + заголовок панели: Аркады → Досуг")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 3/4  убрать метки пола у Рекрута ═══════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# во вкладке Агента карточки персонажа — убрать подписи Мужчина/Женщина
import re
# заменяем имена карточек на нейтральные (или пустые)
txt=txt.replace('<div class="ag-char-name">Мужчина</div>','<div class="ag-char-name">Детектив</div>',1)
txt=txt.replace('<div class="ag-char-name">Женщина</div>','<div class="ag-char-name">Детектив</div>',1)
n+=2; print("  + карточки персонажа: убраны Мужчина/Женщина → Детектив")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF

python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# toast при выборе — убрать "Детектив-женщина/мужчина"
old="""  try{ if(window.toast) toast('Персонаж выбран', (g==='f'?'Детектив-женщина':'Детектив-мужчина')+'. Обновлено во всей игре.', '🕵️'); }catch(_){}"""
new="""  try{ if(window.toast) toast('Персонаж выбран', 'Обновлено во всей игре.', '🕵️'); }catch(_){}"""
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + toast без указания пола")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 4/4  gender-select — нейтральные подписи ═══════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# на экране выбора оставляем Мужчина/Женщина (это выбор внешности — норм),
# но если хочется совсем нейтрально — меняем на "Он"/"Она". Пока оставим выбор как есть.
# (метки убраны только из постоянного интерфейса Агента и toast)
print("  (экран выбора персонажа оставлен — там выбор внешности уместен)")
print("✓ index.html: 0")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R92 — splash без мелькания, Досуг, метки пола убраны"
echo "   git add -A && git commit -m 'R92: fix splash flash, rename Arcades, remove gender labels' && git push"
echo "═══════════════════════════════════════════════════════"
