#!/usr/bin/env bash
# СДВИГ R93 — премиальная нижняя панель (объём, переливы, нажимаемые кнопки)
set -e
echo "══ штамп → R93 ══"
sed -i "s/SDVIG_BUILD='R92'/SDVIG_BUILD='R93'/" src/main/resources/static/app.js
sed -i 's/>R92</>R93</' src/main/resources/static/index.html

echo ""; echo "══ премиальная навбар CSS ═════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# 1) Заменяем .bottom-nav на объёмную премиальную версию
import re
old_nav=re.search(r'\.bottom-nav\{[^}]*\}', txt)
if old_nav:
    new_nav='''.bottom-nav{
  flex:0 0 auto;
  position:fixed; left:0; right:0; bottom:0; z-index:120;
  display:flex; align-items:stretch;
  height:calc(var(--navh) + var(--safeb));
  padding:8px 10px var(--safeb);
  /* объёмная многослойная подложка */
  background:
    linear-gradient(180deg, rgba(28,33,46,.92) 0%, rgba(14,18,26,.96) 100%);
  -webkit-backdrop-filter:blur(24px) saturate(1.3);
  backdrop-filter:blur(24px) saturate(1.3);
  border-top:1px solid rgba(255,255,255,.12);
  box-shadow:
    0 -1px 0 rgba(255,255,255,.06) inset,
    0 -12px 30px rgba(0,0,0,.45),
    0 -2px 8px rgba(0,0,0,.3);
  pointer-events:auto;
}
/* верхний блик-перелив вдоль панели */
.bottom-nav::before{
  content:''; position:absolute; top:0; left:10%; right:10%; height:1px;
  background:linear-gradient(90deg, transparent, rgba(255,207,107,.35), transparent);
}'''
    txt=txt[:old_nav.start()]+new_nav+txt[old_nav.end():]
    n+=1; print("  + .bottom-nav объёмная с бликом")

# 2) Заменяем .nb на объёмные нажимаемые кнопки
old_nb=re.search(r'\.nb\{[^}]*\}', txt)
if old_nb:
    new_nb='''.nb{
  flex:1; position:relative; display:flex; flex-direction:column;
  align-items:center; justify-content:center; gap:3px;
  background:none; border:none; cursor:pointer; color:var(--ink4);
  font-family:inherit; pointer-events:auto;
  border-radius:16px; margin:0 2px;
  transition:color .25s ease, transform .12s ease, background .25s ease;
  -webkit-tap-highlight-color:transparent;
}
/* подсветка-капсула под активной кнопкой */
.nb::before{
  content:''; position:absolute; inset:4px 6px;
  border-radius:14px; opacity:0; transform:scale(.8);
  background:
    radial-gradient(120% 100% at 50% 0%, rgba(255,207,107,.22), rgba(200,134,10,.06) 60%, transparent);
  box-shadow:
    0 0 0 1px rgba(255,207,107,.25) inset,
    0 4px 14px rgba(200,134,10,.25);
  transition:opacity .3s ease, transform .3s cubic-bezier(.34,1.56,.64,1);
  pointer-events:none;
}
.nb:active{ transform:translateY(1px) scale(.96); }
.nb:active::before{ opacity:.5; transform:scale(.95); }'''
    txt=txt[:old_nb.start()]+new_nb+txt[old_nb.end():]
    n+=1; print("  + .nb объёмные нажимаемые")

# 3) Активная кнопка — капсула видна, иконка поднята и светится
txt=txt.replace(".nb.active{ color:var(--acc-2); }",
'''.nb.active{ color:var(--acc-2); }
.nb.active::before{ opacity:1; transform:scale(1); }
.nb.active [data-ico]{
  transform:translateY(-2px) scale(1.08);
  filter:drop-shadow(0 0 6px rgba(255,207,107,.6));
}
.nb [data-ico]{ transition:transform .3s cubic-bezier(.34,1.56,.64,1), filter .3s ease; position:relative; z-index:1; }
.nb-lbl{ position:relative; z-index:1; transition:opacity .25s ease; }
.nb.active .nb-lbl{ text-shadow:0 0 8px rgba(255,207,107,.4); }''')
n+=1; print("  + активная кнопка: капсула + подъём иконки + свечение")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ style.css: %d"%n)
PYEOF

echo ""; echo "══ тактильный отклик при нажатии вкладок ══════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# при клике по навбару — лёгкая вибрация
if "_navHaptic" not in txt:
    old="function goToTab(t){ $('.nb[data-tab=\"'+t+'\"]')?.click(); }"
    new='''function _navHaptic(){ try{ navigator.vibrate&&navigator.vibrate(8); }catch(_){} }
function goToTab(t){ $('.nb[data-tab="'+t+'"]')?.click(); }
document.addEventListener('DOMContentLoaded',function(){
  document.querySelectorAll('.nb').forEach(function(b){
    b.addEventListener('click',_navHaptic);
  });
});'''
    if old in txt:
        txt=txt.replace(old,new,1); n+=1; print("  + тактильный отклик навбара")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R93 — премиальная нижняя панель"
echo "   git add -A && git commit -m 'R93: premium bottom navigation bar' && git push"
echo "═══════════════════════════════════════════════════════"
