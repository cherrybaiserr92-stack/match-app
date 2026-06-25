#!/usr/bin/env bash
# СДВИГ R74 — фикс отладчика: список уровней + синхронизация с картой
set -e
echo "══ штамп → R74 ══"
sed -i "s/SDVIG_BUILD='R73'/SDVIG_BUILD='R74'/" src/main/resources/static/app.js
sed -i 's/>R73</>R74</' src/main/resources/static/index.html

echo ""; echo "══ 1/2  CAMPAIGN → window (список уровней появится) ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# После загрузки CAMPAIGN пробрасываем в window
old='  CAMPAIGN=xhrJson("/scenarios/campaign.json");\n  if(!CAMPAIGN)CAMPAIGN={cases:[{id:"case001"}]};'
new='  CAMPAIGN=xhrJson("/scenarios/campaign.json");\n  if(!CAMPAIGN)CAMPAIGN={cases:[{id:"case001"}]};\n  window.CAMPAIGN=CAMPAIGN;'
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + window.CAMPAIGN проброшен (список заполнится)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/2  admGoto — синхронизация с картой (mapNode) ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# admGoto: при переходе на уровень обновляем и mapNode (подсветка на карте)
old='''window.admGoto=function(i){
  try{
    _caseIdx=i;
    try{ localStorage.setItem('sdvig_case', CAMPAIGN.cases[i].id); }catch(_){}
    loadCaseByIndex(i);
    if(window.Feed){ try{initCarousel_data();}catch(_){}; Feed.reset(); Feed.init(); }
    closeAdmin();
    if(window.toast) toast('Уровень '+(i+1),CAMPAIGN.cases[i].id,'⚙');
  }catch(e){ alert('Ошибка перехода: '+e.message); }
};'''
new='''window.admGoto=function(i){
  try{
    _caseIdx=i;
    try{ localStorage.setItem('sdvig_case', CAMPAIGN.cases[i].id); }catch(_){}
    // синхронизируем карту: mapNode = индекс уровня (разблокируем путь до него)
    if(App.profile){ App.profile.mapNode=i; saveProfile(); }
    loadCaseByIndex(i);
    if(window.Feed){ try{initCarousel_data();}catch(_){}; Feed.reset(); Feed.init(); }
    try{ renderMap&&renderMap(); }catch(_){}
    closeAdmin();
    if(window.toast) toast('Уровень '+(i+1),(CAMPAIGN.cases[i].subtitle||CAMPAIGN.cases[i].id),'⚙');
  }catch(e){ alert('Ошибка перехода: '+e.message); }
};'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + admGoto синхронит mapNode + renderMap")

# admJump тоже через admGoto (уже так) — ок. Добавим обновление списка после перехода
# Список уровней: подсветка текущего обновляется при openAdmin (уже есть)
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R74 — отладчик: список уровней + синхрон с картой"
echo "   git add -A && git commit -m 'R74: fix admin panel level list + map sync' && git push"
echo "═══════════════════════════════════════════════════════"
