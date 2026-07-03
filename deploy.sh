#!/usr/bin/env bash
# СДВИГ R104 — экран загрузки: убрать дубль надписи, тематическая полоса
set -e
echo "══ штамп → R104 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R104'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R104</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/3  убрать дубль надписи СДВИГ ════════════════"
python3 - << 'PYEOF'
path="app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# убираем построение букв СДВИГ (дублируют логотип)
old="""  // буквы СДВИГ
  'СДВИГ'.split('').forEach(ch=>{ const s=el('span','title-letter',ch); titleRow.appendChild(s); });

  await wait(120);"""
new="""  // (надпись СДВИГ убрана — уже есть на логотипе)
  await wait(120);"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + построение букв убрано")

# убираем анимацию появления букв
old2="""  await wait(380);
  $$('.title-letter').forEach((l,i)=>setTimeout(()=>l.classList.add('in'),i*90));
"""
new2="""  await wait(280);
"""
if old2 in txt: txt=txt.replace(old2,new2,1); n+=1; print("  + анимация букв убрана")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""; echo "══ 2/3  тематические статусы загрузки ═════════════"
python3 - << 'PYEOF'
path="app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""  const steps=[
    [22,'Загрузка дел'],
    [48,'Сбор улик'],
    [74,'Калибровка'],
    [100,'Готово']
  ];"""
new="""  const steps=[
    [20,'Открываем архив'],
    [44,'Раскладываем улики'],
    [68,'Опрашиваем свидетелей'],
    [88,'Выходим на след'],
    [100,'Дело открыто']
  ];"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + детективные статусы")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""; echo "══ 3/3  тематическая полоса загрузки (CSS) ════════"
python3 - << 'PYEOF'
path="style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# прячем title-row + премиальная полоса
txt=txt.replace(".splash-title-row{ display:flex; gap:4px; }",
                ".splash-title-row{ display:none; }")
n+=1

# полоса: шире, с текстурой, багрово-янтарным свечением, бегущим бликом
old=""".splash-progress-wrap{ width:200px; display:flex; flex-direction:column; align-items:center; gap:10px; }
.splash-track{ width:100%; height:4px; border-radius:4px; background:rgba(255,255,255,.08); overflow:hidden; }
.splash-fill{ height:100%; width:0; border-radius:4px; background:linear-gradient(90deg,var(--acc-d),var(--acc-2)); transition:width .35s ease; }
.splash-status{ font-size:11px; letter-spacing:2px; color:var(--ink3); text-transform:uppercase; font-family:'JetBrains Mono',monospace; }"""
new=""".splash-progress-wrap{ width:240px; display:flex; flex-direction:column; align-items:center; gap:14px; }
.splash-track{ position:relative; width:100%; height:8px; border-radius:6px;
  background:rgba(0,0,0,.5); overflow:hidden;
  box-shadow:inset 0 1px 3px rgba(0,0,0,.6), 0 1px 0 rgba(255,255,255,.05);
  border:1px solid rgba(176,38,66,.25); }
.splash-fill{ position:relative; height:100%; width:0; border-radius:5px;
  background:linear-gradient(90deg,#7a1020,#b02642 45%,#e0546e 80%,#ff9db2);
  box-shadow:0 0 12px rgba(224,84,110,.6), 0 0 4px rgba(255,157,178,.8);
  transition:width .5s cubic-bezier(.4,0,.2,1); overflow:hidden; }
/* бегущий блик по заполненной части */
.splash-fill::after{ content:''; position:absolute; inset:0;
  background:linear-gradient(90deg,transparent,rgba(255,255,255,.45),transparent);
  transform:translateX(-100%); animation:splashSheen 1.3s ease-in-out infinite; }
@keyframes splashSheen{ 0%{transform:translateX(-100%);} 60%,100%{transform:translateX(220%);} }
/* тлеющий кончик полосы (как уголёк) */
.splash-fill::before{ content:''; position:absolute; right:0; top:50%; transform:translateY(-50%);
  width:10px; height:10px; border-radius:50%;
  background:radial-gradient(circle,#fff,#ff9db2 40%,transparent 70%);
  box-shadow:0 0 10px rgba(255,157,178,.9); }
.splash-status{ font-size:11px; letter-spacing:3px; color:#c06478; text-transform:uppercase;
  font-family:'Special Elite','JetBrains Mono',monospace; }"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + тематическая полоса (багровая, блик, тлеющий кончик)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ style.css: %d"%n)
PYEOF

cd - >/dev/null

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R104 — экран загрузки: дубль убран, полоса тематическая"
echo "   git add -A && git commit -m 'R104: loading screen - remove title dup, themed progress bar' && git push"
echo "═══════════════════════════════════════════════════════"
