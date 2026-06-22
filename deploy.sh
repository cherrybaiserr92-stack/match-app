#!/usr/bin/env bash
# СДВИГ R59 — премиум-иконки в шкалах и Агенте (лупа, шляпа)
set -e
echo "══ штамп → R59 ══"
sed -i "s/SDVIG_BUILD='R58'/SDVIG_BUILD='R59'/" src/main/resources/static/app.js
sed -i 's/>R58</>R59</' src/main/resources/static/index.html

echo ""; echo "══ 1/2  шкалы внизу — иконки вместо эмодзи ═════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Шкала Сдвиг: 🎩 → шляпа
txt=txt.replace(
  '<span class="gscale-name"><span class="gscale-ico">🎩</span>Сдвиг</span>',
  '<span class="gscale-name"><img class="gscale-ico-img" src="/img/icons/ico-hat.png" alt="">Сдвиг</span>')
# Шкала Детектив: 🔍 → лупа
txt=txt.replace(
  '<span class="gscale-name"><span class="gscale-ico">🔍</span>Детектив</span>',
  '<span class="gscale-name"><img class="gscale-ico-img" src="/img/icons/ico-magnify.png" alt="">Детектив</span>')
n+=1; print("  + иконки в шкалах (шляпа, лупа)")

# Агент статы: тоже заменить
txt=txt.replace('<div class="ag-stat-ico">🔍</div>','<div class="ag-stat-ico"><img class="ag-stat-img" src="/img/icons/ico-magnify.png" alt=""></div>')
txt=txt.replace('<div class="ag-stat-ico">🎩</div>','<div class="ag-stat-ico"><img class="ag-stat-img" src="/img/icons/ico-hat.png" alt=""></div>')
n+=1; print("  + иконки в статах Агента")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/2  CSS иконок шкал ═════════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".gscale-ico-img" not in txt:
    txt+='''
/* ── премиум-иконки шкал ── */
.gscale-ico-img{width:20px;height:20px;object-fit:contain;
  filter:drop-shadow(0 1px 3px rgba(0,0,0,.5));vertical-align:middle;}
.ag-stat-img{width:30px;height:30px;object-fit:contain;
  filter:drop-shadow(0 2px 4px rgba(0,0,0,.4));}
.ag-stat-ico{display:flex;align-items:center;justify-content:center;margin-bottom:6px;}
'''
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS иконок шкал/статов")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R59 — премиум-иконки в шкалах и Агенте"
echo "   git add -A && git commit -m 'R59: premium icons in scales and agent' && git push"
echo "═══════════════════════════════════════════════════════"
