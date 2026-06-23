#!/usr/bin/env bash
# СДВИГ R61 — фикс: пролог не показывался (вызов был в неиспользуемой initCarousel)
set -e
echo "══ штамп → R61 ══"
sed -i "s/SDVIG_BUILD='R60'/SDVIG_BUILD='R61'/" src/main/resources/static/app.js
sed -i 's/>R60</>R61</' src/main/resources/static/index.html

echo ""; echo "══ перенос вызова пролога в enterMain (Feed-режим) ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Добавляем вызов в enterMain ПОСЛЕ всех рендеров (там где Feed уже активен)
old='''  try{ checkDaily(); }catch(e){ console.error('checkDaily',e); }
}'''
new='''  try{ checkDaily(); }catch(e){ console.error('checkDaily',e); }
  // пролог + выбор персонажа (работает и в Feed-режиме)
  try{ maybeShowGenderSelect(); bindAgentControls(); }catch(e){ console.error('prologue',e); }
}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + maybeShowGenderSelect вызывается из enterMain")

# Подстраховка: задержка, чтобы DOM пролога точно был готов
txt=txt.replace(
  "  // пролог + выбор персонажа (работает и в Feed-режиме)\n  try{ maybeShowGenderSelect(); bindAgentControls(); }catch(e){ console.error('prologue',e); }",
  "  // пролог + выбор персонажа (работает и в Feed-режиме)\n  setTimeout(function(){ try{ maybeShowGenderSelect(); bindAgentControls(); }catch(e){ console.error('prologue',e); } }, 300);")
n+=1; print("  + задержка 300мс для готовности DOM")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R61 — пролог теперь показывается (Feed-режим)"
echo "   git add -A && git commit -m 'R61: fix prologue not showing in Feed mode' && git push"
echo "═══════════════════════════════════════════════════════"
