#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  СДВИГ R10.1 · Фиксы после интеграции карусели
# ═══════════════════════════════════════════════════════════
set -e
echo ""
echo "══ 1/2  app.js — фиксы логики ══════════════════════"
python3 - << 'PYEOF'
import sys

path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f:
    txt = f.read()

changes = 0

# ── 1. unlockSwipe (был удалён при замене секции R10) ──────
if "function unlockSwipe()" not in txt:
    anchor = "function removeLockOverlay(){"
    if anchor in txt:
        txt = txt.replace(anchor,
            "function unlockSwipe(){\n"
            "  App.swipeUnlocked=true;\n"
            "  vibrate(20); try{Sound.booster();}catch(_){}\n"
            "  try{removeLockOverlay();}catch(_){}\n"
            "}\n" + anchor, 1)
        print("  + unlockSwipe восстановлен")
        changes += 1
    else:
        print("  ⚠ якорь removeLockOverlay не найден")
else:
    print("  · unlockSwipe уже есть")

# ── 2. backHTML: убираем маленькие «С» из углов рубашки ────
old_back = (
    "function backHTML(){return gframeHTML()+"
    "'<span class=\"crank t\">С</span><span class=\"crank b\">С</span>"
    "<div class=\"cmono\">С</div>';}"
)
new_back = "function backHTML(){return gframeHTML()+'<div class=\"cmono\">С</div>';}"
if old_back in txt:
    txt = txt.replace(old_back, new_back, 1)
    print("  + backHTML: угловые «С» убраны")
    changes += 1
elif 'crank t' not in txt:
    print("  · backHTML уже без crank")

# ── 3. addLockOverlay: скрываем choices пока замок показан ─
old_add = (
    "function addLockOverlay(cardEl){\n"
    "  const pad=cardEl.querySelector('.pad'); if(!pad) return;\n"
    "  if(pad.querySelector('.card-lock')) return;"
)
new_add = (
    "function addLockOverlay(cardEl){\n"
    "  const pad=cardEl.querySelector('.pad'); if(!pad) return;\n"
    "  if(pad.querySelector('.card-lock')) return;\n"
    "  const _ch=pad.querySelector('.choices'); if(_ch) _ch.style.display='none';"
)
if old_add in txt and '_ch=pad.querySelector' not in txt:
    txt = txt.replace(old_add, new_add, 1)
    print("  + addLockOverlay: choices скрыты")
    changes += 1

# ── 4. removeLockOverlay: восстанавливаем choices ──────────
old_rem = (
    "function removeLockOverlay(){\n"
    "  const lock=document.querySelector('.cfcard.active .card-lock');\n"
    "  if(lock) lock.remove();\n"
    "}"
)
new_rem = (
    "function removeLockOverlay(){\n"
    "  const lock=document.querySelector('.cfcard.active .card-lock');\n"
    "  if(!lock) return;\n"
    "  const _p=lock.closest('.pad'); lock.remove();\n"
    "  if(_p){const _c=_p.querySelector('.choices');if(_c) _c.style.display='';}\n"
    "}"
)
if old_rem in txt:
    txt = txt.replace(old_rem, new_rem, 1)
    print("  + removeLockOverlay: choices восстановлены")
    changes += 1

with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
if changes == 0:
    print("  · все JS-фиксы уже применены")
print("✓ app.js сохранён")
PYEOF


echo ""
echo "══ 2/2  card-design.css — визуальные фиксы ══════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f:
    txt = f.read()

if "/* R10.1 FIX */" in txt:
    print("  · CSS-фиксы уже применены")
else:
    fix_css = """
/* ════ R10.1 FIX ════════════════════════════════════════ */

/* 1. Карточки полупрозрачнее */
.cfinner{
  background:
    radial-gradient(130% 75% at 50% -6%, rgba(74,56,30,.18), transparent 58%),
    repeating-linear-gradient(115deg, rgba(255,255,255,.01) 0 2px, transparent 2px 5px),
    linear-gradient(158deg,rgba(34,29,22,.70) 0%,rgba(11,9,7,.78) 72%) !important;
  box-shadow:
    0 0 0 2.5px rgba(169,121,15,.65),
    0 0 0 3.5px rgba(0,0,0,.4),
    0 16px 40px rgba(0,0,0,.52),
    0 0 20px rgba(180,120,20,.1),
    inset 0 0 60px rgba(0,0,0,.48) !important;
}

/* 2. tools-bar в flex-потоке (не перекрывает карточки) */
#tab-cases > .tools-bar{
  position:relative !important;
  bottom:auto !important; left:auto !important; right:auto !important;
  flex:0 0 auto;
  padding:6px 14px max(8px,env(safe-area-inset-bottom));
  background:linear-gradient(0deg,rgba(6,8,12,.88) 0%,rgba(6,8,12,.0) 100%);
  margin-bottom:0;
  pointer-events:auto;
}
/* Все дочерние кнопки кликабельны */
#tab-cases > .tools-bar > *{ pointer-events:auto; }

/* 3. Отступ под нижнее меню (tab-cases учитывает nav) */
#tab-cases{
  padding-bottom:calc(var(--navh) + var(--safeb)) !important;
}

/* 4. Карточка: badge отступает от filigree */
.cfcard.active .cfinner .pad{
  padding-top:50px;
  padding-bottom:10px;
}
.cfcard.active .pad > .badge{
  margin-top:0;
}

/* 5. Текст: не более 4 строк, иначе выходит за край */
.cfcard.active .text{
  -webkit-line-clamp:4;
  font-size:13px;
  line-height:1.45;
}

/* 6. card-lock: поверх всего, не перекрывает badge */
.card-lock{
  position:absolute !important;
  bottom:0 !important; left:0 !important; right:0 !important;
  top:auto !important;
  z-index:20 !important;
  background:linear-gradient(
    0deg,
    rgba(5,8,13,.98) 0%,
    rgba(5,8,13,.92) 52%,
    rgba(5,8,13,.0) 100%
  ) !important;
  padding:36px 15px 16px !important;
  border-radius:0 0 13px 13px !important;
}

/* 7. Shift-карты: vstack компактнее */
.vstack{ gap:5px; margin-top:4px; }
.vpanel .vlabel{ font-size:14px; margin-bottom:3px; }
.vpanel .vtext{ font-size:11.5px; }
.shift-intro{ font-size:12px; margin:2px 0 4px; }

/* 8. choices компактнее */
.choices{ margin-top:8px; gap:6px; }
.choice{ padding:9px 7px; font-size:11.5px; }
.choice .dir{ font-size:9px; margin-bottom:2px; }

/* 9. title чуть меньше на маленьких картах */
.cfcard.active .title{ font-size:18px; margin:8px 0 7px; }
"""
    txt += fix_css
    with open(path, "w", encoding="utf-8") as f:
        f.write(txt)
    print("✓ card-design.css: визуальные фиксы добавлены")

PYEOF


echo ""
echo "═══════════════════════════════════════════════════"
echo "✅  R10.1 готов"
echo "   git add -A && git commit -m 'R10.1: unlock fix + layout fixes' && git push"
echo "═══════════════════════════════════════════════════"
